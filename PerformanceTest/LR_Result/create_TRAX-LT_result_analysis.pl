use strict;
use File::Path;
use File::Basename;
use File::Glob ':glob';
use Time::Local;

my %months = (
	Jan => 0,
	Feb => 1,
	Mar => 2,
	Apr => 3,
	May => 4,
	Jun => 5,
	Jul => 6,
	Aug => 7,
	Sep => 8,
	Oct => 9,
	Nov => 10,
	Dec => 11,
);

open my $REPORT, ">report.txt";
open my $LOG, ">list.log";

my $start_tick = 0;
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
			$start_tick = $time - 3600; # convert to CT
			$start_tick -= 300;
		}
		if ($end =~ /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/) {
			print "start: $start, mon: $1, day: $2, year: $3, hour $4, min: $5, sec: $6\n";
			my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $2, $1-1, $3);
			my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
			$end_tick = $time - 3600; # convert to CT
			$end_tick += 300;
		}
	}
	close FILE;
}

if ($end_tick==0 || $start_tick==0) {
	print "start_tick($start_tick) or end_tick($end_tick) equals to 0";
}
else {
	print "start_tick: $start_tick\n";
	print "end_tick:   $end_tick\n";
}

{ # get server logs
	{ # get cd /usr/WebSphere/AppServer/profiles/AppSrv01/logs/Trax
		#Check if SystemErr.log has something new
		#Check if native_stdout.log has something new
		#Check if trace.log has something new
		#get SystemOut.log & parse for something weird
		#get native_stderr.log & make GC 
	}
	
	#{
		#/usr/local/logs/trax
		#ls -Alt
		#ijtcap148(lsusanto):/usr/local/logs/trax> ls -Alt
		#total 197232
		#-rw-rw-r--   1 trax     wasadmin     507318 Mar 11 00:15 trax0.xml.1
		#-rw-rw-r--   1 trax     wasadmin     981584 Mar 11 00:14 trax0.xml.3
		#-rw-rw-r--   1 trax     wasadmin     531652 Mar 11 00:13 trax0.xml
		#-rw-rw-r--   1 trax     wasadmin      89392 Mar 11 00:12 trax0.xml.2
		#-rw-rw-r--   1 trax     wasadmin    1060317 Mar 10 23:47 trax1.xml.2
		#-rw-rw-r--   1 trax     wasadmin    1048747 Mar 10 23:02 trax1.xml.1
		#-rw-rw-r--   1 trax     wasadmin    1049751 Mar 10 20:53 trax1.xml
		#-rw-rw-r--   1 trax     wasadmin    1048585 Mar 10 19:43 trax1.xml.3

	#}
}

#if (0) {
foreach my $folder (bsd_glob('httplogs/*')) {
	if (-d $folder) {
		my $basename = basename($folder);
		my $i= 0;
		open FILE, "$folder/access_log.trax";
		while ((my $line = <FILE>)) { #&&($i<100)
			if ($line =~ /j_security_check/) {
				if ($line =~ /\[(\d+)\/(\w+)\/(\d+):(\d+):(\d+):(\d+) /) {
					my ($sec,$min,$hour,$mday,$mon,$year) = ($6, $5, $4, $1, $months{$2}, $3);
					my $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
					
					#print "	time: $time - $year/$mon/$mday $hour:$min:$sec\n";
					if (($start_tick < $time) && ($time < $end_tick)) {
						$i++;
					}
				}
				
			}
			#start_tick: 1257195749
			#end_tick:   1257197351
			#1254513922
			
			#11/02/2009   14:02:29   11/02/2009   14:29:11
			#02/Nov/2009:13:03:02
			
			#if ($line =~ /\.(gif|png|jpg|js|css|swf) HTTP/i) {
			#}
			#else {
			#	print $line;
			#	$i++;
			#}
		}
		close FILE;
		print "$basename	j_security_check	$i\n";
	}
}
#}

open my $ERRLOG, ">$0.error.log";
open my $PAPERRLOG, ">pap.error.log";
my $EndorsementCodeMaintenanceErrorCount = 0;
my $CommissionBasicErrorCount = 0;
my $TransactionLevelAdjustmentErrorCount = 0;

my %old_clups;
my %empty_uploadnum;
my %AreaCostCentersMaintain_Load_bad_pAreaManagerID;
my %AreaCostCentersMaintain_Load_bad_pDivisionID;
my %CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptAgentID;
my %CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptPolicyNum2;
my @LATPolicy_Load_pUploadNumber;
my %upload_lat_policy_number_status;
my %MultipleUBECorrection_Load_bad_CLUP;

foreach my $file (bsd_glob('log/*.log')) {
	print {$LOG} "$file\n";
	if ($file =~ /AddPolicy_Load_/) {
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /fail/i) {
				print {$PAPERRLOG} "$file\n";
				print {$PAPERRLOG} $line;
			}
		}
		close FILE;
	}
	elsif ($file =~ /AreaCostCentersMaintain_Load_/) {
		my $transaction_name = "";
		my $pAreaManagerID = "";
		my $pDivisionID = "";
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Transaction (\w+) started/) {
				$transaction_name = $1;
			}
			elsif ($line =~ /\"pAreaManagerID\"\s+=\s+\"(\d+)\"/) { #"pAreaManagerID" =  "196690"
				$pAreaManagerID = $1;
			}
			elsif ($line =~ /\"pDivisionID\"\s+=\s+\"(\d+)\"/) {
				$pDivisionID = $1;
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				
				if ($line =~ /pCostCenterDetailID/) {
					if ($transaction_name eq 'ACC_T04_SearchAreaManager') {
						#print {$ERRLOG} "$filename:ACC_T04_SearchAreaManager:pAreaManagerID($pAreaManagerID) returns nothing.\n";
						$AreaCostCentersMaintain_Load_bad_pAreaManagerID{$pAreaManagerID}++;
					}
					elsif ($transaction_name eq 'ACC_T02_SearchDivision') {
						#print {$ERRLOG} "$filename:ACC_T02_SearchDivision:pDivisionID($pDivisionID) returns nothing.";
						$AreaCostCentersMaintain_Load_bad_pDivisionID{$pDivisionID}++;
					}
					else {
						print {$ERRLOG} "$filename:$line";
					}
				}
				else {
					print {$ERRLOG} "$filename:$line";
				}
			}
		}
		close FILE;
	}
	elsif ($file =~ /CashCheckReceiptMultipleAllocation_Load/) {
		my $pCheckReceiptAgentID;
		my $pCheckReceiptPolicyNum2;
		my $status;
		my $open_transaction;
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /\"pCheckReceiptAgentID\"\s+=\s+\"(.+?)\"/) {
				$pCheckReceiptAgentID = $1;
			}
			elsif ($line =~ /\"pCheckReceiptPolicyNum2\"\s+=\s+\"(.+?)\"/) {
				$pCheckReceiptPolicyNum2 = $1;
			}
			elsif ($line =~ /Notify: Transaction (\S+) started\./) {
				$open_transaction = $1;
				$open_transaction =~ s/^\"//;
				$open_transaction =~ s/\"$//;
			}
			elsif ($line =~ /Check creation .+?status is not .+?: (.+?) - abort/) {
				#status is not VALID or DUPLICATE: AGENT_SYSTEM_CANCELLED - abort
				#status is not VALID, status: POLICY_NOT_FOUND - abort
				$status = $1;
				print "status: $status, open_transaction: $open_transaction\n";
				
				if (($status eq 'AGENT_SYSTEM_CANCELLED') && ($open_transaction eq 'CCRMA_T05_CreateNewEntry')) {
					$CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptAgentID{$pCheckReceiptAgentID}++;
				}
				elsif (($status eq 'POLICY_NOT_FOUND') && ($open_transaction eq 'CCRMA_T08_ValidatePolicyNumber')) {
					$CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptPolicyNum2{$pCheckReceiptPolicyNum2}++;
				}
			}
			elsif ($line =~ /Cannot start transaction \"?CCRMA_T05_CreateNewEntry\"?/) {
				#CashCheckReceiptMultipleAllocation.c(269): Error: Cannot start transaction "CCRMA_T05_CreateNewEntry". 
			}
			elsif ($line =~ /Cannot start transaction \"?CCRMA_T08_ValidatePolicyNumber\"?/) {
				#CashCheckReceiptMultipleAllocation.c(638): Error: Cannot start transaction "CCRMA_T08_ValidatePolicyNumber".
				#CashCheckReceiptMultipleAllocation.c(666): Check creation #2-1301306184959 status is not VALID, status: POLICY_NOT_FOUND - abort
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}
		}
		close FILE;
	}
	elsif ($file =~ /CommissionBasic_Load_/) {
		my $open_transaction = "";
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Notify: Transaction (\S+) started\./) {
				$open_transaction = $1;
				$open_transaction =~ s/^\"//;
				$open_transaction =~ s/\"$//;
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
				
				$CommissionBasicErrorCount++;
				print {$LOG} "	$open_transaction:$line";
			}
		}
		close FILE;
		print {$LOG} "Error count: $CommissionBasicErrorCount\n";
	}
	elsif ($file =~ /EndorsementCodeMaintenance_Load_/) {
		my $open_transaction = "";
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Notify: Transaction (\S+) started\./) {
				$open_transaction = $1;
				$open_transaction =~ s/^\"//;
				$open_transaction =~ s/\"$//;
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
				
				$EndorsementCodeMaintenanceErrorCount++;
				print {$LOG} "	$open_transaction:$line";
			}
		}
		close FILE;
		print {$LOG} "Error count: $EndorsementCodeMaintenanceErrorCount\n";
	}	
	elsif ($file =~ /InventoryTransferPolicies_Load_/) {
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}
			elsif ($line =~ /^InventoryMUP_BulkTransfer.+Saving Parameter \"vOldAgentID = (\d+\.\d+\.\d+\.\d+)\"/) {
				$old_clups{InventoryMUP_BulkTransfer}{$1}++;
			}
			elsif ($line =~ /^InventoryMUP_RangeTransfer.+Saving Parameter \"pCurrentAgentID = (\d+\.\d+\.\d+\.\d+)\"/) {
				$old_clups{InventoryMUP_RangeTransfer}{$1}++;
			}
			#InventoryMUP_BulkTransfer.c(43): Notify: Saving Parameter "vOldAgentID = 101349.3.74.29"
			#InventoryMUP_RangeTransfer.c(27): Notify: Saving Parameter "pCurrentAgentID = 101349.3.74.29"
		}
		close FILE;
	}
	elsif ($file =~ /LATPolicy_Load_/) {
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Saving Parameter \"pUploadNumber = (\d+\-\d+)\"/) {
				push @LATPolicy_Load_pUploadNumber, $1;
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}	
		}
		close FILE;
	}
	elsif ($file =~ /MultipleUBECorrection_Load/) {
		my $open_transaction;
		my $pCustomerNo;
		my $pAgentLocation;
		my $pAgentUW;
		my $pAgentState;
		#MultipleUBECorrection_Load_1.log:MultipleUBECorrection.c(140): Error -26366: "Text=<value>75</value>" not found for web_reg_find  	[MsgId: MERR-26366]
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Notify: Transaction (\S+) started\./) {
				$open_transaction = $1;
				$open_transaction =~ s/^\"//;
				$open_transaction =~ s/\"$//;
			}
			elsif ($line =~ /\"pCustomerNo\"\s+=\s+\"(.+?)\"/) {
				$pCustomerNo = $1;
			}
			elsif ($line =~ /\"pAgentLocation\"\s+=\s+\"(.+?)\"/) {
				$pAgentLocation = $1;
			}
			elsif ($line =~ /\"pAgentUW\"\s+=\s+\"(.+?)\"/) {
				$pAgentUW = $1;
			}
			elsif ($line =~ /\"pAgentState\"\s+=\s+\"(.+?)\"/) {
				$pAgentState = $1;
			}
			elsif ($line =~ /Text=<value>\d+<\/value>\" not found for web_reg_find/) {
				if ($open_transaction eq 'MUBE_T02_EnterAgentID') {
					$MultipleUBECorrection_Load_bad_CLUP{"$pCustomerNo.$pAgentLocation.$pAgentUW.$pAgentState"}++;
				}
				else {
					my $filename = basename($file);
					print {$ERRLOG} "$filename:$line";
				}
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}	
		}
		close FILE;
	}
	elsif ($file =~ /multipleubecorrection2_/) {
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}
			elsif ($line =~ /(Upload number \(([\d\-]+)\) has (\d+) UBE policies left)/) {
				if ($3 eq "0") {
					$empty_uploadnum{$2}++;
				}
				print {$LOG} "\t$1\n";
			}
		}
		close FILE;
	}
	elsif ($file =~ /TransactionLevelAdjustment_Load_/) {
		my $open_transaction = "";
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /Notify: Transaction (\S+) started\./) {
				$open_transaction = $1;
				$open_transaction =~ s/^\"//;
				$open_transaction =~ s/\"$//;
			}
			elsif ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
				
				$TransactionLevelAdjustmentErrorCount++;
				print {$LOG} "	$open_transaction:$line";
			}
		}
		close FILE;
		print {$LOG} "Error count: $TransactionLevelAdjustmentErrorCount\n";
	}
	else {
		open FILE, $file;
		while (my $line = <FILE>) {
			if ($line =~ /^\w+\.c\(\d+\): Error/) {
				my $filename = basename($file);
				print {$ERRLOG} "$filename:$line";
			}	
		}
		close FILE;
	}
}
################################################################################
{ # AreaCostCentersMaintain_Load
	my $note = "";
	my @bad_pAreaManagerIDs = keys %AreaCostCentersMaintain_Load_bad_pAreaManagerID;
	if ($#bad_pAreaManagerIDs > -1) {
		$note .= qq|	iPick = 1;\n|;
		$note .= qq|	while (iPick == 1) {\n|;
		$note .= qq|		lr_save_string(lr_paramarr_random1("pAllAreaManagerID"), "pAreaManagerID");\n|;
		$note .= qq|		iPick = 0;\n|;
		my $i=0;
		foreach my $pAreaManagerID (@bad_pAreaManagerIDs) {
			if ($i != 0) {
				$note .= qq|		elsif (strcmp(lr_eval_string("{pAreaManagerID}"), "$pAreaManagerID")==0) {\n|;
			}
			else {
				$note .= qq|		if (strcmp(lr_eval_string("{pAreaManagerID}"), "$pAreaManagerID")==0) {\n|;
			}
			$note .= qq|			iPick = 1;\n|;
			$note .= qq|		}\n|;
			$i++;
		}
		$note .=  qq|	}\n|;
	}
	#############
	my @bad_pDivisionIDs = keys %AreaCostCentersMaintain_Load_bad_pDivisionID;
	if ($#bad_pDivisionIDs > -1) {
		$note .= qq|	iPick = 1;\n|;
		$note .= qq|	while (iPick == 1) {\n|;
		$note .= qq|		lr_save_string(lr_paramarr_random1("pAllDivisionID"), "pDivisionID");\n|;
		$note .= qq|		iPick = 0;\n|;
		my $i=0;
		foreach my $pDivisionID (@bad_pDivisionIDs) {
			if ($i != 0) {
				$note .= qq|		elsif (strcmp(lr_eval_string("{pDivisionID}"), "$pDivisionID")==0) {\n|;
			}
			else {
				$note .= qq|		if (strcmp(lr_eval_string("{pDivisionID}"), "$pDivisionID")==0) {\n|;
			}
			$note .= qq|			iPick = 1;\n|;
			$note .= qq|		}\n|;
			$i++;
		}
		$note .= qq|	}\n|;
	}
	#############
	if (length $note > 0) {
		mkpath("Scripts_WAS7/AreaCostCentersMaintain_Load");
		open my $DATAFH, ">Scripts_WAS7/AreaCostCentersMaintain_Load/AreaCostCenterSearch.c";
		print {$DATAFH} $note;
		close $DATAFH;
		
		#print {$ERRLOG} "AreaCostCentersMaintain_Load:\n";
		#print {$ERRLOG} $note;
	}
}
################################################################################
{ # CashCheckReceiptMultipleAllocation_Load
	my @bad_pCheckReceiptAgentID = keys %CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptAgentID;
	if ($#bad_pCheckReceiptAgentID > -1) {
		mkpath("Scripts_WAS7/CashCheckReceiptMultipleAllocation_Load");
		
		open my $DATAFH, ">Scripts_WAS7/CashCheckReceiptMultipleAllocation_Load/bad_pCheckReceiptAgentID.txt";
		print {$DATAFH} join "\n", @bad_pCheckReceiptAgentID;
		close $DATAFH;
	}
	my @bad_pCheckReceiptPolicyNum2 = keys %CashCheckReceiptMultipleAllocation_Load_bad_pCheckReceiptPolicyNum2;
	if ($#bad_pCheckReceiptPolicyNum2 > -1) {
		mkpath("Scripts_WAS7/CashCheckReceiptMultipleAllocation_Load");
		
		open my $DATAFH, ">Scripts_WAS7/CashCheckReceiptMultipleAllocation_Load/bad_pCheckReceiptPolicyNum2.txt";
		print {$DATAFH} join "\n", @bad_pCheckReceiptPolicyNum2;
		close $DATAFH;
	}
}
################################################################################
{ # LATPolicy_Load
	{ # unzip UploadPoliciesNumberStatus script 
		my $seven_zip = "C:\\Program Files\\7-Zip\\7z.exe";
		my $file = "..\\archives\\UploadPoliciesNumberStatus.zip";
		my $dir = "Scripts_WAS7";
	
		mkpath($dir);
	
		print qq{"$seven_zip" x $file -o$dir -y\n};
		system(qq{"$seven_zip" x $file -o$dir -y});
	
		open my $UPLDNUMFH, ">Scripts_WAS7/UploadPoliciesNumberStatus/importFile.dat";
		print {$UPLDNUMFH} "upload_number\n";
		foreach my $upload_number (@LATPolicy_Load_pUploadNumber) {
			print {$UPLDNUMFH} "$upload_number\n";
		}
		close $UPLDNUMFH;
		
		{ # execute UploadPoliciesNumberStatus
			my $LRBinPath = 'C:\Program Files\HP\LoadRunner\bin';
			use Cwd;
			my $dir = getcwd;
			my $script_location = "$dir\\Scripts_WAS7\\UploadPoliciesNumberStatus";
			my $script_name = basename($script_location);
			(my $script_usr_location = "$script_location\\$script_name.usr") =~ s/\//\\/g;
			(my $result_location   = "$script_location\\result") =~ s/\//\\/g;
			
			if (!-e $result_location) {
				mkpath("$result_location");
			}
			print  "\"$LRBinPath\\mdrv.exe\" -usr \"$script_usr_location\" -out \"$result_location\" -vugen_win 0\n";
			system "\"$LRBinPath\\mdrv.exe\" -usr \"$script_usr_location\" -out \"$result_location\" -vugen_win 0";
			
			{ # parse result
				open FILE, "$result_location/output.txt";
				while (my $line = <FILE>) {
					#The status of upload number (201102-1124861) is ACCEPTED
					if ($line =~ /The status of upload number \(([\d\-]+)\) is (\w+)/) {
						$upload_lat_policy_number_status{$1} = $2;
					}
				}
				close FILE;
				
				#use Data::Dumper;
				#print Dumper \%upload_policy_number_status;
			}
		}
	}
}
################################################################################
{ # MultipleUBECorrection_Load
	my @bad_CLUP = keys %MultipleUBECorrection_Load_bad_CLUP;
	if ($#bad_CLUP > -1) {
		mkpath("Scripts_WAS7/MultipleUBECorrection_Load");
		
		open my $DATAFH, ">Scripts_WAS7/MultipleUBECorrection_Load/bad_CLUP.txt";
		print {$DATAFH} join "\n", @bad_CLUP;
		close $DATAFH;
	}
}
################################################################################

close $LOG;
close $ERRLOG;


print {$REPORT} "Empty uploadnum (multipleubecorrection2):\n";
foreach my $uploadnum (sort keys %empty_uploadnum) {
	print {$REPORT} "	$uploadnum\n";
}
print {$REPORT} "Old CLUP (InventoryTransferPolicies):\n";
foreach my $scriptName (sort keys %old_clups) {
	foreach my $CLUP (sort keys %{$old_clups{$scriptName}}) {
		print {$REPORT} "	$scriptName	$CLUP\n";
	}
}
print {$REPORT} "LAT Policy Upload\n";
foreach my $upload_number (@LATPolicy_Load_pUploadNumber) {
	print {$REPORT}  "	$upload_number	$upload_lat_policy_number_status{$upload_number}\n";
}
close $REPORT;

__DATA__
11/02/2009   14:02:29   11/02/2009   14:29:11
ijtcap141.ngs.fnf.com   j_security_check        19598
ijtcap142.ngs.fnf.com   j_security_check        19615

10.53.0.20 - - [02/Nov/2009:13:02:57 -0600] "GET /trax/action.faces?action=landingPageAction.init&redirect=home HTTP/1.1" 302 -
10.53.0.20 - - [02/Nov/2009:13:02:57 -0600] "GET /trax/login.jsp HTTP/1.1" 200 5183