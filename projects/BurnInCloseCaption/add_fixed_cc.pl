use strict;
use v5.10.1;
use File::Glob ':glob';

open my $LOG, ">>$0.log";
foreach my $file (bsd_glob('*.avi')) {
	say "$file";
	if ($file =~ /(.+)\.avi/i) {
		my $filename = $1;
		if ($file =~ /(S\d+E\d+)/i) {
			my $episode = $1;
		
			$episode = uc($episode);
			
			my $system1 = qq{"C:\\work\\bin\\MPlayer-athlon-svn-34401\\mencoder.exe" "$filename.avi" -oac copy -ovc lavc -sub "$filename.srt" -subcp cp1250 -subfont-text-scale 2 -o "Series.$episode.avi"};
			
			say {$LOG} "\t$system1";
			
			system($system1);
		}
	}
}
close $LOG;