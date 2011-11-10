use strict;
use File::Glob ':glob';

my @logfolders = (
	'lltcap148.fnf.com/trax-a',
	'lltcap148.fnf.com/trax-b',
	'lltcap149.fnf.com/trax-a',
	'lltcap149.fnf.com/trax-b',
	'lltcap150.fnf.com/trax-a',
	'lltcap150.fnf.com/trax-b',
	
	#'ljtcap148.fnf.com/trax-a',
	#'ljtcap148.fnf.com/trax-b',
	#'ljtcap149.fnf.com/trax-a',
	#'ljtcap149.fnf.com/trax-b',
);

my %duplicate_log;
my ($sec,$min,$hour,$mday,$mon,$year) = (0, 0, 0, 0, 0, 0);
open my $LOG, ">extractLogs.log";
foreach my $logfolder (@logfolders) {
	print "$logfolder\n";
	foreach my $logfile (bsd_glob("$logfolder/SystemOut*.log")) {
		my $add_to_buffer = 0;
		my $buffer = "";
		print "	$logfile\n";
		#print {$LOG} "$logfile\n";
		open FILE, $logfile;
		while (my $line = <FILE>) {
			if ($line =~/^\[((\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+).+?)\]/) { #1/6/11 1:57:44:698 CST
				my $time = $1;
				($sec,$min,$hour,$mday,$mon,$year) = ($7, $6, $5, $3, $2, $4+2000);
				$mday =~ s/^0//;
				#$mon =~ s/^0//;
				
				if ($add_to_buffer) {
					#scan $buffer
					#if ($buffer =~ /JMS/i) {
					#	my @lines = split /\n/, $buffer;
					#	print {$LOG} "$year-$mon-$mday $hour:$min:$sec\t$logfolder\t$lines[0]\n";
					#}
					#if ($buffer =~ /DAO_QUERY_TIMEOUT/) {
					#	if ($buffer =~ /Execution time: (\d+) milliseconds/i) {
					#		my $timeout = $1;
					#		
					#		if ($buffer =~ /\] (\w+) LocalExceptio/) {
					#			my $threadid = $1;
					#		
					#			my @lines = split /\n/, $buffer;
					#			print {$LOG} "$year-$mon-$mday $hour:$min:$sec\t$logfolder\tDAO_QUERY_TIMEOUT\tt$threadid\t$timeout\t$lines[0]\n";
					#		}
					#	}
					#}
					#elsif ($buffer =~ /It was active for approximately (\d+) milliseconds/) {
					#	my $timeout = $1;
					#	
					#	$buffer =~ /\] (\w+) ThreadMonitor/;
					#	my $threadid = $1;
					#	
					#	my @lines = split /\n/, $buffer;
					#	print {$LOG} "$year-$mon-$mday $hour:$min:$sec\t$logfolder\tThreadMonitor\tt$threadid\t$timeout\t$lines[0]\n";
					#}
					if ($buffer =~ /ffdc/) {
						my @lines = split /\n/, $buffer;
						print {$LOG} "$year-$mon-$mday $hour:$min:$sec\t$logfolder\t$lines[0]\n";
					}

					$buffer = "";
					$add_to_buffer = 0;
				}
				$buffer = $line;
				$add_to_buffer = 1;
			}
			else {
				$buffer .= $line;
			}
			
			if (0) {
				if ($line =~/^\[((\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+).+?)\]/) { #1/6/11 1:57:44:698 CST
					my $time = $1;
					($sec,$min,$hour,$mday,$mon,$year) = ($7, $6, $5, $3, $2, $4+2000);
					$mday =~ s/^0//;
					#$mon =~ s/^0//;
				}
				#[12/28/10 4:11:46:443 CST] 0000005e LocalExceptio E   CNTR0020E: EJB threw an unexpected (non-declared) exception during invocation of method "findByOptimized" on bean "BeanId(trax#TraxEJB.jar#File, null)". Exception data: com.fnf.maia.common.exception.MRuntimeException: Error ID: MSRVR1704389152 Error code: DAO_QUERY_TIMEOUT
				#...
				#Caused by: javax.ejb.EJBException: nested exception is: com.fnf.maia.common.exception.DAOException: Error code: DAO_QUERY_TIMEOUT
				#Error context: SELECT   TR_FILE_TOTAL_V.FILE_EXTERNAL_ID,TR_FILE_TOTAL_V.FILE_SYS_ID,TR_FILE_TOTAL_V.CUST_SYS_ID,TR_FILE_TOTAL_V.LOC_SYS_ID,TR_FILE_TOTAL_V.UW_SYS_ID,TR_FILE_TOTAL_V.STATE_CD,TR_FILE_TOTAL_V.LEGECY_STATE_NUM,TR_FILE_TOTAL_V.PAYMENT_STATUS,TR_FILE_TOTAL_V.FILE_BAL_AMT,TR_FILE_TOTAL_V.TOT_PAY_AMT,TR_FILE_TOTAL_V.TOT_ADJ_AMT,TR_FILE_TOTAL_V.TOT_FILE_AMT,TR_FILE_TOTAL_V.UW_NBR,TR_FILE_TOTAL_V.UW_SYS_ID,TR_FILE_TOTAL_V.UW_ABBV_CD,TR_FILE_TOTAL_V.CUST_LOC_NBR,TR_FILE_TOTAL_V.LEGECY_STATE_NUM FROM TR_FILE_TOTAL_V WHERE       TR_FILE_TOTAL_V.UW_SYS_ID IN ( 32,33,34,646,71,72,136,137,73,74,75,12,13,14,16,21,27,31 ) AND  UPPER(TR_FILE_TOTAL_V.FILE_EXTERNAL_ID)= 'TST-1293530527186-111' AND TR_FILE_TOTAL_V.CUST_SYS_ID= 7022 AND TR_FILE_TOTAL_V.LOC_SYS_ID= 40051 AND TR_FILE_TOTAL_V.STATE_CD= 'TX' AND TR_FILE_TOTAL_V.UW_SYS_ID= 72 AND ROWNUM <= 1000 , Execution time: 300538 milliseconds, Statement type: com.fnf.maia.server.dao.MDynamicSqlStatement
				
				#WAS7 PROD
				#[12/28/10 0:31:01:939 CST] 00000038 LocalExceptio E   CNTR0020E: EJB threw an unexpected (non-declared) exception during invocation of method "reopen" on bean "BeanId(trax#TraxEJB.jar#Batch, null)". Exception data: com.fnf.maia.common.exception.MRuntimeException: Error ID: MSRVR371629847 Error code: DAO_DBINTERNAL_ERROR
				if ($line =~ /Error code: DAO_QUERY_TIMEOUT/) {
					$line = <FILE>;
					if ($line =~ /Error context: (.+?), Execution time: (\d+) milliseconds/) {
						my $timeout = $2;
						my $SQL = $1;
						
						if (!exists $duplicate_log{"$year-$mon-$mday $hour:$min:$sec:$logfolder:$timeout"}) {
							print {$LOG}  "$year-$mon-$mday $hour:$min:$sec\t$logfolder\tDAO_QUERY_TIMEOUT\t$timeout\t$SQL\n";
							$duplicate_log{"$year-$mon-$mday $hour:$min:$sec:$logfolder:$timeout"} = 1;
						}
					}
				}
			}
			if (0) {
				if ($line =~ /Error code: DAO_QUERY_TIMEOUT/) {
					$line = <FILE>;
					if ($line =~ /Error context: (.+?), Execution time: (\d+) milliseconds/) {
						print {$LOG}  "$logfolder\tDAO_QUERY_TIMEOUT\t$2\t$1\n";
					}
				}
			}
		}
	}
}
close $LOG;