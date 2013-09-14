#!/usr/bin/env perl -T

use strict;
use warnings;

use Test::Most tests => 1;

BEGIN {
	use_ok( 'String::TrigramSimilarity' );
}

diag( "Testing String::TrigramSimilarity $String::TrigramSimilarity::VERSION, Perl $], $^X" );
