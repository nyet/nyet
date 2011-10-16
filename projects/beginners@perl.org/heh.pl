use strict;
my %CELL;
my %CELL_TYPE_COUNT;
while (my $line = <DATA>) {
	if ($line =~ /CELL\s+(\d+)\s+(.+?),.+?HEH/) { # take CELL number into $1 and the information after the number (and before the first comma) into $2
		$CELL{$1}{$2}++;
		$CELL_TYPE_COUNT{$2}++;
	}
}

# header
print "CELL,".join(",",sort keys %CELL_TYPE_COUNT)."\n";
# body
foreach my $cellNo (sort keys %CELL) { # you can use map function, but it never sits well on my brain
	print "$cellNo";
	foreach my $info (sort keys %CELL_TYPE_COUNT) {
		if (exists $CELL{$cellNo}{$info}) {
			print ", $CELL{$cellNo}{$info}";
		}
		else {
			print ", 0";
		}
	}
	print "\n";
}


__DATA__
 00 REPT:CELL 20 CDM 1, CRC, HEH
    SUPPRESSED MSGS: 0
    ERROR TYPE: ONEBTS MODULAR CELL ERROR
    SET: DS1-MLG ASSOCIATION CHANGE
    MLG 1 DS1 1,2

 00 REPT:CELL 20 CDM 1, CRC, HEH
    SUPPRESSED MSGS: 0
    ERROR TYPE: ONEBTS MODULAR CELL ERROR
    SET: DS1-MLG ASSOCIATION CHANGE
    MLG 1 DS1 1,2

 00 REPT:CELL 21 CDM 2, CRC, HEH  <- my own test data