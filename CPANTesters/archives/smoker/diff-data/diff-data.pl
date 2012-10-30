use strict;
use v5.10.1;
my @data;
# reading data file that grows with time, but do not read the previous data.
# e.g.:  reading C:\CPANTesters\reports-sent.db



my $lineNoPrev = 0;
my $lineNo = $lineNoPrev;
open FILE, "data-10.txt";
while(my $line = <FILE>) {
	if ($. <= $lineNoPrev) {
		next ROW;
	}
	else {
		chomp $line;
		push @data, $line;
		$lineNo++;
	}
}
close FILE;

say "data-10: ".$#data;

$lineNoPrev = $lineNo;
$lineNo = $lineNoPrev;
open FILE, "data-20.txt";
ROW:while(my $line = <FILE>) {
	if ($. <= $lineNoPrev) {
		next ROW;
	}
	else {
		chomp $line;
		push @data, $line;
		$lineNo++;
	}
}
close FILE;


use Data::Dumper;
say "data-20: ".$#data;
print Dumper \@data;