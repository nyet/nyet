my $record_section = 0;
my @section;
open FILE, "collections.txt";
while (my $line = <FILE>) {
	if ($line =~ /^\[Copied\]/) {
		$record_section = 1;
		$line = <FILE>;
	}
	elsif ($line =~ /^\[/) {
		$record_section = 0;
	}
	
	if ($record_section) {
		chomp $line;
		if ($line ne "") {
			push @section, $line;
		}
	}
}
close FILE;


open  TARGET, ">$0.log";
say   TARGET join("\n", sort(@section));
close TARGET;