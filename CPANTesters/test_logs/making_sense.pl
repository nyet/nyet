use strict;
use v5.10.1;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Data::Dumper;

open my $LOG, ">", "$0.tsv";
say {$LOG} "module name\tfail\t\\bfail\\b\tfailed";

my $zip = Archive::Zip->new("201207_P5.012004.zip");
my @members = $zip->membersMatching('.*\.log');
my $i = 0;
FILE:foreach my $member (@members) {
	my @modules;
	
	$i++;
	push @modules, $member->{'fileName'};
	#say {$LOG} $member->{'fileName'};
	my $content = $member->contents(); 
	#say $content;
	
	my $count = 0;
	while ($content =~ /fail/g) {
		$count++;
	}
	push @modules, $count;
	
	$count = 0;
	while ($content =~ /\bfail\b/g) {
		$count++;
	}
	push @modules, $count;
	
	while ($content =~ /failed/g) {
		$count++;
	}
	push @modules, $count;
	#last FILE if $i == 2;	
	
	say {$LOG} join "\t", @modules;
}

#my @sorted;
#foreach my $module (keys %modules) {
#	my $count = $modules{$module};
#	push @{$sorted[$count]}, $module;
#}
#print {$LOG} Dumper \@sorted;
close $LOG;