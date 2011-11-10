use Data::Dumper;
use File::Basename;
use File::Glob ':glob';
use File::Path;
use Time::Local;
use XML::Simple;

my $log = "$0.log";
open my $LOGFH, ">$log";

my $folder = './Analysis/Report';

my $seven_zip = "C:\\Program Files\\7-Zip\\7z.exe";

my %months = (
	Jan=>1, Feb=>2, Mar=>3, Apr=>4,  May=>5,  Jun=>6, 
	Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12,
	January=>1,  February=>2,  March=>3, 
	April=>4,    May=>5,       June=>6, 
	July=>7,     August=>8,    September=>9, 
	October=>10, November=>11, December=>12,
);

my %start_time;
my $start_tick = 0;
my %end_time;
my $end_tick = 0;
{
	local $/ = undef;
	open FILE, "$folder/summary.html";
	my $whole = <FILE>;
	if ($whole =~ /Period: (\d+\/\d+\/\d+\s+\d+:\d+:\d+) - (\d+\/\d+\/\d+\s+\d+:\d+:\d+)\</) {
		my $start = $1;
		my $end = $2;
		print "start: $start\nend:   $end\n";
		if ($start =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/) {
			print "start: $start, mon: $1, day: $2, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $2, $1-1, $3);
			my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
			$start_tick = $time - 3600;		# 10.213.210.31
			#$start_tick = $time - 3600;		# convert to CT
			#$start_tick = $time - 3*3600;	# convert to PT
			#$start_tick -= 300;
			
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
			$end_tick = $time - 3600;		# 10.213.210.31
			#$end_tick = $time - 3600;		# convert to CT
			#$end_tick = $time - 3*3600;	# convert to PT
			#$end_tick += 300;
			
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

my $start_str = "$start_time{'year'}/$start_time{'mon'}/$start_time{'mday'} $start_time{'hour'}:$start_time{'min'}:$start_time{'sec'}";
my $end_str   = "$end_time{'year'}/$end_time{'mon'}/$end_time{'mday'} $end_time{'hour'}:$end_time{'min'}:$end_time{'sec'}";

my $start_date_str = "$start_time{'year'}/$start_time{'mon'}/$start_time{'mday'}";
my $end_date_str   = "$end_time{'year'}/$end_time{'mon'}/$end_time{'mday'}";

print "start: $start_str\n";
print "stop:  $end_str\n";
print "Go ahead?";my $wait=<>;

my @files = (
	#'ijtcap148.ngs.fnf.com\Trax\trace_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-1\trace_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-2\trace_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-3\trace_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax\trace_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-1\trace_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-2\trace_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-3\trace_2010.09.18_9.49.54.gz',
	
	#'ijtcap148.ngs.fnf.com\Trax\trace.gz',
	#'ijtcap148.ngs.fnf.com\Trax-1\trace.gz',
	#'ijtcap148.ngs.fnf.com\Trax-2\trace.gz',
	#'ijtcap148.ngs.fnf.com\Trax-3\trace.gz',
	#'ijtcap149.ngs.fnf.com\Trax\trace.gz',
	#'ijtcap149.ngs.fnf.com\Trax-1\trace.gz',
	#'ijtcap149.ngs.fnf.com\Trax-2\trace.gz',
	#'ijtcap149.ngs.fnf.com\Trax-3\trace.gz',
	#'ljtcap170.fnf.com\trax-1\trace.log',
	#'ljtcap170.fnf.com\trax-2\trace.log',
	#'ljtcap170.fnf.com\trax-3\trace.log',
	#'ljtcap170.fnf.com\trax-4\trace.log',
	
	#'ljtcap148.fnf.com\trax-a\trace.gz',
	#'ljtcap148.fnf.com\trax-b\trace.gz',
	#'ljtcap149.fnf.com\trax-a\trace.gz',
	#'ljtcap149.fnf.com\trax-b\trace.gz',
	
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap148.fnf.com\trax-a\trace.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap148.fnf.com\trax-b\trace.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap149.fnf.com\trax-a\trace.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap149.fnf.com\trax-b\trace.gz',
);



open MQLOG, ">MQ.log";
foreach my $file (@files) {
	$file =~ /(ljtcap.*?)\./;
	my $vm_name = $1;
	$file =~ /[\\\/]Trax(-.*)[\\\/]/i;
	$vm_name .= "-VM$1";
	
	print "vm_name: $vm_name\n";
	print {$LOGFH} "vm_name: $vm_name\n";
	#exit;
	
	if (-f $file) {

		print "file: $file\n";
		print {$LOGFH} "file: $file\n";

		my $dir = dirname($file);
		print "	dir:$dir\n";
			#"C:\Program Files\7-Zip\7z.exe" e ijtcap148.ngs.fnf.com\Trax\trace.gz -oijtcap148.ngs.fnf.com\Trax
			print qq{	"$seven_zip" e $file -o$dir -y\n};
			system(qq{"$seven_zip" e $file -o$dir -y});
		
		#(my $log_file = $file) =~ s/\.gz$/.log/;
		use File::Basename;
		my $log_file = dirname($file).'/trace.log';
		#process trace.log
		print "	processing $log_file\n";
		print {$LOGFH} "	processing $log_file\n";

		my $lineNo=1;
		my %threads;

		#16/08/2010 19:40:02 - 16/08/2010 20:46:14
		my $current_date_str = "";
		my $current_tick = "";
		my $log_it = 0;

		open FILE, $log_file or die "Can not open $log_file";
		while (my $line = <FILE>) {
			if ($line =~/^\[(.+?)\]\s+(.+?)\s+.+?FileServiceImpl\(\)\:sendMessage\(\)/) {
				my $time = $1; 
				my $thread_id = $2; 
				print {$LOGFH} "	time:$time";
				if ($time =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+):(\d+)/) { #5/10/11 13:39:04:415 CDT
					my ($msec,$sec,$min,$hour,$mday,$mon,$year) = ($7, $6, $5, $4, $2, $1-1, $3+2000);
					$mday =~ s/^0//;
					$mon =~ s/^0//;
					$current_date_str = "$year/".($mon+1)."/$mday";
					print {$LOGFH} ":$current_date_str";
					
					#print "start_date_str:   $start_date_str\n";
					#print "current_date_str: $current_date_str\n";
					if ($current_date_str >= $start_date_str) {
						$current_tick = timelocal($sec,$min,$hour,$mday,$mon,$year);
						

						if (($start_tick < $current_tick) && ($current_tick < $end_tick)) {
							if ($line =~ /entering/) {
								$threads{$thread_id}{start} = $current_tick * 1000 + $msec;
								print {$LOGFH} ":".$threads{$thread_id}{start};
							}
							elsif ($line =~ /Leaving/) {
								my $delta = ($current_tick * 1000 + $msec) - $threads{$thread_id}{start};
								print MQLOG "$current_date_str($hour:$min:$sec):$vm_name:$thread_id:$delta\n";

							}
							print {$LOGFH} ":$line";
							print {$LOGFH} "	GET\n";
						}
						else {
							print {$LOGFH} "\n";
						}
					}
				}
			}
			
			$lineNo++;
		}
		close FILE;
		
	}
}
close MQLOG;
close $LOGFH;

