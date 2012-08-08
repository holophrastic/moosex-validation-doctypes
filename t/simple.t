#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Validatable::Simple;

my $simple = Test::Validatable::Simple->new;

is_deeply($simple->list_doctype('Person'), {
    id    => "Str",
    name  => "Str",
    title => "Str"
}, '... Person doctype is returned correctly');

is_deeply($simple->list_doctype('Location'), {
    id     => "Str",
    city   => "Str",
    state  => "Str",
    country => "Str",
    zipcode => "Int"
}, '... Location doctype is returned correctly');

is(0, $simple->validate_doctype('Person', {
    id => '17382-QA',
    name => 'Bob',
    title => 'CIO'
}), '... Validation returns a 0 on a correct value for Person');

is_deeply({ extra_data => { favorite_food => 'ice cream' } },
    $simple->validate_doctype('Person', {
        id => '17382-QA',
        name => 'Bob',
        title => 'CIO',
        favorite_food => 'ice cream'
    }),
'... Validation returns extra data that is not defined by the object');

is_deeply({ errors => { title => "invalid value 'undef' for type 'title'" } },
    $simple->validate_doctype('Person', {
        id => '17382-QA',
        name => 'Bob'
    }),
'... Validation returns a hash on a missing value for Person');

is_deeply({ errors => { zipcode => "invalid value 'ABCDEF' for type 'zipcode'" } },
    $simple->validate_doctype('Location', {
        id       => 'My House', 
        city     => 'Anytown',
        state    => 'IL',
        country  => 'USA',
        zipcode  => 'ABCDEF'
    }),
'... Validation returns a hash on a bad value for Location');

done_testing;
