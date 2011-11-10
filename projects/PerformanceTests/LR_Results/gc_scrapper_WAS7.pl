use Data::Dumper;
use File::Basename;
use File::Glob ':glob';
use File::Path;
use Time::Local;
use XML::Simple;

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
	#'ijtcap148.ngs.fnf.com\Trax\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-1\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-2\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap148.ngs.fnf.com\Trax-3\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-1\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-2\native_stderr_2010.09.18_9.49.54.gz',
	#'ijtcap149.ngs.fnf.com\Trax-3\native_stderr_2010.09.18_9.49.54.gz',
	
	#'ijtcap148.ngs.fnf.com\Trax\native_stderr.gz',
	#'ijtcap148.ngs.fnf.com\Trax-1\native_stderr.gz',
	#'ijtcap148.ngs.fnf.com\Trax-2\native_stderr.gz',
	#'ijtcap148.ngs.fnf.com\Trax-3\native_stderr.gz',
	#'ijtcap149.ngs.fnf.com\Trax\native_stderr.gz',
	#'ijtcap149.ngs.fnf.com\Trax-1\native_stderr.gz',
	#'ijtcap149.ngs.fnf.com\Trax-2\native_stderr.gz',
	#'ijtcap149.ngs.fnf.com\Trax-3\native_stderr.gz',
	#'ljtcap170.fnf.com\trax-1\native_stderr.log',
	#'ljtcap170.fnf.com\trax-2\native_stderr.log',
	#'ljtcap170.fnf.com\trax-3\native_stderr.log',
	#'ljtcap170.fnf.com\trax-4\native_stderr.log',
	
	#'ljtcap148.fnf.com\trax-a\native_stderr.gz',
	#'ljtcap148.fnf.com\trax-b\native_stderr.gz',
	#'ljtcap149.fnf.com\trax-a\native_stderr.gz',
	#'ljtcap149.fnf.com\trax-b\native_stderr.gz',
	
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap148.fnf.com\trax-a\native_stderr.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap148.fnf.com\trax-b\native_stderr.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap149.fnf.com\trax-a\native_stderr.gz',
	'C:\PerformanceTest\TRAX\results\TRAXLogs\ljtcap149.fnf.com\trax-b\native_stderr.gz',
);




open AFLOG, ">Af.log";
print AFLOG "JVM_Container\tAF_ID\tNeed(bytes)\tLastAF(ms)\tCompleted(ms)\tTime\n";
close AFLOG;

open GCLOG, ">Gc.log";
print GCLOG "JVM_Container\tGC_ID\tTime\tFreed(bytes)\tFree(\%)\tGC_elapse(ms)\tSOA freebytes(bytes)\tSOA totalbytes(bytes)\tSOA percent(\%)\tLOA freebytes(bytes)\tLOA totalbytes(bytes)\tLOA percent(\%)\n";
close GCLOG;
foreach my $file (@files) {
	$file =~ /(ljtcap.*?)\./;
	my $vm_name = $1;
	$file =~ /[\\\/]Trax(-.*)[\\\/]/i;
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
		my $buffer = "";
		
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
			if ($line =~/<af type=\"tenured\" id=\"(\d+)\" timestamp=\"(.+?)\" intervalms=\"([\d\.]+)\">/) {
				my $time = $2;
				if ($time =~ /(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/) { #Dec 07 14:10:00 2010
					my ($sec,$min,$hour,$mday,$mon,$year) = ($5, $4, $3, $2, $months{$1}-1, $6);
					$mday =~ s/^0//;
					$current_date_str = "$year/".($mon+1)."/$mday";
					
					#print "start_date_str:   $start_date_str\n";
					#print "current_date_str: $current_date_str\n";
					if ($current_date_str >= $start_date_str) {
						$current_tick = timelocal($sec,$min,$hour,$mday,$mon,$year);
						
						$log_it = 0;
						if (($start_tick < $current_tick) && ($current_tick < $end_tick)) {
							print "		time: $time, current_tick: $current_tick\n";
							$log_it = 1;
						}
					}
				}
			}
			if ($log_it) {
				$buffer .= $line;
			}
			if ($log_it && $line =~/<\/af>/) {
				$log_it = 0;
				
				# process the buffer
				my $xml = XMLin($buffer);
				#AFLOG "JVM_Container\tAF_ID\tNeed\tLastAF\tCompleted\n";
				print "AF_ID\t          ".$xml->{id}."\n";
				print "	Need           ".$xml->{minimum}{requested_bytes}."\n";
				print "	LastAF         ".$xml->{intervalms}."\n";
				my $completed = "";
				DONE:foreach my $time (@{$xml->{time}}) {
					if (exists $time->{totalms}) {
						print "	Completed      ".$time->{totalms}."\n";
						$completed = $time->{totalms};
						last DONE;
					}
				}
				print AFLOG "$vm_name\t$xml->{id}\t$xml->{minimum}{requested_bytes}\t$xml->{intervalms}\t$completed\t$xml->{'timestamp'}";
				my $LOA_percent_claimed   = $xml->{tenured}->[1]->{loa}{'percent'} - $xml->{tenured}->[0]->{loa}{'percent'};
				my $LOA_freebytes_claimed = $xml->{tenured}->[1]->{loa}{'freebytes'} - $xml->{tenured}->[0]->{loa}{'freebytes'};
				my $LOA_totalbytes_claimed = $xml->{tenured}->[1]->{loa}{'totalbytes'} - $xml->{tenured}->[0]->{loa}{'totalbytes'};
				my $SOA_percent_claimed   = $xml->{tenured}->[1]->{soa}{'percent'} - $xml->{tenured}->[0]->{soa}{'percent'};
				my $SOA_freebytes_claimed = $xml->{tenured}->[1]->{soa}{'freebytes'} - $xml->{tenured}->[0]->{soa}{'freebytes'};
				my $SOA_totalbytes_claimed = $xml->{tenured}->[1]->{soa}{'totalbytes'} - $xml->{tenured}->[0]->{soa}{'totalbytes'};
				my $af_tick = 0;
				if ($xml->{'timestamp'} =~ /(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)/) { # Dec 07 14:10:00 2010 <- CT
					my ($sec,$min,$hour,$mday,$mon,$year) = ($5, $4, $3, $2, $months{$1}-1, $6);
					$af_tick = timelocal($sec,$min,$hour,$mday,$mon,$year);
				}
				print AFLOG "\t$af_tick\t$SOA_percent_claimed\t$SOA_freebytes_claimed\t$SOA_totalbytes_claimed\t$LOA_percent_claimed\t$LOA_freebytes_claimed\t$LOA_totalbytes_claimed";
				print AFLOG "\n";
				
				#GCLOG "JVM_Container\tGC_ID\tTime\tFreed\tFree(\%)\tGC_elapse(ms)\tSOA freebytes\tSOA totalbytes\tSOA percent\tLOA freebytes\tLOA totalbytes\tLOA percent\n";
				
				print "GC_ID\t          ".$xml->{gc}{id}."\n";
				print "	Time           ".$xml->{timestamp}."\n";
				print "	Freed          ".$xml->{gc}{tenured}{freebytes}."\n";
				print '	Free(%)        '.$xml->{gc}{tenured}{percent}."\n";
				print "	GC_elapse(ms)  ".$xml->{gc}{timesms}{total}."\n";
				
				print "	LOA freebytes  ".$xml->{gc}{tenured}{loa}{freebytes}."\n";
				print "	LOA totalbytes ".$xml->{gc}{tenured}{loa}{totalbytes}."\n";
				print "	LOA percent    ".$xml->{gc}{tenured}{loa}{percent}."\n";
				
				print "	SOA freebytes  ".$xml->{gc}{tenured}{soa}{freebytes}."\n";
				print "	SOA totalbytes ".$xml->{gc}{tenured}{soa}{totalbytes}."\n";
				print "	SOA percent    ".$xml->{gc}{tenured}{soa}{percent}."\n";

				print GCLOG "$vm_name\t$xml->{gc}{id}\t$xml->{timestamp}\t$xml->{gc}{tenured}{freebytes}\t$xml->{gc}{tenured}{percent}\t$xml->{gc}{timesms}{total}\t$xml->{gc}{tenured}{soa}{freebytes}\t$xml->{gc}{tenured}{soa}{totalbytes}\t$xml->{gc}{tenured}{soa}{percent}\t$xml->{gc}{tenured}{loa}{freebytes}\t$xml->{gc}{tenured}{loa}{totalbytes}\t$xml->{gc}{tenured}{loa}{percent}\n";
				
				$buffer = "";
			}
			$lineNo++;
		}
		close FILE;
		close GCLOG;
		close AFLOG;
	}
}



print "1?1";my $wait=<>;

__DATA__
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
