use strict;
use v5.10.1;
use File::Glob ':glob';
use Win32::DriveInfo;
use File::Path;
# to use as fully automated script
# 1. email/notification function is deployed

my $loglevel = 1;

open my $LOG, ">>$0.log";
say {$LOG} time;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon++;
$mon = "0$mon" if length($mon) == 1;
say {$LOG} "$year$mon";

foreach my $file (bsd_glob('*')) {
	if ((-d $file) && ($file =~ /^\d{6}_/) && ($file !~ /^$year$mon/)) {
		my $TotalNumberOfFreeBytes = (Win32::DriveInfo::DriveSpace('C:'))[6];
		
		if ($TotalNumberOfFreeBytes > 200_000_000) {
			my $status = 0;
			say {$LOG} "Archive folder: $file";
			my $cmd = qq{"C:\\Program Files\\7-Zip\\7z.exe" a $file.zip $file\ |};
			say {$LOG} "  cmd:$cmd";
			
			open my $CMDFH, $cmd;
			while (my $line = <$CMDFH>) {
				print {$LOG} $line if $loglevel == 4;
				
				if ($line =~ /Everything is Ok/) {
					$status = 1;
				}
			}
			close $CMDFH;
			
			if ($status) {
				say {$LOG} "Delete folder: $file";
				rmtree($file, 1, 1);		
			}
		}
		else {
			say {$LOG} "Free space is less than 200MB ($TotalNumberOfFreeBytes)";
		}
	}
}
close $LOG;