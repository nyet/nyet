use Data::Dumper;
use File::Basename;
use File::Glob ':glob';
use File::Path;
use Time::Local;

#my $folder = '..\FNF TRAX Scripts\Results\20100816_1939_v2_32_133_01_was7_baseline_50pct_1hr_148\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20100816_1939_v2_32_133_01_was7_baseline_50pct_1hr_148\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20100816_2100_v2_32_133_01_was7_baseline_50pct_1hr_148\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20100816_2220_v2_32_133_01_was7_baseline_50pct_1hr_148_2vm\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20100816_2338_v2_32_133_01_was7_baseline_50pct_1hr_148_2vm\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101115_1456_v2_34_125_01_ftlauderdale\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101115_1802_v2_34_125_01_ftlauderdale_40taag\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101115_2032_v2_34_125_01_ftlauderdale_40taag_bad\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101115_2317_v2_34_125_01_ftlauderdale_40taag\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101116_1223_v2_34_125_01_ftlauderdale_40taag\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101116_1510_v2_34_125_01_ftlauderdale_nocreatecust_40taag\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101116_1752_v2_34_125_01_ftlauderdale_nocreatecust_40taag_3JVM\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101116_2013_v2_34_125_01_ftlauderdale_nocreatecust_40taag_3JVM\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101117_1142_v2_34_125_01_ftlauderdale_createcust_40taag_3jvm_30thrd\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101117_1626_v2_34_125_01_ftlauderdale_createcust_90taag_3jvm_30thrd\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101117_1938_v2_34_125_01_ftlauderdale_createcust_openbatch_90taag_3jvm_30thrd\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101118_1559_v2_34_125_01_ftlauderdale_nocreatecust_40taag_stat1\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101118_1905_v2_34_125_01_ftlauderdale_nocreatecust_40taag_stat1\Analysis\Report';
#my $folder = 'G:\Perf\TRAX\Results\20101118_2119_v2_34_125_01_ftlauderdale_nocreatecust_40taag_stat1\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101201_1332_v2_35_111_01_gary\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101201_1703_v2_35_111_01_gary\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101201_2050_v2_35_111_01_gary\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101202_1215_v2_35_111_01_gary_foogle500items\Analysis\Report';
my $folder = 'G:\Perf\TRAX\Results\20101202_1503_v2_35_111_01_gary_foogle500items\Analysis\Report';
my $folder = 'E:\Perf\TRAX\Results\20101209_1130_v2_35_111_01_gary_elynx\Analysis\Report';
my $folder = 'E:\Perf\TRAX\Results\20101209_1414_v2_35_111_01_gary_elynx\Analysis\Report';
my $folder = 'E:\Perf\TRAX\Results\20101209_1725_v2_35_111_01_gary_elynx_capture_maia_errors\Analysis\Report';
#my $folder = '\Analysis\Report';
#my $folder = '\Analysis\Report';
#my $folder = '\Analysis\Report';
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
			print "start: $start, mon: $2, day: $1, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $1, $2-1, $3);
			my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
			$start_tick = $time - 3600;		# 10.213.210.31
			#$start_tick = $time - 3600;		# convert to CT
			#$start_tick = $time - 3*3600;	# convert to PT
			#$start_tick += 300;
			
			($start_time{sec},$start_time{min},$start_time{hour},
			 $start_time{mday},$start_time{mon},$start_time{year},
			 $start_time{wday},$start_time{yday},$start_time{isdst}) = localtime($start_tick);
			$start_time{mon}++;
			$start_time{year}+=1900;
		}
		if ($end =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/) {
			print "start: $start, mon: $2, day: $1, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $1, $2-1, $3);
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
	#'ijtcap148.ngs.fnf.com\Trax\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-1\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-2\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-3\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-1\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-2\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-3\native_stderr_2010.09.18_9.49.54.gz',
	
	'ijtcap148.ngs.fnf.com\Trax\native_stderr.gz',
	'ijtcap148.ngs.fnf.com\Trax-1\native_stderr.gz',
	'ijtcap148.ngs.fnf.com\Trax-2\native_stderr.gz',
	'ijtcap148.ngs.fnf.com\Trax-3\native_stderr.gz',
	'ijtcap149.ngs.fnf.com\Trax\native_stderr.gz',
	'ijtcap149.ngs.fnf.com\Trax-1\native_stderr.gz',
	'ijtcap149.ngs.fnf.com\Trax-2\native_stderr.gz',
	'ijtcap149.ngs.fnf.com\Trax-3\native_stderr.gz',
);



open AFLOG, ">Af.log";
print AFLOG "JVM_Container\tAF_ID\tNeed\tLastAF\tCompleted\n";
close AFLOG;

open GCLOG, ">Gc.log";
print GCLOG "JVM_Container\tGC_ID\tTime\tFreed\tFree(\%)\tGC_elapse(ms)\n";
close GCLOG;
foreach my $file (@files) {
	$file =~ /(ijtcap.*?)\./;
	my $vm_name = $1;
	$file =~ /[\\\/]Trax(.*)[\\\/]/;
	$vm_name .= "-VM$1";
	
	print "vm_name: $vm_name\n";
	#exit;
	
	if (-f $file) {
		print "$file: file\n";
		my $dir = dirname($file);
		print "	dir:$dir\n";
		#"C:\Program Files\7-Zip\7z.exe" e ijtcap148.ngs.fnf.com\Trax\native_stderr.gz -oijtcap148.ngs.fnf.com\Trax
		print qq{	"$seven_zip" e $file -o$dir -y\n};
		system(qq{"$seven_zip" e $file -o$dir -y});
		
		#(my $log_file = $file) =~ s/\.gz$/.log/;
		use File::Basename;
		my $log_file = dirname($file).'/native_stderr.log';
		#process native_stderr.log
		print "	processing $log_file\n";
		my $GCidx = 0;
		my $AFidx = 0;
		my $AFneed = 0;
		my $AFlast = 0;
		
		my $lineNo=1;
		my $display_counter = 1;
		
		#16/08/2010 19:40:02 - 16/08/2010 20:46:14
		my $current_date_str = "";
		my $current_tick = "";
		my $log_it = 0;
		open GCLOG, ">>Gc.log";
		open AFLOG, ">>Af.log";
		open FILE, $log_file or die "Can not open $log_file";
		while (my $line = <FILE>) {
			if ($line =~/<GC\((\d+)\): GC cycle started (.+)/) {
				$GCidx = $1;
				my $time = $2;
				if ($time =~ /(\w+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/) { #Fri Feb 20 12:34:50 2009
					#print "		time: $time, mon: $months{$2}, day: $3, year: $7, hour $4, min: $5, sec: $6\n";
					my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $3, $months{$2}-1, $7);
					$current_date_str = "$year/$months{$2}/$mday";
					
					if ($current_date_str eq $start_date_str) {
						$current_tick = timelocal($sec,$min,$hour,$mday,$mon,$year);
						print "		time: $time, current_tick: $current_tick\n";
						#exit if $display_counter++ % 20 == 0;
						
						$log_it = 0;
						if (($start_tick < $current_tick) && ($current_tick < $end_tick)) {
							print "		time: $time, current_tick: $current_tick\n";
							print GCLOG "$vm_name	$GCidx	$time";
							$log_it = 1;
						}
					}
				}
			}
			elsif ($line =~/<AF\[(\d+)\]: Allocation Failure. need (\d+) bytes, (\d+) ms since last AF/) {
				$AFidx = $1;
				$AFneed = $2;
				$AFlast = $3;
			}
			else {
				if (($log_it) && ($line =~/<GC\((\d+)\): freed (\d+) bytes, (\d+)% free \((\d+)\/(\d+)\), in (\d+) ms>/)) {
					my $idx = $1;
					my $freed = $2;
					my $free = $3;
					#my $ = $4;
					#my $ = $5;
					my $time = $6;
					if ($idx == $GCidx) {
						print GCLOG "	$freed	$free	$time\n";
					}
					else {
						print GCLOG "BITCH! $idx != $GCidx at $lineNo\n";
					}
				}
				elsif (($log_it) && ($line =~/<AF\[(\d+)\]: completed in (\d+) ms/)) {
					my $idx = $1;
					my $completed = $2;
					if ($idx == $AFidx) {
						print AFLOG "$vm_name\t$idx\t$AFneed\t$AFlast\t$completed\n";
					}
					else {
						print AFLOG "BITCH! $idx != $AFidx at $lineNo\n";
					}
				}
			}
			
			$lineNo++;
		}
		close FILE;
		close GCLOG;
		close AFLOG;
		#exit;
	}
}



#print "1?1";my $wait=<>;

__DATA__

<AF[203]: Allocation Failure. need 20802016 bytes, 106841 ms since last AF>
<AF[203]: managing allocation failure, action=2 (795348040/1064368640)>
  <GC(203): mark stack overflow[18]>
  <GC(203): mark stack overflow processing System Classes>
  <GC(203): GC cycle started Mon Nov  1 10:34:14 2010
  <GC(203): freed 158725800 bytes, 89% free (954073840/1064368640), in 10213 ms>
  <GC(203): mark: 2014 ms, sweep: 28 ms, compact: 8171 ms>
  <GC(203): refs: soft 0 (age >= 32), weak 47, final 669, phantom 0>
  <GC(203): moved 1183222 objects, 72576480 bytes, reason=1, used 29824 more bytes>
<AF[203]: managing allocation failure, action=3 (954073840/1064368640)>
  <GC(203): need to expand mark bits for 1073674752-byte heap>
  <GC(203): expanded mark bits by 143360 to 16777216 bytes>
  <GC(203): need to expand alloc bits for 1073674752-byte heap>
  <GC(203): expanded alloc bits by 143360 to 16777216 bytes>
  <GC(203): need to expand FR bits for 1073674752-byte heap>
  <GC(203): expanded FR bits by 290816 to 33554432 bytes>
  <GC(203): expanded heap fully by 9306112 to 1073674752 bytes, 89% free>
<AF[203]: managing allocation failure, action=4 (963379952/1073674752)>
<AF[203]: clearing all remaining soft refs>
  <GC(204): GC cycle started Mon Nov  1 10:34:25 2010
  <GC(204): freed 3249744 bytes, 90% free (966629696/1073674752), in 1064 ms>
  <GC(204): mark: 305 ms, sweep: 22 ms, compact: 737 ms>
  <GC(204): refs: soft 280 (age >= 6), weak 0, final 73, phantom 0>
  <GC(204): moved 320151 objects, 19875648 bytes, reason=1, used 16 more bytes>
<AF[203]: completed in 12047 ms>



		use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);
		use IO::File;
		my $input = new IO::File "<$file" or die "Cannot open '$file': $!\n" ;
		my $buffer ;
		anyinflate $input => \$buffer or die "anyinflate failed: $AnyInflateError\n";
		
		(my $uncompressed_file = $file) =~ s/\.gz$/.txt/;
		open FILE, ">$uncompressed_file";
		print FILE $input;
		close FILE;
		
		
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
	'WS', => {
		agents => '.*ijtcap14[12].*EPAgent.*',
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
);


my $time = " between $start_str and $end_str";
#my $time = " between 2010/02/01 08:00:00 and 2010/02/01 08:15:00 with frequency of 300 s";
open my $LOG, ">getWILY.log";
foreach my $type (sort keys %skim) {
	print {$LOG} "server type: $type\n";
	my $agents = $skim{$type}{agents};
	print {$LOG} "	agent string: $agents\n";
	foreach my $metric (@{$skim{$type}{metrics}}) {
		print {$LOG} "	metric: $metric\n";
		(my $metricname = $metric) =~ s/(\W)/_/g;
		$metricname =~ s/\s/_/g;
		my $cmdLine = qq{java -Xmx128M -Duser=Guest -Dpassword=Guest -Dhost=10.53.3.74 -Dport=5001 -jar "../CLWorkstation.jar" get historical data from agents matching \"$agents\" and metrics matching \"$metric\" $time > rawdata.$type.$metricname.csv};
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
