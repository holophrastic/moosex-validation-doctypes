package Test::Validatable::Complex;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use MooseX::Types::URI   qw[ Uri ];
use MooseX::Types::Email qw[ EmailAddress ];

use Locale::Language   ();
use Locale::Currency   ();
use Number::Phone::US  ();

use Validatable;

subtype 'CurrencyCode' => as 'Str' => where { Locale::Currency::code2currency( $_ )    || undef };
subtype 'LocaleCode'   => as 'Str' => where { Locale::Language::code2language( $_ )    || undef };
subtype 'PhoneNumber'  => as 'Str' => where { Number::Phone::US::is_valid_number( $_ ) || undef };

doctype 'Location' => as {
    id       => 'Str', 
    name     => 'Str',
    location => {
        address => {
            address1    => 'Str',
            city        => 'Str',
            country     => 'Str',
            postal_code => 'Str',
            address2    => 'Maybe[Str]',
            address3    => 'Maybe[Str]',
            address4    => 'Maybe[Str]',
            address5    => 'Maybe[Str]',
            state       => 'Maybe[Str]',
        },
        coordinates => {
            lon => 'Num',
            lat => 'Num',
        }
    },
    contact => {
        phone   => 'PhoneNumber',
        fax     => 'Maybe[PhoneNumber]',
        support => 'Maybe[PhoneNumber | MooseX::Types::URI::Uri | MooseX::Types::Email::EmailAddress]',
        web     => 'Maybe[MooseX::Types::URI::Uri]',
        email   => 'Maybe[MooseX::Types::Email::EmailAddress]',
    },
    i18n => {
        default_currency     => 'CurrencyCode',           
        default_locale       => 'LocaleCode',           
        available_currencies => 'ArrayRef[CurrencyCode]', 
        available_locales    => 'ArrayRef[LocaleCode]', 
    }
};

__PACKAGE__->meta->make_immutable;


1;
