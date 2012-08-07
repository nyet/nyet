use strict;
use File::Copy;

my $scriptname = "tt";
my $starttime = "";
open EXECLOG, "output.txt";
while (my $line = <EXECLOG>) {
	if ($line =~ /[\\\/]+([^\\\/]+?)[\\\/]+default.cfg/) {
		$scriptname = $1;
	}
	elsif ($line =~ /Virtual User Script started at : (.+)/) {
		#2010-04-28 08:02:48
		$starttime = $1;
		print "starttime: $starttime\n";
		$starttime =~ s/[\-\:]//g;
		$starttime =~ s/\s/_/g;
		print "starttime: $starttime\n";
	}
}
close EXECLOG;

my $hang = 0;
my $timestamp = timeStampString();
my $time = time;
if ($scriptname eq 'tt') {
	print "Script name is not found, using tt instead\n";
	$hang = 1;
}
print "starttime: $starttime\n";
if (!$starttime) {
	print "Start time is not found, using time stamp($timestamp) instead\n";
	$hang = 1;
}


my $status = copy("output.txt", "../$scriptname.output.$starttime.$time.txt");
if (!$status) {
	print "copy(\"output.txt\", \"../$scriptname.output.$starttime.$time.txt\");\n";
	print "problem while copy: $!\n";
	$hang = 1;
}


if ($hang) {
	print "wait, shit happened";
	my $this = <>;
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