use strict;
use File::Path;
use Net::SSH::Perl;
use Net::SSH::Perl::Constants qw( :msg );
use Time::HiRes qw( gettimeofday tv_interval );
################################################################################
# TODO: 
# 1. figure out /usr/local/logs/trax logs
my $currentDateString = dateFileString();
#my $hostname = 'ijtcap148.ngs.fnf.com';
#my $hostname = 'ijtcap149.ngs.fnf.com';

my %archived;
{
	open ARCHIVED, "ARCHIVED.log";
	while (my $line = <ARCHIVED>) {
		chomp $line;
		$archived{$line} = 1;
	}
	close ARCHIVED;
}

my $log_file = "backup.log";
open my $LOG, ">$log_file";
close $LOG;

my @appservers = qw(
	lltcap148.fnf.com
	lltcap149.fnf.com
	lltcap150.fnf.com
);
foreach my $hostname (@appservers) {
	if (1) { # /w70p/App-JTCTRAXLT/logs/trax-b
		my @files;
		open my $LOG, ">>$log_file";
		print {$LOG} "cmd:ls -At /w70p/App-LTCTRAX/logs/trax*/*.log\n";
		open my $CMD, "C:\\work\\bin\\plink.exe -ssh lsusanto\@$hostname -2 -i C:\\work\\data\\lsusanto.ppk -m C:\\work\\data\\appsrv_log_files_was7_prod.txt |";
		while (my $file = <$CMD>) {
			print {$LOG} "cmd:ls -At /w70p/App-LTCTRAX/logs/trax*/*.log\n";
			chomp $file;
			push @files, $file;
			#print "$file\n";
		}
		close $CMD;
		
		my $i=0;
		foreach my $file (@files) {
			my $dirName = "";
			if ($file =~ /\/(trax.+?)\//) {
				$dirName = $1;
			}
				
			if ($file =~ /\/([^\/\\]+_\d+\.\d+\.\d+_\d+\.\d+\.\d+\.log)/) {
				my $filename = $1;
				$filename =~ s/\.log$/.gz/;
				print {$LOG} "$i:$hostname:$file\n";
				if (!exists $archived{"$hostname:$file"}) {
					if (!-d "$hostname/$dirName") {
						mkpath("$hostname/$dirName");
						print {$LOG} "mkpath('$hostname/$dirName');\n";
					}
					print {$LOG} "archive the file\n";
					print {$LOG} "filename:$filename\n";
					
					my $t0 = [gettimeofday];
					my $outputFile = "$hostname/$dirName/$filename";
					print {$LOG} "outputFile:$outputFile\n";
					open TEMP, ">$outputFile";
					binmode TEMP;
					{
						local $/ = undef;
						open my $CMD, "C:\\work\\bin\\plink.exe -ssh lsusanto\@$hostname -2 -i C:\\work\\data\\lsusanto.ppk \"gzip -9 -c $file\" |";
						binmode $CMD;
						#gzip -9 -c /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax/trace_09.09.12_19.48.41.log
						while (my $line = <$CMD>) {
							print TEMP $line;
						}
						close $CMD;
					}
					close TEMP;
					my $elapsed = tv_interval ( $t0, [gettimeofday]);
					my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($outputFile);
					open  PERF, ">>backup.perf.log";
					print PERF timeStampString()."\t$file\t$elapsed\t$size\n";
					close PERF;
					print {$LOG} "Downloaded $file in $elapsed\n";
					
					$archived{"$hostname:$file"} = 1;
				}
			}
			elsif ($file =~ /\/([^\/\\]+\.log)/) {
				my $filename = $1;
				$filename =~ s/\.log$/.gz/;
				print {$LOG} "$i:$hostname:$file\n";
				if (!exists $archived{"$hostname:$file"}) {
					if (!-d "$hostname/$dirName") {
						mkpath("$hostname/$dirName");
						print {$LOG} "mkpath('$hostname/$dirName');\n";
					}
					print {$LOG} "copy the file\n";
					print {$LOG} "filename:$filename\n";
					
					my $t0 = [gettimeofday];
					my $outputFile = "$hostname/$dirName/$filename";
					print {$LOG} "outputFile:$outputFile\n";
					open TEMP, ">$outputFile";
					binmode TEMP;
					{
						local $/ = undef;
						open my $CMD, "C:\\work\\bin\\plink.exe -ssh lsusanto\@$hostname -2 -i C:\\work\\data\\lsusanto.ppk \"gzip -9 -c $file\" |";
						binmode $CMD;
						#gzip -9 -c /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax/trace.log
						while (my $line = <$CMD>) {
							print TEMP $line;
						}
						close $CMD;
					}
					close TEMP;
					my $elapsed = tv_interval ( $t0, [gettimeofday]);
					my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($outputFile);
					open  PERF, ">>backup.perf.log";
					print PERF timeStampString()."\t$file\t$elapsed\t$size\n";
					close PERF;
					print {$LOG} "Downloaded $file in $elapsed\n";
				}
			}
			$i++;
		}
		close $LOG;
	}
}

{
	open ARCHIVED, ">ARCHIVED.log";
	foreach my $line (sort keys %archived) {
		print ARCHIVED "$line\n";
	}
	close ARCHIVED;
}


sub dateFileString {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon++;
	$year+=1900;
	$year = substr $year, 2, 2;
	$mon = "0$mon" if (length $mon == 1);
	$mday = "0$mday" if (length $mday == 1);
	$sec = "0$sec" if (length $sec == 1);
	$min = "0$min" if (length $min == 1);
	$hour = "0$hour" if (length $hour == 1);
	return "$year.$mon.$mday";
}

sub timeStampString {
	my ($TIME) = @_;
	if (defined $TIME) {
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($TIME);
		$mon++;$year+=1900;
		$mon = "0$mon" if (length $mon == 1);
		$mday = "0$mday" if (length $mday == 1);
		$sec = "0$sec" if (length $sec == 1);
		$min = "0$min" if (length $min == 1);
		$hour = "0$hour" if (length $hour == 1);
		return "$year$mon$mday"."_$hour$min$sec";
	}
	else {
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$mon++;$year+=1900;
		$mon = "0$mon" if (length $mon == 1);
		$mday = "0$mday" if (length $mday == 1);
		$sec = "0$sec" if (length $sec == 1);
		$min = "0$min" if (length $min == 1);
		$hour = "0$hour" if (length $hour == 1);
		return "$year$mon$mday"."_$hour$min$sec";
	}
	return undef;
}

__DATA__
ls -At /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax/*.log

istat /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax/trace.log
Inode 62204 on device 10/13     File
Protection: rw-rw-r--
Owner: 10045(trax)              Group: 208(wasadmin)
Link count:   1         Length 5215059 bytes

Last updated:   Sat Jul 31 20:17:34 CDT 2010
Last modified:  Thu Jan 14 12:08:50 CST 2010
Last accessed:  Thu Aug  5 19:22:18 CDT 2010


gzip -9 -c usr/IBMIHS/logs/access_log > access_log.ictcap181.gz



		