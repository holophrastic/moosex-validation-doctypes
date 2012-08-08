package Test::Validatable::Simple;

use Moose;
use Validatable;

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