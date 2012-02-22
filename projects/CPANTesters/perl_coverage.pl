#!/usr/bin/perl
use strict;
use v5.10.1;
use DBI;

my $logfile = "$0.log";

my $perl_version = "P$]";
$perl_version =~ s/\./_/g;
print "perl_version: $perl_version\n";

my @platforms = (
	'P5.012004',
	'P5.010001', 
	'P5.014001',
	#'5.010000',
	#'5.012002',
	#'5.012003',
	#'5.014000'
);

open my $LOG, ">$logfile";
my $running = 1;
while ($running) {
	$running = 0;
	foreach my $platform (@platforms) {
		$platform =~ s/\./_/g;
		#open SQLite database
		my $dbh = DBI->connect("dbi:SQLite:dbname=C:/1working/nyet/projects/CPANTesters/dev.db","","");
		if ($dbh) {
			#say "SELECT filename FROM cpan_test_file WHERE $platform != 1 or $platform is null order by filename";
			my $sth = $dbh->prepare("SELECT filename FROM cpan_test_file WHERE $platform != 1 or $platform is null order by filename");
			$sth->execute();
			if (my $row = $sth->fetchrow_hashref) {
				my $filename = $row->{filename};
				say {$LOG} "$platform:$filename";
				say "$platform:$filename";
				$sth->finish;
				$sth = $dbh->prepare("UPDATE cpan_test_file SET $platform = 1 WHERE filename LIKE '$filename'");
				$sth->execute();
				$running = $running || 1;
			}
			else {
				$running = $running || 0;
			}
			$dbh->disconnect();
		}
	}
}
close $LOG;