open TARGET, ">AddPolicy1.c";
open FILE, "AddPolicy.c";
while (my $line = <FILE>) {
	$line =~ s/, +$/,/;
	print TARGET $line;
}
close FILE;
close TARGET;