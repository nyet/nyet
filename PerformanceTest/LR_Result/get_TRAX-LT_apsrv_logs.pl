use strict;
use File::Path;
use Net::SSH::Perl;
use Net::SSH::Perl::Constants qw( :msg );
use Time::HiRes qw( gettimeofday tv_interval );
################################################################################
# TODO: 
# 1. figure out /usr/local/logs/trax logs
# 2. zip before download?
my $currentDateString = dateFileString();
my $hostname = 'zzz.com';
my %option = (
	debug    => 1,
	user     => 'xxx',
	password => 'xxx',
);

open  PERF, ">getTRAX-LTLogs.perf.log";
close PERF;

open FILE, ">111983732784378423.log";
if (1) {
	# logs in /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax(.*)
	my @dirs = (
		'/usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax', 
		'/usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax-1', 
		'/usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax-2', 
		'/usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax-3'
	);
	foreach my $dir (@dirs) {
		my @this = split /\//, $dir;
		my $dirName = $this[$#this];
		
		my $sshClient = Net::SSH::Perl->new($hostname, %option);
		$sshClient->login('xxx', 'xxx');
		
		my ($lsout, $lserr, $lsexit) = $sshClient->cmd("cd $dir\nls -al");
		print FILE "cmd:cd $dir\nls -al\n";
		print FILE "exit:$lsexit\n";
		print FILE "out:$lsout\n";
		print FILE "err:$lserr\n";
		
		my $outputFile = "";
		$sshClient->register_handler(SSH_SMSG_STDOUT_DATA, sub {
			my($ssh, $packet) = @_;
			my $str = $packet->get_str;
			
			open  my $OUT, ">>$outputFile";
			print {$OUT} $str;
			close $OUT;
		});
		my $errStr = "";
		$sshClient->register_handler(SSH_SMSG_STDERR_DATA, sub {
			my($ssh, $packet) = @_;
			my $str = $packet->get_str;
			
			$errStr .= $str;
		});
		
		while ($lsout =~ /\s+(\S+log)$/mg) {
			my $filename = $1;
			print "file:$filename, $currentDateString\n";
			if ($filename =~ /http_access/) {
				print "do not copy this file:$filename\n";
			}
			elsif ($filename =~ /http_error/) {
				print "do not copy this file:$filename\n";
			}
			elsif ($filename =~ /_\d+\.\d+\.\d+_/) {
				if ($filename =~ /$currentDateString/) {
					mkpath("$hostname/$dirName") if !-d "$hostname/$dirName";
					print "copy this file:$filename\n";
					print FILE "file:$filename\n";
					
					my $t0 = [gettimeofday];
					$outputFile = "$hostname/$dirName/$filename";
					open TEMP, ">$outputFile";
					close TEMP;
					$errStr     = "";
					$sshClient->cmd("cat $dir/$filename");
					if (length $errStr > 0) {
						print FILE "Failed to run cat $dir/$filename, reason: $errStr\n";
					}
					my $elapsed = tv_interval ( $t0, [gettimeofday]);
					
					my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($outputFile);
					open  PERF, ">>getTRAX-LTLogs.perf.log";
					print PERF timeStampString()."\t$dir/$filename\t$elapsed\t$size\n";
					close PERF;
					print FILE "Downloaded $dir/$filename in $elapsed\n";
				}
				else {
					print "do not copy this file:$filename\n";
				}
			}
			else {
				mkpath("$hostname/$dirName") if !-d "$hostname/$dirName";
				print "copy this file:$filename\n";
				print FILE "file:$filename\n";
				
				my $t0 = [gettimeofday];
				$outputFile = "$hostname/$dirName/$filename";
				open TEMP, ">$outputFile";
				close TEMP;
				$errStr     = "";
				$sshClient->cmd("cat $dir/$filename");
				if (length $errStr > 0) {
					print FILE "Failed to run cat $dir/$filename, reason: $errStr\n";
				}
				my $elapsed = tv_interval ( $t0, [gettimeofday]);
				
				my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($outputFile);
				open  PERF, ">>getTRAX-LTLogs.perf.log";
				print PERF timeStampString()."\t$dir/$filename\t$elapsed\t$size\n";
				close PERF;
				print FILE "Downloaded $dir/$filename in $elapsed\n";
			}
		}
	}
}
if (1){
	# get all in /usr/local/logs/trax - for now
	my $sshClient = Net::SSH::Perl->new($hostname, %option);
	$sshClient->login('xxx', 'xxx');
	
	my $dir = '/usr/local/logs/trax';
	(my $dirName = $dir) =~ s/\///;
	$dirName =~ s/[\/\\]/./g;
	my ($lsout, $lserr, $lsexit) = $sshClient->cmd("cd $dir\nls -Alt");
	print FILE "cmd:cd $dir\nls -al\n";
	print FILE "exit:$lsexit\n";
	print FILE "out:$lsout\n";
	print FILE "err:$lserr\n";
	
	my $outputFile = "";
	$sshClient->register_handler(SSH_SMSG_STDOUT_DATA, sub {
		my($ssh, $packet) = @_;
		my $str = $packet->get_str;
		
		open  my $OUT, ">>$outputFile";
		print {$OUT} $str;
		close $OUT;
	});
	my $errStr = "";
	$sshClient->register_handler(SSH_SMSG_STDERR_DATA, sub {
		my($ssh, $packet) = @_;
		my $str = $packet->get_str;
		
		$errStr .= $str;
	});
	while ($lsout =~ /\s+(\S+\.xml.*)$/img) {
		my $filename = $1;
		print "file:$filename\n";
		if ($filename !~ /lck/) {
			mkpath("$hostname/$dirName") if !-d "$hostname/$dirName";
			print "copy this file:$filename\n";
			print FILE "file:$filename\n";
			
			my $t0 = [gettimeofday];
			$outputFile = "$hostname/$dirName/$filename";
			open TEMP, ">$outputFile";
			close TEMP;
			$errStr     = "";
			$sshClient->cmd("cat $dir/$filename");
			if (length $errStr > 0) {
				print FILE "Failed to run cat $dir/$filename, reason: $errStr\n";
			}
			my $elapsed = tv_interval ( $t0, [gettimeofday]);
			
			my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($outputFile);
			open  PERF, ">>getTRAX-LTLogs.perf.log";
			print PERF timeStampString()."\t$dir/$filename\t$elapsed\t$size\n";
			close PERF;
			print FILE "Downloaded $dir/$filename in $elapsed\n";
		}
	}
}
close FILE;





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

