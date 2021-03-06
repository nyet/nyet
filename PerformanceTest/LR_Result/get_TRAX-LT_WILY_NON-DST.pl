use strict;
use Data::Dumper;
use File::Basename;
use File::Path;
use File::Glob ':glob';
use Time::Local;

my %start_time;
my $start_tick = 0;
my %end_time;
my $end_tick = 0;
{
	local $/ = undef;
	open FILE, "./Analysis/Report/summary.html";
	my $whole = <FILE>;
	if ($whole =~ /Period: (\d+\/\d+\/\d+\s+\d+:\d+:\d+) - (\d+\/\d+\/\d+\s+\d+:\d+:\d+)\</) {
		my $start = $1;
		my $end = $2;
		print "start: $start\nend:   $end\n";
		if ($start =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/) {
			print "start: $start, mon: $1, day: $2, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $2, $1-1, $3);
			my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
			$start_tick = $time + 3600;
			#$start_tick = $time - 3600;		# 10.213.210.31
			#$start_tick = $time - 3600;	# convert to CT
			#$start_tick = $time - 3*3600;	# convert to PT
			$start_tick -= 300;

			($start_time{sec},$start_time{min},$start_time{hour},
			 $start_time{mday},$start_time{mon},$start_time{year},
			 $start_time{wday},$start_time{yday},$start_time{isdst}) = localtime($start_tick);
			$start_time{mon}++;
			$start_time{year}+=1900;
		}
		if ($end =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/) {
			print "start: $start, mon: $1, day: $2, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $2, $1-1, $3);
			my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
			$end_tick = $time + 3600;
			#$end_tick = $time - 3600;		# 10.213.210.31
			#$end_tick = $time - 3600;	# convert to CT
			#$end_tick = $time - 3*3600;	# convert to PT
			$end_tick += 300;

			($end_time{sec},$end_time{min},$end_time{hour},
			 $end_time{mday},$end_time{mon},$end_time{year},
			 $end_time{wday},$end_time{yday},$end_time{isdst}) = localtime($end_tick);
			$end_time{mon}++;
			$end_time{year}+=1900;
		}
	}
	close FILE;
}

print Dumper \%start_time;
print Dumper \%end_time;


#my $start_str = "$start_time{'year'}/$start_time{'mon'}/$start_time{'mday'} $start_time{'hour'}:$start_time{'min'}:$start_time{'sec'}";
#my $end_str   = "$end_time{'year'}/$end_time{'mon'}/$end_time{'mday'} $end_time{'hour'}:$end_time{'min'}:$end_time{'sec'}";

my $start_str = "$start_time{'year'}-$start_time{'mon'}-$start_time{'mday'} $start_time{'hour'}:$start_time{'min'}:$start_time{'sec'}";
my $end_str   = "$end_time{'year'}-$end_time{'mon'}-$end_time{'mday'} $end_time{'hour'}:$end_time{'min'}:$end_time{'sec'}";


print "start: $start_str\n";
print "stop:  $end_str\n";
print "Go ahead?";my $wait=<>;

my %skim = (
	'DB' => {
		agents => '.*ijtcdb15[89].*EPAgent.*',
		metrics => [
			'.*VM.CPU.*',
			'.*VM.Memory.*',
			'.*VM.Kernel Threads.*',
			'.*VM.Faults.*',
			'.*VM.Paging.*',
			'.*GC Heap.*',
			'.*netstat.(Total|ESTABLISHED).*',
			#'.*Free Disk Space.*',
		],
	},
	'AP', => {
		agents => '.*ijtcap14[89].*EPAgent.*',
		metrics => [
			'.*VM.CPU.*',			# WAS6
			'.*VM.Memory.*',		# WAS6
			'.*VM.Kernel Threads.*',	# WAS6
			'.*VM.Faults.*',		# WAS6
			'.*VM.Paging.*',		# WAS6
			'.*GC Heap.*',			# WAS6/7
			'.*netstat.(Total|ESTABLISHED).*', # WAS6/7
			#'.*Free Disk Space.*',
		],
	},
	'WS', => {
		agents => '.*ijtcap14[12].*EPAgent.*',
		metrics => [
			'.*VM.CPU.*',			# WAS6
			'.*VM.Memory.*',		# WAS6
			'.*VM.Kernel Threads.*',	# WAS6
			'.*VM.Faults.*',		# WAS6
			'.*VM.Paging.*',		# WAS6
			'.*GC Heap.*',			# WAS6/7
			'.*netstat.(Total|ESTABLISHED).*', # WAS6/7
			#'.*Free Disk Space.*',
		],
	},
);

mkpath("Perfmon2_NON-DST");
my $time = " between $start_str and $end_str";
#my $time = " between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s";
open my $LOG, ">getWILY_NON-DST.log";
foreach my $type (sort keys %skim) {
	print {$LOG} "server type: $type\n";
	my $agents = $skim{$type}{agents};
	print {$LOG} "	agent string: $agents\n";
	foreach my $metric (@{$skim{$type}{metrics}}) {
		print {$LOG} "	metric: $metric\n";
		(my $metricname = $metric) =~ s/(\W)/_/g;
		$metricname =~ s/\s/_/g;
		my $cmdLine = qq{java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=xxx -Dport=5001 -jar "../CLWorkstation.jar" get historical data from agents matching \"$agents\" and metrics matching \"$metric\" $time > Perfmon2_NON-DST/rawdata.$type.$metricname.csv};
		print {$LOG} "		$cmdLine\n";

		use Time::HiRes qw( gettimeofday tv_interval );
		my $t0 = [gettimeofday];
		print "execute: $cmdLine\n";
		system "$cmdLine";
		my $elapsed = tv_interval ( $t0, [gettimeofday]);

		
		print {$LOG} "		Elapsed time: $elapsed\n";

	}
}
close $LOG;


