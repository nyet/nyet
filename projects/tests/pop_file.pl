use strict;
use v5.10.1;

open FILE, ">1_EMERGENCY_QUEUE.txt";
for (1..10) {
	say  FILE $_;
}
close FILE;


use Tie::File;
tie my @cmdLines, 'Tie::File', "1_EMERGENCY_QUEUE.txt" or die "Can not open 1_EMERGENCY_QUEUE.txt";

say "shift: ".shift(@cmdLines);
say "pop: ".pop(@cmdLines);




