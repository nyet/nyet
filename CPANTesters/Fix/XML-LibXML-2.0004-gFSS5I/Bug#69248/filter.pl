my $whole;
open FILE, "02parse-191.test.log";
open TARGET, ">02parse-191.test.filtered.log";
while (my $line = <FILE>) {
	$line =~ s/C:\/CPANTesters\/Perl5.12.4/P5/g;
	$whole .= $line;
}
$whole =~ s/\n\n/\n/g;
print TARGET $whole;
close TARGET;
close FILE;

open FILE, "02parse-191.test.seleta.log";
open TARGET, ">02parse-191.test.seleta.filtered.log";
while (my $line = <FILE>) {
	$line =~ s/\/usr\/lib\/perl5\/5.8.8/P5\/lib/g;
	$line =~ s/\/usr\/lib64\/perl5\/5.8.8\/x86_64-linux-thread-multi/P5\/lib/g;
	print TARGET $line;
}
close TARGET;
close FILE;