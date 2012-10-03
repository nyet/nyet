use strict;
use v5.10.1;
use File::Glob ':glob';
use File::Path;
use File::Basename;
use File::Copy;
use Time::Local;
use Sys::Hostname;
my $hostname = uc(hostname);

#TODO: the rest of the log needs to be logged for manual inpection

my $foswiki_attachment_dir = 'G:/foswiki/pub/Main/CPANTesters/ExecList/LSusantoM3';
my $foswiki_report_dir     = 'G:/foswiki/data/Main/CPANTesters/ExecList';
my $foswiki_report = 'G:/foswiki/data/Main/CPANTesters/TestResultAnalysis.txt';
#if (!-d $foswiki_attachment_dir) {
#	die "foswiki_attachment_dir($foswiki_attachment_dir) is not detected";
#}

my %PREREQ;
open my $PREREQ, "PREREQ-Collected.txt";
while (my $line = <$PREREQ>) {
	chomp $line;
	my ($module, $noted, $main) = split /\t/, $line;
	$PREREQ{$module}{noted} = $noted;
	%{$PREREQ{$module}{main}} = map { $_ => 1 } split /,/, $main;
}
close $PREREQ;

open my $LOG, ">", "$0.log";
my $table;
my $i=0;
REPORTFILE:foreach my $file (bsd_glob('*.log')) {
	say {$LOG} "$file";
	say        "$file";
	my $filename = basename($file);
	#20120229_225316.P5.010001.cpan-t.T_TE_TEMPIRE_Net-Heroku-0.01.tar.gz
	#20121001_123231.P5.016001.cpan-i.Net-DNS.log
	if ($filename =~ /^(\d{6}).+?(P\d\.\d{6})/) {
		my $platform = $2; 
		my $folder = "C:/CPANTesters/test_logs/$1"."_$2";
		if (!-d $folder) {
			mkpath $folder;
			say {$LOG} "mkpath $folder;";
		}
		
		my $module_name = '';
		if ($filename =~ /cpan-i\.(.+?)\.log/) {
			($module_name = $1) =~ s/\-/::/g;
		}
		
		my $foswiki_page = q|%META:TOPICINFO{author="LeoSusanto" comment="reprev" date="1349196428" format="1.1" version="1"}%|."\n";
		$foswiki_page   .= q|%META:TOPICPARENT{name="WebHome"}%|."\n";
		$foswiki_page   .= q|%TABLE{ sort="on" initsort="2" headerrows="1" }%|."\n";
		$foswiki_page   .= q{| *Line* | *Stat* | *Content* |}."\n";
		my $result_is_count = 0;
		my $copy = 0;
		my $note = '-';
		my $distro_name = '';
		my $cpan_name = '';
		my $move = 0;
		my $move_reason = '';
		my $test_status = 0;
		my @CPAN_Reporter_lines;
		open my $LOGFH, $file;
		PARSELOG:while (my $line = <$LOGFH>) {
			chomp $line;
			if ((!$distro_name)&&($line =~ /Running make for (.+)/)) {
				$distro_name = $1;
				$distro_name =~ s/\.tgz$//;
				$distro_name =~ s/\.tar.gz$//;
				$distro_name =~ s/\.zip$//;
				$distro_name =~ s/.+[\/\\]//;
				
				($cpan_name = $distro_name) =~ s/-([^-]+?)$//; 
				$cpan_name =~ s/-/::/g;
			}
			
			if ($line =~ /Can't open perl script.+cpan-shell-test.pl.+No such file or directory/) {
				$move = 1;
				$move_reason = 'bad configuration:delete in 1 year';
				say "	move:$move_reason";
			}
			elsif ($line =~ /Warning: Cannot install (.+?), don't know what it is/) {
				$move = 1;
				$move_reason = 'module not exists:delete in 1 year';
				say "	move:$move_reason";
			}
			elsif ($line =~ /Don't be silly, you can't install.+?;-\)/) {
				$move = 1;
				$move_reason = 'module not exists:delete in 1 year';
				say "	move:$move_reason";
			}
			elsif ($line =~ /(.+?) is up to date \(.+?\)/) {
				my $tmp = $1;
				if ($module_name eq $tmp) {
					$move = 1;
					$move_reason = 'module is up to date:delete in 1 year';
					say "	move:$move_reason";
				}
			}
			elsif ($line =~ /skipped: Test requires module '(.+?)' but it's not found/) {
				my $module = $1;
				$PREREQ{$module}{main}{$cpan_name}++;
				$PREREQ{$module}{noted} = 0 if !exists $PREREQ{$module}{noted};
				
				$foswiki_page .= qq{| $. | 12-req | <nop>$line |}."\n";
				next PARSELOG;
			}
			elsif ($line =~ /skipped: (.+?) required/) {
				my $module = $1;
				$PREREQ{$module}{main}{$cpan_name}++;
				$PREREQ{$module}{noted} = 0 if !exists $PREREQ{$module}{noted};
				
				$foswiki_page .= qq{| $. | 12-req | <nop>$line |}."\n";
				next PARSELOG;
			}
			elsif ($line =~ /skipped: (.+?) required for test/) {
				my $module = $1;
				$PREREQ{$module}{main}{$cpan_name}++;
				$PREREQ{$module}{noted} = 0 if !exists $PREREQ{$module}{noted};
				
				$foswiki_page .= qq{| $. | 12-req | <nop>$line |}."\n";
				next PARSELOG;
			}
			elsif ($line =~ /skipped: (.+?) .+?required to test/) {
				my $module = $1;
				$PREREQ{$module}{main}{$cpan_name}++;
				$PREREQ{$module}{noted} = 0 if !exists $PREREQ{$module}{noted};
				
				$foswiki_page .= qq{| $. | 12-req | <nop>$line |}."\n";
				next PARSELOG;
			}
			elsif ($line =~ /skipped: (.+?) needed to check error messages/) {
				my $module = $1;
				$PREREQ{$module}{main}{$cpan_name}++;
				$PREREQ{$module}{noted} = 0 if !exists $PREREQ{$module}{noted};
				
				$foswiki_page .= qq{| $. | 12-req | <nop>$line |}."\n";
				next PARSELOG;
			}
			elsif ($line =~ /require/i) {
				# broad catch of required module (some module is required to run some test but it is not be part of the prerequsite modules)
				my $require_count = 0;
				while ($line =~ /require/ig) {
					$require_count++;
				}
				
				if ($line =~ /^(.+?)\.t/) { #capture the test file name.
					my $test_filename = $1;
					my $test_filename_require_count = 0;
					while ($test_filename =~ /require/ig) {
						$test_filename_require_count++;
					}
					if ($require_count == $test_filename_require_count) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
				}
				
				#20121001_145510.P5.016001.cpan-i.MAD-Loader.log
				#t/manifest.t ............................. skipped: Author tests not required for installation
				if ($require_count == 1) {
					if ($line =~ /Author tests not required for installation/i) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					elsif ($line =~ /Compilation failed in require/i) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					elsif (($line =~ /^\s*requires:\s*$/i) || ($line =~ /\[requires\]/i)) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					elsif (($line =~ /^\s*build_requires:\s*$/i) || ($line =~ /\[build_requires\]/i)) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					elsif (($line =~ /^\s*test_requires:\s*$/i) || ($line =~ /\[test_requires\]/i)) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					elsif (($line =~ /^\s*configure_requires:\s*$/i) || ($line =~ /\[configure_requires\]/i)) {
						$foswiki_page .= qq{| $. | 90-req bla | <nop>$line |}."\n";
						next PARSELOG;
					}
					else {
						$move_reason = 'require detected';
						$move = 1;
						$copy = 1;
						
						$foswiki_page .= qq{| $. | 1-req | <nop>$line |}."\n";
						next PARSELOG;
					}
				}
				else {
					$move_reason = 'require detected';
					$move = 1;
					$copy = 1;
				
					$foswiki_page .= qq{| $. | 1-req | <nop>$line |}."\n";
					next PARSELOG;
				}
			}
			elsif ($line =~ /CPAN::Reporter: (.+)/) {
				say {$LOG} "\t$line";
				
				push @CPAN_Reporter_lines, $line;
				
				if ($line =~ /preparing a CPAN Testers report for (.+)/) {
					my $module_name_under_test = $1;
					#filename: 20121001_144617.P5.016001.cpan-t.F_FR_FREW_SQL-Translator-0.11013_03.tar.gz.log
					#CPAN::Reporter: Test result is 'pass', All tests successful.
					#CPAN::Reporter: preparing a CPAN Testers report for SQL-Translator-0.11013_03
					say {$LOG} "\t\t-> ".$CPAN_Reporter_lines[$#CPAN_Reporter_lines -1];
					if ($CPAN_Reporter_lines[$#CPAN_Reporter_lines -1] =~ /Test result is 'pass'/i) {
						$move = 1;
						$move_reason = 'good module';
						say {$LOG} "	move:$move_reason";
					}
					$foswiki_page .= qq{| $. | 99-PASS | <nop>$line |}."\n";
				}
				elsif ($line =~ /result is 'fail'/i) {
					$result_is_count++;
					$move_reason = 'fail detected';
					$note = 'FAIL';
					$move = 1;
					$copy = 1;
					
					$foswiki_page .= qq{| $. | 3-FAIL | <nop>$line |}."\n";
					next PARSELOG;
				}
				elsif ($line =~ /result is 'unknown'/i) {
					$result_is_count++;
					$move_reason = 'unknown detected';
					$note = 'UNKNOWN';
					$move = 1;
					$copy = 1;
					
					$foswiki_page .= qq{| $. | 2-UNKNOWN | <nop>$line |}."\n";
					next PARSELOG;
				}
				elsif ($line =~ /result is 'pass'/i) {
					$result_is_count++;
					$foswiki_page .= qq{| $. | 99 | <nop>$line |}."\n";
					next PARSELOG;
				}
				elsif ($line =~ /result is '(.+)'/i) {
					$result_is_count++;
					$move_reason = 'the result is unknown';
					$note = 'READ';
					$move = 1;
					$copy = 1;
					$foswiki_page .= qq{| $. | <nop>0-? | <nop>$line |}."\n";
					next PARSELOG;
				}
				else {
					$foswiki_page .= qq{| $. | 99 | <nop>$line |}."\n";
				}
			}
			else {
				$foswiki_page .= qq{| $. | 99 | <nop>$line |}."\n";
			}
		}
		close $LOGFH;
		
		if (!$move) {
			if (!$result_is_count) {
				#20121001_124527.P5.016001.cpan-i.Starman.log
				$move = 1;
				$copy = 1;
				$move_reason = '"result is" count is 0';
				$note = 'NORESULT';
			}
		}
		
		
		if (($copy)&&(-d $foswiki_attachment_dir)) {
			(my $foswiki_filename = $filename) =~ s/(\W)/_/g;
			if(-d $foswiki_report_dir) {
				open my $RPT, ">$foswiki_report_dir/$foswiki_filename.txt";
				print {$RPT} $foswiki_page;
				close $RPT;
			}
			
			copy($file, $foswiki_attachment_dir);
			$table .= "| $hostname | $platform | !$distro_name | [[\%PUBURL\%/Main/CPANTesters/ExecList/LSUSANTOM3/$filename][raw]] [[Main.CPANTesters.ExecList.$foswiki_filename][neat]]| 1-new | $note |\n";
		}
		if ($move) {
			if (move($file, "$folder/$filename")) {
				say {$LOG} qq{move($file, "$folder/$filename")};
				open my $BADFH, ">>", "move.bad.log";
				say  {$BADFH} "$folder/$filename\t$move_reason";
				close $BADFH;
			}
			else {
				say {$LOG} qq{move($file, "$folder/$filename"), ERROR: $!};
			}
		}
		
	}
	#2-20120224_115652.log
	elsif ($filename =~ /2-\d{8}_\d{6}\.log/i){
		my $folder = "../test_logs/logs";
		if (!-d $folder) {
			mkpath $folder;
			say {$LOG} "mkpath $folder;";
		}
		if (!-f "test-duration.html") {
			open my $REPORT, ">>", "test-duration.html";
			say    {$REPORT} qq{<table border=0 cellspacing=2 cellpadding=2>};
			close   $REPORT;
		}
		my $cpan_cmdline_start;
		my $cpan_cmdline_end;
		my $cpan_cmdline_logfile;
		open my $FILE, $file;
		while (my $line = <$FILE>) {
			#print "$file:$line";
			if ($line =~ /^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2}):\s+cpan_cmdline\(.+?\) - start > (.+)/) {
				my $year = $1;
				my $mon  = $2-1;
				my $mday = $3;
				my $hour = $4;
				my $min  = $5;
				my $sec  = $6;
				$cpan_cmdline_logfile = $7;
				$cpan_cmdline_start = timelocal( $sec, $min, $hour, $mday, $mon, $year );
				#say "cpan_cmdline_start:$cpan_cmdline_start:$cpan_cmdline_logfile";
			}
			elsif ($line =~ /^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2}):\s+cpan_cmdline\(.+?\) - end/) {
				my $year = $1;
				my $mon  = $2-1;
				my $mday = $3;
				my $hour = $4;
				my $min  = $5;
				my $sec  = $6;
				$cpan_cmdline_end = timelocal( $sec, $min, $hour, $mday, $mon, $year );
				my $duration = $cpan_cmdline_end - $cpan_cmdline_start;
				my $duration_min = int($duration / 60);
				my $duration_sec = $duration % 60;
				if ($duration > 25*60) {
					if ($cpan_cmdline_logfile =~ /(\d{6}).+?(P\d\.\d{6})/) {
						my $file = "../test_logs/$1"."_$2/$cpan_cmdline_logfile";
						open my $REPORT, ">>", "test-duration.html";
						say    {$REPORT} qq{<tr><td>$duration</td><td>$duration_min:$duration_sec</td><td><a href="$file">$cpan_cmdline_logfile</a></td></tr>};
						#say              qq{<tr><td>$duration</td><td>$duration_min:$duration_sec</td><td><a href="$file">$cpan_cmdline_logfile</a></td></tr>};
						close   $REPORT;
					}
				}
			}
		}
		close $FILE;
		
		if (move($file, "$folder/$filename")) {
			say {$LOG} qq{move($file, "$folder/$filename")};
		}
		else {
			say {$LOG} qq{move($file, "$folder/$filename"), ERROR: $!};
		}
	}
	$i++;
	
	#last REPORTFILE if $i > 10;
}
say {$LOG} "TABLE";
say {$LOG} $table;
close $LOG;

open my $PREREQ, ">", "PREREQ-Collected.txt";
foreach my $module (sort keys %PREREQ) {
	say {$PREREQ} join("\t", $module, $PREREQ{$module}{noted}, join(",", keys %{$PREREQ{$module}{main}}));
}
close $PREREQ;

if (-f $foswiki_report) {
	my $whole = '';
	open my $REPORT, $foswiki_report;
	while (my $line = <$REPORT>) {
		if ($line =~ /^TESTRESULTS/) {
			$whole .= $table;
		}
		$whole .= $line;
	}
	close $REPORT;
	
	open my $REPORT, ">", $foswiki_report;
	print {$REPORT} $whole;
	close $REPORT;
}

__DATA__


throws away make test failure (this is common)
but do not throw away build/makefile error

CPAN::Reporter: Makefile.PL result is 'pass', No errors.
CPAN::Reporter: C:\CPANTE~1\PERL51~1.1\site\bin\dmake.exe result is 'unknown', Stopped with an error.
CPAN::Reporter: Test result is 'fail', One or more tests failed.

test error, but everything else is ok - 20121001_140413.P5.016001.cpan-i.Exception.log


20121002_141744.P5.016001.cpan-i.Gearman-Glutch.log
	CPAN::Reporter: Build.PL result is 'pass', No errors.
	CPAN::Reporter: Test result is 'fail', One or more tests failed.
		Unable to initialize connection to gearmand at C:/CPANTesters/Perl5.16.1/site/lib/Gearman/Worker.pm line 116.

20121002_085100.P5.016001.pre-req.log
	CPAN::Reporter: Makefile.PL result is 'pass', No errors.
	CPAN::Reporter: C:\CPANTE~1\PERL51~1.1\site\bin\dmake.exe result is 'unknown', Stopped with an error.
	
FIXED:
20121002_122134.P5.016001.cpan-t.I_IN_INA_Char_HP15_Char-HP15-0.83.tar.gz.log
	everything passed, but the report is not moved.
20121001_124527.P5.016001.cpan-i.Starman.log
	if "result is '" is not found, then there is a problem with this execution.
		
20120815_105736:	cpan_cmdline(Perl::Dist::Strawberry -i) - start > 20120815_105736.P5.012004.cpan-i.Perl-Dist-Strawberry.log
20120815_105736:		C:\CPANTesters\Perl5.012.004_MSSDK7.1_cpan.bat Perl::Dist::Strawberry -i
20120815_110956:	cpan_cmdline(Perl::Dist::Strawberry -i) - end
