package Test::MooseX::Validation::Doctypes::Simple;

use Moose;
use MooseX::Validation::Doctypes;

doctype 'Person' => as {
    id       => 'Str', 
    name     => 'Str', 
    title    => 'Str'
};

doctype 'Location' => as {
    id       => 'Str', 
    city     => 'Str',
    state    => 'Str',
    country  => 'Str',
    zipcode  => 'Int'
};

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__