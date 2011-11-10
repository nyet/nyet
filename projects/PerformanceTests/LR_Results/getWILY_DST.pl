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
			$start_tick = $time;
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
			$end_tick = $time;
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

use Text::CSV_XS;
my $csv = Text::CSV_XS->new ({
	quote_char          => '"',
	escape_char         => '"',
	sep_char            => ',',
	eol                 => $\,
	always_quote        => 0,
	binary              => 0,
	keep_meta_info      => 0,
	allow_loose_quotes  => 0,
	allow_loose_escapes => 0,
	allow_whitespace    => 0,
	blank_is_undef      => 0,
	verbatim            => 0,
});

my %months = (
 Jan=>1, Feb=>2, Mar=>3, Apr=>4,  May=>5,  Jun=>6, 
 Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12,
 January=>1,  February=>2,  March=>3, 
 April=>4,    May=>5,       June=>6, 
 July=>7,     August=>8,    September=>9, 
 October=>10, November=>11, December=>12,
);

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
		agents => '.*ljtcap14[89].*EPAgent.*',
		metrics => [
			'.*vmstat.Cpu.*',		# WAS7
			'.*vmstat.Memory.*',		# WAS7
			'.*vmstat.Kernel Threads.*',	# WAS7
			'.*vmstat.System.*',		# WAS7
			'.*vmstat.Swap.*',		# WAS7
			'.*GC Heap.*',			# WAS6/7
			'.*netstat.(Total|ESTABLISHED).*', # WAS6/7
			#'.*Free Disk Space.*',
		],
	},
	'WS', => {
		agents => '.*ljtcap14[12].*EPAgent.*',
		metrics => [
			'.*vmstat.Cpu.*',		# WAS7
			'.*vmstat.Memory.*',		# WAS7
			'.*vmstat.Kernel Threads.*',	# WAS7
			'.*vmstat.System.*',		# WAS7
			'.*vmstat.Swap.*',		# WAS7
			'.*GC Heap.*',			# WAS6/7
			'.*netstat.(Total|ESTABLISHED).*', # WAS6/7
			#'.*Free Disk Space.*',
		],
	},
);

my $rawdata_folder = "Perfmon2_DST\\RawData";
mkpath($rawdata_folder);
my $data_folder = "Perfmon2_DST\\Data";
mkpath($data_folder);
my $time = " between $start_str and $end_str";
#my $time = " between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s";
open my $LOG, ">Perfmon2_DST\\getWILY_DST.log";
foreach my $type (sort keys %skim) {
	print {$LOG} "server type: $type\n";
	my $agents = $skim{$type}{agents};
	print {$LOG} "	agent string: $agents\n";
	foreach my $metric (@{$skim{$type}{metrics}}) {
		print {$LOG} "	metric: $metric\n";
		(my $metricname = $metric) =~ s/(\W)/_/g;
		$metricname =~ s/\s/_/g;
		my $rawdata_file = "$rawdata_folder\\rawdata.$type.$metricname.csv";
		my $cmdLine = qq{java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar "../CLWorkstation.jar" get historical data from agents matching \"$agents\" and metrics matching \"$metric\" $time > $rawdata_file};
		print {$LOG} "		$cmdLine\n";
		
		use Time::HiRes qw( gettimeofday tv_interval );
		my $t0 = [gettimeofday];
		print "execute: $cmdLine\n";
		system "$cmdLine";
		my $elapsed = tv_interval ( $t0, [gettimeofday]);
		print {$LOG} "		Elapsed time: $elapsed\n";
		
		open my $RAWFILE, $rawdata_file;
		my $line = <$RAWFILE>;
		$line = <$RAWFILE>;
		my $status  = $csv->parse($line);
		my @header;
		if ($status) {
			foreach my $txt ($csv->fields()) {
				$txt =~ s/^\s+//;
				$txt =~ s/\s+$//;
				push @header, $txt;
			}
			#print "header: ".join("|", @header)."\n";
			#print "wait";<>;
		}
		else {
			die $csv->error_input();
		}
		my $data_file = "$data_folder/$type.$metricname.tsv";
		my %data;
		if ($#header > -1) {
			while ($line = <$RAWFILE>) {
				#print $line;
				#print "wait";<>;
				
				my $status  = $csv->parse($line); 
				if ($status) {
					my @values = $csv->fields();
					
					my $idx = 0;
					my $data_value = "";
					my $metric = "";
					my $value_type = "";
					my $timestamp = "";
					my $timestamp_orig = "";
					
					foreach my $value (@values) {
						if ($header[$idx] eq 'Host') {
							$metric = $value;
							#print "Host: $value\n";
						}
						elsif ($header[$idx] eq 'Resource') {
							$metric .= "_$value";
							#print "Resource: $value\n";
						}
						elsif ($header[$idx] eq 'MetricName') {
							$metric .= "_$value";
							#print "MetricName: $value\n";
						}
						elsif ($header[$idx] eq 'Actual Start Timestamp') {
							$timestamp_orig = $value;
							if ($value =~ /^(\w+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\w+)\s+(\d+)/) { 
								#Wed Mar 16 19:45:30 EDT 2011
								my $year = $8;
								my $mon  = $months{$2};
								my $day  = $3;
								my $hour = $4;
								my $min  = $5;
								my $sec  = $6;
								$timestamp = "$year-$mon-$day $hour:$min:$sec";
							}
							
							$data{$data_file}{$timestamp}{'OriginalTimestamp'} = $timestamp_orig;
						}
						elsif ($header[$idx] eq 'Value Type') {
							$value_type = $value;
						}
						elsif ($header[$idx] eq 'Integer Value') {
							if ($value_type eq 'Long') {
								$data_value = $value;
							}
							elsif ($value_type eq 'Integer') {
								$data_value = $value;
							}
							else {
								die "Can not handle value type: $value_type";
							}
						}
						$idx++;
					}
					$data{$data_file}{$timestamp}{$metric} = $data_value;
				}
				else {
					die $csv->error_input();
				}
			}
		}
		close $RAWFILE;
		
		my @timestamps;
		my %graph_data;
		foreach my $data_file (keys %data) {
			my $header_flag= 0;
			open  ROW, ">$data_file";
			foreach my $timestamp (sort keys %{$data{$data_file}}) {
				if ($header_flag == 0) {
					push my @metrics, "Timestamp", sort keys %{$data{$data_file}{$timestamp}};
					print ROW join("\t", @metrics)."\n";
					$header_flag = 1;
				}
				
				print ROW "$timestamp";
				push @timestamps, $timestamp;
				foreach my $metric (sort keys %{$data{$data_file}{$timestamp}}) {
					print ROW "\t$data{$data_file}{$timestamp}{$metric}";
					
					push @{$graph_data{$metric}}, $data{$data_file}{$timestamp}{$metric};
				}
				print ROW "\n";
			}
			close ROW;
		}
		
	}
}
close $LOG;


__DATA__
CRASH: my $cmdLine = qq{java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching \".*ijtcdb15[89].*EPAgent.*\" and metrics matching \".*\" between $start_str and $end_str > rawdata.DB.1.csv};
works:
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching \".*ijtcdb15[89].*EPAgent.*\" and metrics matching \".*\" for past 1 minutes with frequency of 60 seconds > test1.csv
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching \".*ijtcap14[89].*EPAgent.*\" and metrics matching \".*\" for past 1 minutes with frequency of 60 seconds > test2_apsrv.csv

small chunk of data


java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Active virtual.*" between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Active virtual.1.csv"

java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcdb15[89].*EPAgent.*" and metrics matching ".*Free Disk Space.*" between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.1.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Free i-nodes.*" between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Free_i-nodes.1.csv"
NG: java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Error Count.*" and resource matching ".*NETSTAT.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.NETSTAT.ErrorCount.1.csv"
NG: java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Error Count.*" between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.NETSTAT.ErrorCount.2.csv"
NG: java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and resource matching ".*NETSTAT.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.NETSTAT.ErrorCount.3.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*NETSTAT.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.NETSTAT.ErrorCount.4.csv"
NG: java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM|CPU.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.CPU.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Kernel.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Kernel.1.csv"
NG: java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*Connections.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Connections.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*netstat.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.netstat.1.csv"





java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM.CPU.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.CPU.2.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM.Memory.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Memory.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM.Kernel Threads.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Kernel.2.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM.Faults.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Faults.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*GC Heap.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.GCHeap.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*VM.Paging.*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.Paging.1.csv"
java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar CLWorkstation.jar get historical data from agents matching ".*ijtcap14[89].*EPAgent.*" and metrics matching ".*netstat.(Total|ESTABLISHED).*"  between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s > "rawdata.netstat.2.csv"





































