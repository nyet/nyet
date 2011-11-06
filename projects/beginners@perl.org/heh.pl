use strict;
my %CELL;
my %CELL_TYPE_COUNT;
my $timestamp;
my $hour;
while (my $line = <DATA>) {
	if ($line =~ m|\d{1,2}/\d{1,2}/\d{2} ((\d{1,2}):\d{1,2}:\d{1,2})|) { #10/17/11 18:25:20 #578030
		$timestamp = $1;
		$hour = $2;
	}
	
	if ($line =~ /CELL\s+(\d+)\s+(.+?),.+?HEH/) { # take CELL number into $1 and the information after the number (and before the first comma) into $2
		if ((17 <= $hour)&&($hour <=21)) {
			$CELL{$hour}{$1}{$2}++;
			$CELL_TYPE_COUNT{$2}++;
		}
	}
}

# header
print "HOUR, CELL,".join(", ",sort keys %CELL_TYPE_COUNT)."\n";
# body
foreach my $hour (sort keys %CELL) { # you can use map function, but it never sits well on my brain
	foreach my $cellNo (sort keys %{$CELL{$hour}}) {
		print "$hour, $cellNo";
		foreach my $info (sort keys %CELL_TYPE_COUNT) {
			if (exists $CELL{$hour}{$cellNo}{$info}) {
				print ", $CELL{$hour}{$cellNo}{$info}";
			}
			else {
				print ", 0";
			}
		}
		print "\n";
	}
}


__DATA__
10/17/11 10:25:20 #578030

 25 REPT:CELL 221 CDM 2, CRC, HEH
    SUPPRESSED MSGS: 0
    ERROR TYPE: ONEBTS MODULAR CELL ERROR
    SET: MLG BANDWIDTH CHANGE
    MLG 1 BANDWIDTH = 1536

      00  00  06  00  00  00  00  00
      00  00  00  00  00  00  00  00
      00  00  00  00

10/17/11 18:25:20 #578031

 25 REPT:CELL 221 CDM 2, CRC, HEH
    SUPPRESSED MSGS: 0
    ERROR TYPE: ONEBTS MODULAR CELL ERROR
    SET: DS1-MLG ASSOCIATION CHANGE
    MLG 1 DS1 1,2

      00  00  00  00  00  00  00  00
      03  00  00  00  01  00  05  05

#my own test data
10/17/11 18:25:20 #578031 
 25 REPT:CELL 220 CDM 1, CRC, HEH
10/17/11 18:25:20 #578031
 25 REPT:CELL 220 CDM 1, CRC, HEH
10/17/11 19:25:20 #578031
 25 REPT:CELL 220 CDM 1, CRC, HEH
