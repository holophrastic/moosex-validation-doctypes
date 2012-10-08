package MooseX::Validation::Doctypes;

use strict;
use warnings;

use Moose;
use Moose::Util qw/find_meta/;
use Moose::Util::TypeConstraints;

use subs qw/expand_hash collapse_hash/;

use Moose::Exporter;
Moose::Exporter->setup_import_methods(
    as_is => [
        qw/as doctype list_doctype validate_doctype/
    ],
);

sub doctype {
    if(@_ == 1 && !ref $_[0]) {
        __PACKAGE__->_throw_error(
            'A doctype must have a parent'
        );
    }

    my $name = (ref $_[0] && !blessed $_[0]) ? undef : shift;
    my %p = map { %{$_} } @_;

    if(!exists $p{as}) {
        $p{as} = $name;
        $name = undef;
    }

    my $caller = caller;
    my $meta = find_meta($caller);

    unless($meta->get_method('_get_moosex_validation_doctypes')) {
        $meta->add_attribute('_moosex_validation_doctypes' => (
            reader => '_get_moosex_validation_doctypes'
        ));
    }

    my $dt = $meta->get_attribute('_moosex_validation_doctypes');
    my $caller_obj = Class::MOP::Class->initialize($caller);
    my $doctypes = $dt->get_value($caller_obj) || {};
    $doctypes->{$name} = $p{as};
    $dt->set_value($caller_obj, $doctypes);
}

sub list_doctype {
    my ($self, $type) = @_;
    my $doctypes = $self->meta->get_attribute('_moosex_validation_doctypes')->get_value(Class::MOP::Class->initialize(ref $self));
    if($type) {
        return $doctypes->{$type} || {};
    }
    return $doctypes;
}

sub validate_doctype {
    my ($self, $type, $doc) = @_;
    die 'Must pass a doctype to validate_doctype' unless($type);
    die 'Must pass a document to validate to validate_doctype' unless($doc);

    my $doctype = $self->list_doctype($type);
    unless(scalar keys(%{$doctype})) {
        die 'No doctype of that type';
    }

    my $errors;
    my $constraint_errors;
    my $flat_doctype = collapse_hash($doctype);
    my $flat_doc = collapse_hash($doc);

    foreach my $key (keys %{$flat_doctype}) {
        my $constraint = Moose::Util::TypeConstraints::find_or_parse_type_constraint($flat_doctype->{$key});
        die "Unknown type $key" unless($constraint);
        my $value = delete $flat_doc->{$key};

        unless($constraint->check($value)) {
            if(ref($value) eq 'ARRAY') {
                my $array_value = join ',', @{$value};
                $value = "[" . $array_value . "]";
            } else {
                $value ||= 'undef';
            }
            $constraint_errors->{$key} = "invalid value '$value' for type '$key'";
        }
    }

    if(scalar keys(%{$constraint_errors})) {
        $errors->{errors} = expand_hash($constraint_errors);
    }
    if(scalar keys(%{$flat_doc})) {
        $errors->{extra_data} = expand_hash($flat_doc);
    }

    return $errors || 0;
}

# The functions below and generally ripped from CGI::Expand.
# They do less, much much less, especially with arrays, because all
# we actually care about is handling a nested hashref.
# Props to CGI::Expand for being so easy to work from, though.

sub split_name {
    my $name  = shift;
    my $sep = "\Q.";
 
    $name =~ m/^ ( [^\\$sep]* (?: \\(?:.|$) [^\\$sep]* )* ) /gx;
    my $first = $1;
    $first =~ s/\\(.)/$1/g;
 
    my (@segments) = $name =~ m/\G (?:[$sep]) ( [^\\$sep]* (?: \\(?:.|$) [^\\$sep]* )* ) /gx;
    return ($first, @segments);
}

sub expand_hash {
    my $flat = shift;
    my $deep = {};
    my $sep = '.';
 
    for my $name (keys %$flat) {
 
        my ($first, @segments) = split_name($name);
 
        my $box_ref = \$deep->{$first};
        for (@segments) {
            s/\\(.)/$1/g if $sep; # remove escaping
            $$box_ref = {} unless defined $$box_ref;
            unless(ref $$box_ref eq 'HASH') {
                die "Clash for $name=$_";
            }
            $box_ref = \($$box_ref->{$_});
        }
        if(defined $$box_ref) {
            die "Clash for $name value $flat->{$name}"
        }
        $$box_ref = $flat->{$name};
    }
    return $deep;
}

sub _collapse_hash {
    my $deep  = shift;
    my $flat  = shift;
 
    if(ref $deep eq 'HASH') {
        for (keys %$deep) {
            my $name = $_;
            my $sep = "\Q.";
            $name =~ s/([\\$sep])/\\$1/g;
            _collapse_hash($deep->{$_}, $flat, @_, $name);
        }
    } else {
        my $name = join '.', @_;
        $flat->{$name} = $deep;
    }
}

sub collapse_hash {
    my $deep  = shift;
    my $flat  = {};
 
    _collapse_hash($deep, $flat, () );
    return $flat;
}

no Moose;

1;

__END__