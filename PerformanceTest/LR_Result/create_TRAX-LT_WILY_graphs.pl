use strict;
use Data::Dumper;
# find ###FILTER###


open my $LOG, ">$0.log";

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
my $data_folder = "Perfmon2_DST\\Data";
foreach my $type (sort keys %skim) {
	print {$LOG} "type: $type\n";
	
	my $agents = $skim{$type}{agents};
	
	use Spreadsheet::WriteExcel;
	my $workbook = Spreadsheet::WriteExcel->new("$type.xls");
	
	foreach my $metric (@{$skim{$type}{metrics}}) {
		print {$LOG} "metric: $metric\n";
		
		(my $metricname = $metric) =~ s/(\W)/_/g;
		$metricname =~ s/\s/_/g;
		my $rawdata_file = "$rawdata_folder\\rawdata.$type.$metricname.csv";
		
		print {$LOG} "open rawdata_file: $rawdata_file\n";
		open my $RAWFILE, $rawdata_file;
		my $line = <$RAWFILE>;
		$line = <$RAWFILE>;
		print {$LOG} "rawdata_file header: $line";
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
		print {$LOG} "rawdata_file header: ".Dumper(\@header);
		my $data_file = "$data_folder/$type.$metricname.tsv";
		my %data;
		if ($#header > -1) {
			while ($line = <$RAWFILE>) {
				#print {$LOG} "RAWFILE:$line";
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
					#print {$LOG} "ASSIGNMENT:\$data _ $data_file _ $timestamp _ $metric _ = $data_value\n";
					$data{$data_file}{$timestamp}{$metric} = $data_value;
				}
				else {
					die $csv->error_input();
				}
			}
		}
		close $RAWFILE;
		
		#print {$LOG} "Dumper data:\n";
		#print {$LOG} Dumper \%data;
		
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
					
					###FILTER###
					if ($metric =~ /cpu/i) {  # CPU
						if ($metric =~ /wait/i) {  # CPU
							push @{$graph_data{wait}{$metric}}, $data{$data_file}{$timestamp}{$metric};
						}
						elsif ($metric =~ /idle/i) {  # CPU
							push @{$graph_data{idle}{$metric}}, $data{$data_file}{$timestamp}{$metric};
						}
					}
				}
				print ROW "\n";
			}
			close ROW;
		}
		
		print {$LOG} "Dumper graph_data:\n";
		print {$LOG} Dumper \%graph_data;
		
		foreach my $counter_name (keys %graph_data) {
			#my %spreadsheet_pseudo;
			
			print {$LOG} "Create worksheet($counter_name data)\n";
			my $worksheet = $workbook->add_worksheet($counter_name." data");
			
			#http://search.cpan.org/~jmcnamara/Spreadsheet-WriteExcel-2.37/lib/Spreadsheet/WriteExcel.pm
			my $row_id_max = 0;
			my $row_idx = 0;
			foreach my $timestamp (@timestamps) {
				my $col_idx = 0;
				$worksheet->write($row_idx, $col_idx, $timestamp);
				#if (!exists $spreadsheet_pseudo{"$row_idx, $col_idx"}) {
				#	$spreadsheet_pseudo{"$row_idx, $col_idx"} = $timestamp; 
				#	print {$LOG} "1:Assign spreadsheet_pseudo at $row_idx, $col_idx\n";
				#	print {$LOG} "Current value:  ".$timestamp."\n";
				#}
				#else {
				#	print {$LOG} "1:Double accounting at $row_idx, $col_idx\n";
				#	print {$LOG} "Previous value: ".$spreadsheet_pseudo{"$row_idx, $col_idx"}."\n";
				#	print {$LOG} "Current value:  ".$timestamp."\n";
				#}
				
				$col_idx++;
				foreach my $metric (sort keys %{$graph_data{$counter_name}}) {
					#print "metric: $metric\n";
					#print "counter_name: $counter_name\n";
					#print "row_idx: $row_idx\n";
					#print "data: ".${$graph_data{$counter_name}{$metric}}[$row_idx]."\n";
					$worksheet->write($row_idx, $col_idx, ${$graph_data{$counter_name}{$metric}}[$row_idx]);
					#if (!exists $spreadsheet_pseudo{"$row_idx, $col_idx"}) {
					#	$spreadsheet_pseudo{"$row_idx, $col_idx"} = ${$graph_data{$counter_name}{$metric}}[$row_idx];
					#	print {$LOG} "2:Assign spreadsheet_pseudo at $row_idx, $col_idx\n";
					#	print {$LOG} "Current value:  ".${$graph_data{$counter_name}{$metric}}[$row_idx]."\n";
					#}
					#else {
					#	print {$LOG} "2:Double accounting at $row_idx, $col_idx\n";
					#	print {$LOG} "Previous value: ".$spreadsheet_pseudo{"$row_idx, $col_idx"}."\n";
					#	print {$LOG} "Current value:  ".${$graph_data{$counter_name}{$metric}}[$row_idx]."\n"; 
					#}
					$col_idx++;
				}
				$row_id_max = ++$row_idx;
			}
			#WARNING: Spreadsheet::WriteExcel and Office Service Pack 3 Options
			#"File Error: data may have been lost". 
			#http://groups.google.com/group/spreadsheet-writeexcel/browse_thread/thread/3dcea40e6620af3a
			
			my $chart = $workbook->add_chart(type => 'line', name => $counter_name.' chart');
			my $i = 66;
			foreach my $counter_header_name (sort keys %{$graph_data{$counter_name}}) {
				$chart->add_series(
					categories => '='.$counter_name.' data!A1:A'.$row_id_max,
					values     => '='.$counter_name.' data!'.chr($i).'1:'.chr($i).''.$row_id_max,
					name       => $counter_header_name,
				);
				$i++;
			}
		}
	}
	$workbook->close();
	#print "stop, check $type.xls\n";<>;
}
close $LOG;
