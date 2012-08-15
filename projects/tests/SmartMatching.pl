#!/usr/bin/perl

use warnings;
use strict;

use 5.010;

say "Checking the number <$ARGV[0]>";

given( $ARGV[0] ) {
	when( ! /^\d+$/ ) { say "Not a number!" }
       
   say "exit"; 
}
