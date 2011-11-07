use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use File::Basename;
use File::Path;
use File::Glob ':glob';
use Cwd;
use Net::SMTP;
use Sys::Hostname;
			
my $current_dir = getcwd;
#print "$current_dir";
(my $current_dir_dos_format = $current_dir) =~ s/\//\\/g;
my $execution_data_location = "$current_dir_dos_format\\execution_log";

my $LRBinPath = 'C:\Program Files\HP\LoadRunner\bin';

my $user   = '';
my $passwd = '';
my $tnsName = '';

my $customerid = 7022;
my $legecy_state_num = 43;
my $uw_sys_id = 72;
my $form_id = 7209743;

open REPORT, ">>automated-test-report.txt";
foreach my $folder (bsd_glob('Scripts/*')) {
	if (-d $folder) {
		(my $folder_dos_format = $folder) =~ s/\//\\/g;
		my $script_basename = basename($folder);
		my $run_flag = 0;
		my $status_of_execution = 'NOT_EXEC'; 
		
		if (0&&($script_basename eq 'AddPolicy_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'AddPolicy_SplitGP_PCR_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'AreaCostCentersMaintain_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'BulkCommunication_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CashCheckReceiptMultipleAllocation_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CashCheckReceipts_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CashDailyDeposit_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CommissionBasic_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CommissionGlobal')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CreateCustomer')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CreateOrder_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'CustomerSearchMaintain_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'EndorsementCodeMaintenance_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'ImportPolicies_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'ImportPolicies_SplitGP_PCR_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'InventoryMUP_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'InventoryTransferPolicies_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'MultipleUBECorrection2_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'MultipleUBECorrection_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'PolicyCorrection_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'ProfitCenterMaintain_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'QueryByBatch_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'QueryByFile_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'QueryByPolicy_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'QueryByUBE_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'RateCodes_Load')) {
			$run_flag = 1;
		}
		elsif (1&&($script_basename eq 'TransactionLevelAdjustment_Load')) {
			$run_flag = 1;
		}
		elsif (0&&($script_basename eq 'UBECorrection_Load')) {
			$run_flag = 1;
		}
		
		
		
		else {
			if (1) {
				# if (0){
					# local $/ = undef;
					# open FILE, "$AddPolicy_Load_ScriptFolder/default.usp";
					# my $whole = <FILE>;
					# close FILE;
					# #print $whole;
					# if ($whole =~ /RunLogicNumOfIterations=\"(\d+)\"/) {
						# my $iteration = $1;
						# if ($iteration == 2500) {
							# print "Iteration is 2500\n";
						# }
						# else {
							# system "$script_location";
							# die "RunLogicNumOfIterations is not 2500";
						# }
					# }
					# else {
						# die "Can not find: RunLogicNumOfIterations";
					# }
				# }
				# if (0){
					# #file: default.cfg
					# local $/ = undef;
					# open FILE, "$AddPolicy_Load_ScriptFolder/default.cfg";
					# my $whole = <FILE>;
					# close FILE;
					# #print $whole;
					# 
					# #Options=NOTHINK
					# if ($whole =~ /Options=(\w+)/) {
						# my $think_time = $1;
						# if ($think_time eq 'NOTHINK') {
							# print "Script think time: $think_time\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script think time is not NOTHINK";
						# }
					# }
					# else {
						# die "Can not find: Options";
					# }
				# 
					# #LogOptions=LogExtended
					# #MsgClassData=0
					# #MsgClassParameters=1
					# #MsgClassFull=0
					# #AutoLog=0
					# if ($whole =~ /LogOptions=(\w+)/) {
						# my $param = $1;
						# if ($param eq 'LogExtended') {
							# print "LogOptions: $param\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script log option is not extended";
						# }
					# }
					# else {
						# die "Can not find: LogOptions";
					# }
					# if ($whole =~ /MsgClassData=(\d+)/) {
						# my $param = $1;
						# if ($param == 0) {
							# print "MsgClassData: $param\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script log, extended, data returned by server option is ENABLED";
						# }
					# }
					# else {
						# die "Can not find: MsgClassData";
					# }
					# if ($whole =~ /MsgClassParameters=(\d+)/) {
						# my $param = $1;
						# if ($param == 1) {
							# print "MsgClassParameters: $param\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script log, extended, parameter substitution option is DISABLED";
						# }
					# }
					# else {
						# die "Can not find: MsgClassParameters";
					# }
					# if ($whole =~ /MsgClassFull=(\d+)/) {
						# my $param = $1;
						# if ($param == 0) {
							# print "MsgClassFull: $param\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script log, extended, advance trace option is ENABLED";
						# }
					# }
					# else {
						# die "Can not find: MsgClassFull";
					# }
					# if ($whole =~ /AutoLog=(\d+)/) {
						# my $param = $1;
						# if ($param == 0) {
							# print "AutoLog: $param\n";
						# }
						# else {
							# print "\"$script_location\"\n";
							# system "\"$script_location\"";
							# die "Script log, send msg only when an error occurs option is ENABLED";
						# }
					# }
					# else {
						# die "Can not find: AutoLog";
					# }
				# }
			}
			
		}
		
		my $now_string = localtime; 
		if ($run_flag) {
			print "Running $script_basename\n";
			my $time = time;
			
			my $script_location = "$current_dir_dos_format\\$folder_dos_format\\$script_basename.usr";
			my $script_execution_data_location = "$execution_data_location\\$time.$script_basename";
			
			if (-e $script_execution_data_location) {
				die "execution_data_location: $script_execution_data_location exists\n";
			}
			else {
				mkpath("$script_execution_data_location");
			}
			
			print  "\"$LRBinPath\\mdrv.exe\" -usr \"$script_location\" -out \"$script_execution_data_location\" -vugen_win 0\n";
			system "\"$LRBinPath\\mdrv.exe\" -usr \"$script_location\" -out \"$script_execution_data_location\" -vugen_win 0";
				
			# parse the execution log
			# get application version out and send it via email
			$status_of_execution = 'PASS'; #pass
			my $output_filename = "$script_execution_data_location\\output.txt";
			open OUTPUT, $output_filename;
			PARSELOG:while (my $line = <OUTPUT>) {
				if ($line =~ /error\.gif/i) {
					#CreateOrder_Load 
				}
				elsif (($line =~ /error/i)||($line =~ /fail/i)) {
					$status_of_execution = 'FAIL';
					last PARSELOG;
				}
			}
			close OUTPUT;
			
			my $smtpserver = '';
			my $emailfrom = '';
			my $To = '';
			my $host = hostname;
			
			my $smtp = Net::SMTP->new($smtpserver,
				Timeout => 30,
				Debug   => 1,
			);
			if (defined $smtp) {
				my $boundary = 'qwertry'.time;
				
				#$smtp->auth($login, $password) if (!$login);
				$smtp->mail($emailfrom);
				$smtp->to($To);
				$smtp->data();
				$smtp->datasend("To: $To\n");
				#$smtp->datasend("Subject: $host - TRAX $script_basename script execution is done\n");
				$smtp->datasend("Subject: TRAX $script_basename $status_of_execution\n");
				$smtp->datasend("MIME-Version: 1.0\n");
				$smtp->datasend("Content-type: multipart/mixed; boundary=\"======================_$boundary==_\"\n");
				$smtp->datasend("\n--======================_$boundary==_\n");
				$smtp->datasend("Content-Type: text/plain; charset=us-ascii\n");
				$smtp->datasend("\n");
				$smtp->datasend("TRAX $script_basename script execution is done\n");
				$smtp->datasend("Status: $status_of_execution\n");
				$smtp->datasend("Test machine: $host\n");
				$smtp->datasend("SMTP server: $smtpserver\n");
				$smtp->datasend("\n--======================_$boundary==_\n");
				$smtp->datasend("Content-Type: application/text; name=\"output.txt\"\n");
				$smtp->datasend("Content-Disposition: attachment; filename=\"output.txt\"\n");
				$smtp->datasend("\n");
				open(OUTPUT_FILE, $output_filename);
				while (my $line = <OUTPUT_FILE>) {
					$smtp->datasend($line);
				}
				close(OUTPUT_FILE);
				$smtp->datasend("--======================_$boundary==_--\n");
				
				
				$smtp->dataend();
				$smtp->quit;
			}
			else {
				print "can not find smtp mail";
			}
			
			# use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
			# my $zip = Archive::Zip->new();
			# my $file_member = $zip->addFile("$execution_data_location/output.txt", "output.txt");
			# unless ( $zip->writeToFileNamed("$execution_data_location/output.zip") == AZ_OK ) {
				# die 'write error';
			# }
			
			
		}
		print REPORT "$now_string	$script_basename	$status_of_execution\n";
	}
}
close REPORT;


#print join("\n", getOutStandingOrder(10));



sub getOutStandingOrder {
	my ($order_count) = @_;
	my $dbh = 1;
	#$ENV{'ORACLE_HOME'} = 'C:\oracle\ora92';
	#$ENV{'ORACLE_HOME'} = 'C:\oracle\product\10.2.0\client_1';
	$ENV{'ORACLE_HOME'} = 'C:\oracle\product\10.2.0\client_1';
	if ($dbh) {
		$dbh = DBI->connect("dbi:Oracle:$tnsName", $user, $passwd);
		print "dbh: $dbh\n";
	}
	my $SQL = qq{
		SELECT r.orig_pol_nbr
		FROM tr_policy_register r
		WHERE r.orig_loc_sys_id in (SELECT loc_sys_id FROM tr_customer_location WHERE cust_sys_id = $customerid AND cust_loc_nbr = 1)
		AND r.orig_uw_sys_id = $uw_sys_id
		AND r.orig_pol_nbr like '$form_id%'
		AND r.orig_prop_state_cd = (SELECT state_cd FROM tr_state_cd WHERE legecy_state_num = $legecy_state_num)
		AND r.pol_stat_cd = 'OUTSTANDING'
		AND NOT EXISTS (SELECT 1 FROM tr_policy WHERE upper(tr_policy.pol_nbr) = upper(r.orig_pol_nbr))
	};
	
	my $sth0 = $dbh->prepare($SQL);
	$sth0->execute();
	
	my $i=0;
	my @policy_numbers;
	ROW:while (my @row = $sth0->fetchrow_array) {
		push @policy_numbers, $row[0];
		last ROW if $i >= $order_count;
	}
	
	$sth0->finish();
	
	return @policy_numbers;
}