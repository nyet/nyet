use URI::Escape;

my $eventid;
my $report;
my $analysis_flag;
open  TARGET, ">$0.log";

my $record = 0;
my $VIEWSTATE;
my $record_VIEWSTATE = 0;
open FILE, "../data/CodeGenerationLog.txt";
#Web Recorder version : 11.0.9409.0 
while (my $line = <FILE>) {
	if ($line =~ /Response Body For Transaction With Id (\d+)/) {
		$eventid = $1;
		$analysis_flag = 1;
	}
	elsif ($line =~ /Response Body For Transaction With Id $eventid Ended/) {
	}
	elsif ($line =~ /Add Event For Transaction With Id $eventid/) {
		$line = <FILE>;
		chomp $line;
		$line =~ s/^\s+//;
	}
	elsif ($line =~ /Add Event For Transaction With Id $eventid Ended/) {
		#this is nonsense.
	}
	if ($analysis_flag) {
		if ($line =~ /id="__VIEWSTATE" value="(.+?)"/) {
			#$report .= $eventid.":".length($1)."\n";
			
			print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
		if ($line =~ /\|__VIEWSTATE\|(.+?)\|/) {
			#$report .= $eventid.":".length($1)."\n";
			
			print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
	}
	
	if ($line =~ /web_custom_request\("CommitmentWorksheet.aspx_7"/) {
		$record = 1;
	}
	elsif ($line =~ /LAST\);/) {
		$record = 0;
	}
	if ($record) {
		if ($line =~ /__VIEWSTATE=(.+)"/) {
			$VIEWSTATE = $1;
			$record_VIEWSTATE = 1;
		}
		elsif ($record_VIEWSTATE && $line =~ /\s+"([^&]+)"/) {
			$VIEWSTATE .= $1;
		}
		elsif ($record_VIEWSTATE && $line =~ /\s+"(.+?)&/) {
			$VIEWSTATE .= $1;
			$record_VIEWSTATE = 0;
		}
	}
}


while (my $line = <FILE>) {
	if ($line =~ /CommitmentWorksheet.aspx_4/) {
		say TARGET "	CommitmentWorksheet.aspx_4";
	}
	
	if ($line =~ /^\*\*\*\s+\[tid=\w+\t(\w+\t\d+)\]\s+Receiving response from/) {
		$eventid = $1;
		$analysis_flag = 1;
		
		say TARGET "eventid($eventid): $analysis_flag";
	}
	elsif ($line =~ /^\*\*\*\s+\[tid=\w+\t(\w+\t\d+)\]\s+(Recording|Replacing) Function/) {
		#say TARGET "Replacing Function $1";
		$eventid = $1;
		$line = <FILE>;
		$line = <FILE>;
		chomp $line;
		$line =~ /"(.+?)"/;
		$VIEWSTATES{$eventid}{function} = $1;
		
		say TARGET "	function($eventid):$VIEWSTATES{$eventid}{function}";
		
		#my $len =  length($VIEWSTATES{$eventid}{VIEWSTATE});
		#say TARGET $eventid.":VIEWSTATE:".length($VIEWSTATES{$eventid}{VIEWSTATE});
		#(my $evid = $eventid) =~ s/\t//;
		#open  VIEWSTATEFH, ">$evid-$len.txt";
		#say   VIEWSTATEFH $VIEWSTATES{$eventid}{function};
		#say   VIEWSTATEFH "length: $len";
		#say   VIEWSTATEFH $VIEWSTATES{$eventid}{VIEWSTATE};
		#close VIEWSTATEFH;
		
		$analysis_flag = 0;
	}
	elsif ($line =~ /^\*\*\*/) {
		say TARGET "SKIP";
		$analysis_flag = 0;
	}
	
	
	if ($analysis_flag) {
		if ($line =~ /id=\\"__VIEWSTATE\\"\s+value=\\"(.+?)"/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} = $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 1;
			#$VIEWSTATE = $1;
			#$record_VIEWSTATE = 1;
			#say TARGET "	record_VIEWSTATE($record_VIEWSTATE):start";
			
			#$report .= $eventid.":".length($1)."\n";
			#print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
		elsif ($line =~ /id=\\"__VIEWSTATE\\"\s+value=\\"(.+?)\\"/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} = $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 0;
			#$VIEWSTATE = $1;
			#$record_VIEWSTATE = 0;
			print TARGET $eventid.":".length($VIEWSTATES{$eventid}{VIEWSTATE})."\n";
			
			#$report .= $eventid.":".length($1)."\n";
			#print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
		elsif ($line =~ /\|__VIEWSTATE\|(.+?)"/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} = $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 1;
			#$VIEWSTATE = $1;
			#$record_VIEWSTATE = 1;
			#say TARGET "	record_VIEWSTATE($record_VIEWSTATE):start";
			
			#$report .= $eventid.":".length($1)."\n";
			#print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
		elsif ($line =~ /\|__VIEWSTATE\|(.+?)\|/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} = $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 0;
			#$VIEWSTATE = $1;
			#$record_VIEWSTATE = 0;
			print TARGET $eventid.":".length($VIEWSTATES{$eventid}{VIEWSTATE})."\n";
			
			#$report .= $eventid.":".length($1)."\n";
			#print TARGET $eventid.":".length($1)."\n";
			#print TARGET $1."\n";
		}
		elsif ($VIEWSTATES{$eventid}{record_VIEWSTATE} && $line =~ /^"(.+?)\|/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} .= $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 0;
			#$VIEWSTATE .= $1;
			#$record_VIEWSTATE = 0;
			#say TARGET "	record_VIEWSTATE($record_VIEWSTATE):end";
			
			#my $len =  length($VIEWSTATES{$eventid}{VIEWSTATE});
			#say TARGET $eventid.":VIEWSTATE:$len";
			#(my $evid = $eventid) =~ s/\t//;
			#open VIEWSTATEFH, ">$evid-$len.txt";
			#say VIEWSTATEFH $VIEWSTATES{$eventid}{function};
			#say VIEWSTATEFH "length: $len";
			#say VIEWSTATEFH $VIEWSTATES{$eventid}{VIEWSTATE};
			#close VIEWSTATEFH;
			
		}
		elsif ($VIEWSTATES{$eventid}{record_VIEWSTATE} && $line =~ /^"(.+?)\\"/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} .= $1;
			$VIEWSTATES{$eventid}{record_VIEWSTATE} = 0;
			#$VIEWSTATE .= $1;
			#$record_VIEWSTATE = 0;
			#say TARGET "	record_VIEWSTATE($record_VIEWSTATE):end";
			
			#my $len =  length($VIEWSTATES{$eventid}{VIEWSTATE});
			#say TARGET $eventid.":VIEWSTATE:".length($VIEWSTATES{$eventid}{VIEWSTATE});
			#(my $evid = $eventid) =~ s/\t//;
			#open VIEWSTATEFH, ">$evid-$len.txt";
			#say VIEWSTATEFH $VIEWSTATES{$eventid}{function};
			#say VIEWSTATEFH "length: $len";
			#say VIEWSTATEFH $VIEWSTATES{$eventid}{VIEWSTATE};
			#close VIEWSTATEFH;
		}
		elsif ($VIEWSTATES{$eventid}{record_VIEWSTATE} && $line =~ /^"(.+?)"/) {
			$VIEWSTATES{$eventid}{VIEWSTATE} .= $1;
			#$VIEWSTATE .= $1;
			#say TARGET "	record_VIEWSTATE($record_VIEWSTATE):all";
		}
		
	}
}
close FILE;

foreach my $ev (keys %VIEWSTATES) {
	my $len =  length($VIEWSTATES{$ev}{VIEWSTATE});
	(my $evid = $ev) =~ s/\t//;
	open VIEWSTATEFH, ">$evid-$len.txt";
	say VIEWSTATEFH $VIEWSTATES{$ev}{function};
	say VIEWSTATEFH "length: $len";
	say VIEWSTATEFH $VIEWSTATES{$ev}{VIEWSTATE};
	close VIEWSTATEFH;
}
#print TARGET $report;
print TARGET "--------------------------------------------------------------------------------\n";
print TARGET length($VIEWSTATE)."\n";
print TARGET uri_unescape($VIEWSTATE);
close TARGET;




