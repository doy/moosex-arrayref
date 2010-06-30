#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Scalar::Util qw(reftype);

{
    package Foo;
    use Moose;
    use MooseX::ArrayRef;

    has foo => (is => 'rw');
    has bar => (is => 'ro', lazy_build => 1);
    sub _build_bar { 'BAR' }
}

my $foo = Foo->new;
is(reftype($foo), 'ARRAY', "got an array instance");
isa_ok($foo, 'Foo');
ok(!$foo->has_bar, "bar not initialized yet");
is($foo->bar, 'BAR', "lazy-built properly");
ok($foo->has_bar, "bar initialized now");
is($foo->foo, undef, "foo not initialized yet");
$foo->foo('FOO');
is($foo->foo, 'FOO', "foo initialized now");
my @contents = @$foo;
is_deeply(\@$foo, ['FOO', 'BAR'], "got the right instance data");

{
    package Bar;
    use Moose;
    extends 'Foo';

    has baz => (is => 'rw');
}

my $bar = Bar->new;
is(reftype($bar), 'ARRAY', "got an array instance");
isa_ok($bar, 'Bar');
isa_ok($bar, 'Foo');
ok(!$bar->has_bar, "bar not initialized yet");
is($bar->bar, 'BAR', "lazy-built properly");
ok($bar->has_bar, "bar initialized now");
is($bar->foo, undef, "foo not initialized yet");
$bar->foo('FOO');
is($bar->foo, 'FOO', "foo initialized now");
is($bar->baz, undef, "baz not initialized yet");
$bar->baz('BAZ');
is($bar->baz, 'BAZ', "baz initialized now");
is_deeply(\@$bar, ['FOO', 'BAR', 'BAZ'], "got the right instance data");

done_testing;
