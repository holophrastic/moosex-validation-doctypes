#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::MooseX::Validation::Doctypes::Complex;

my $complex = Test::MooseX::Validation::Doctypes::Complex->new;

is_deeply($complex->list_doctype('Location'), {
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
}, '... Location doctype is returned correctly');


is(0, $complex->validate_doctype('Location', {
    id       => '14931-FL-53', 
    name     => 'My House', 
    location => {
        address => {
            address1    => '123 Any St',
            city        => 'Anytown',
            country     => 'USA',
            postal_code => '00100',
            address2    => 'Apt Q',
            address5    => 'knock on the back door',
            state       => 'IL',
        },
        coordinates => {
            lon => '38',
            lat => '57',
        }
    },
    contact => {
        phone   => '867-5309',
        support => 'anelson@cpan.org',
        web     => URI->new('https://metacpan.org/author/ANELSON'),
        email   => 'anelson@cpan.org',
    },
    i18n => {
        default_currency     => 'USD',           
        default_locale       => 'en',           
        available_currencies => [ 'USD', 'CAD', 'EUR' ], 
        available_locales    => [ 'en' ] 
    }
}), '... Validation returns a 0 on a correct value for Location');

is_deeply({
    errors => {
        contact => {
            email => "invalid value 'anelson at cpan.org' for type 'contact.email'"
        },
        i18n => {
            available_currencies => "invalid value '[dolla dolla bill,CAD,EUR]' for type 'i18n.available_currencies'",
            default_currency     => "invalid value 'undef' for type 'i18n.default_currency'"
        },
        location => {
            coordinates => {
                lon => "invalid value '38q' for type 'location.coordinates.lon'"
            }
        }
    }
},
$complex->validate_doctype('Location', {
    id       => '14931-FL-53',
    name     => 'My House',
    location => {
        address => {
            address1    => '123 Any St',
            city        => 'Anytown',
            country     => 'USA',
            postal_code => '00100',
            address2    => 'Apt Q',
            address5    => 'knock on the back door',
            state       => 'IL',
        },
        coordinates => {
            lon => '38q',
            lat => '57',
        }
    },
    contact => {
        phone   => '867-5309',
        support => 'anelson@cpan.org',
        web     => URI->new('https://metacpan.org/author/ANELSON'),
        email   => 'anelson at cpan.org',
    },
    i18n => {
        default_locale       => 'en',
        available_currencies => [ 'dolla dolla bill', 'CAD', 'EUR' ],
        available_locales    => [ 'en' ]
    }
}), '... Validation returns a 0 on a correct value for Location');

done_testing;
