use v5.10.1;
my $max = 10;
open FILE, ">data-$max.txt";
for (1..$max) {
	say FILE $_;
}
close FILE;

my $max = 20;
open FILE, ">data-$max.txt";
for (1..$max) {
	say FILE $_;
}
close FILE;