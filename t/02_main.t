#!/usr/bin/perl

# Simple tests for a simple module
use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 17;
use Test::Warnings 0.005 qw( :no_end_test warning );

# Define a class
SCOPE: {
	eval "
	package Foo;

	use Object::Tiny qw{ foo bar };
	";
	ok( ! $@, 'Created package without error' );
}

# Create a trivial object
SCOPE: {
	my $empty = Foo->new;
	isa_ok( $empty, 'Foo' );
	isa_ok( $empty, 'Object::Tiny' );
	is( scalar( keys %$empty ), 0, 'Empty object is empty' );
}

# Create a real object
SCOPE: {
	my $object = Foo->new( foo => 1, bar => 2, baz => 3 );
	isa_ok( $object, 'Foo' );
	isa_ok( $object, 'Object::Tiny' );
	is( scalar( keys %$object ), 3, 'Object contains expected elements' );
	is( $object->foo, 1, '->foo ok' );
	is( $object->bar, 2, '->bar ok' );
	eval {
		$object->baz;
	};
	ok( $@, '->baz returns an error' );
	is( $object->{baz}, 3, '->{baz} does contain value' );
	eval {
		$object->bar(5);
	};
	ok( $@, '->bar(5) returns an error' );
	is( $object->bar, 2, '->bar still ok' );
  like( warning { Foo->new( foo => 1, 'bar' ) }, qr/\AOdd number/, 'Warning raised: incomplete constructor params' );
  like( warning { Foo->new( undef, 1, bar => 2 ) }, qr/uninitialized value/, 'Warning raised: undefined param name' );
}

# Trigger the constructor exception
SCOPE: {
	eval "package Bar; use Object::Tiny 'bad thing';";
	ok( $@ =~ /Invalid accessor name/, 'Got expected error' );
	eval "package Baz; use Object::Tiny 'new';";
	ok( $@ =~ /Invalid accessor name 'new'/, 'Got expected error' );
}
