use strict;
use v5.10;
use File::Basename;
use Win32::OLE;
use Win32::OLE::Enum;
use Win32::OLE::Variant;
use Data::Dumper;
#Win32::OLE->Option(Variant => 1);
use Win32::OLE::Const 'LoadRunner Automation Library';
use constant False  =>  Variant(VT_BOOL,'');
use constant True  =>  Variant(VT_BOOL,1);


my $lrEngine = Win32::OLE->new('wlrun.LrEngine') or die "oops\n";
say $lrEngine;

my $lrScenario = $lrEngine->Scenario();
my ($resultFolderName, $directories) = fileparse($lrScenario->{'ResultDir'});
say $resultFolderName;
say $directories;

say "Win32::OLE::LastError: ".Win32::OLE::LastError();

__DATA__

my $lrScenario = $lrEngine->Scenario();
my $rc = $lrScenario->new(0, lrVusers); # do not save previous, Regular vusers based scenario 
if ($rc != 0) {
	print "Win32::OLE::LastError: ".Win32::OLE::LastError()."\n";
	print "lrScenario->new(0, lrVusers):rc: $rc\n";
}

sleep(15);
print "Finished sleeping for 15 seconds\n";
$lrScenario->{'ResultDir'} = "C:\\Test11920022";
################################################################################
my $hostname = '10.53.3.78';
$rc = $lrScenario->Hosts->Add($hostname , 0); #Windows NT/95 
if ($rc != 0) {
	print "Win32::OLE::LastError: ".Win32::OLE::LastError()."\n";
	print "lrScenario->Hosts->Add:rc: $rc\n";
}
my $lrHost = $lrScenario->Hosts->Item($hostname);

$rc = $lrHost->Connect();
print "lrHost->Connect:rc: $rc\n";
my $status = 0;
CONNECTINGHOST:for (my $i=0;$i<60;$i++) {
	$status = $lrHost->Status();
	print "lrHost->Status: $status\n";
	# 1 - connecting
	# 6 - fail
	# 3 - ready

	last CONNECTINGHOST if $status == 3;
	sleep(2);
}
if ($status != 3) {
	die "Can not connect to $hostname\n";
}
################################################################################
my @groups = (
	{
		groupName => 'QueryByFile_Load',
		scriptLocation => 'C:\PerformanceTest\TRAX\Scripts_WAS7\QueryByFile_Load\QueryByFile_Load.usr',
		scriptName => 'QueryByFile_Load',
		profileActionsName => 'vuser_init,Login,QueryByFile,Logout,vuser_end', #default.usp
		runLogicActionOrder => 'Login,QueryByFile,Logout',
		mercIniTreeSons => 'Login,QueryByFile,Logout',
		vuserCount => 10,
	},	
	{
		groupName => 'CustomerSearchMaintain_Load',
		scriptLocation => 'C:\PerformanceTest\TRAX\Scripts_WAS7\CustomerSearchMaintain_Load\CustomerSearchMaintain_Load.usr',
		scriptName => 'CustomerSearchMaintain_Load',
		profileActionsName => 'vuser_init,Login,CustomerSearch,CustomerSearch_Detail,Logout,vuser_end',
		runLogicActionOrder => 'Login,CustomerSearch,CustomerSearch_Detail,Logout',
		mercIniTreeSons => 'Login,Logout,CustomerSearch,CustomerSearch_Detail',
		vuserCount => 10,
	},
	#{
	#	groupName => '',
	#	scriptLocation => '',
	#	scriptName => '',
	#	profileActionsName => '',
	#	runLogicActionOrder => '',
	#	mercIniTreeSons => '',
	#},
);

my $schedule1Name = Variant(VT_BSTR|VT_BYREF, 'Schedule 1');
foreach my $group (@groups) {
	say "scriptName: $group->{scriptName}";

	# add $group->{groupName} group
	my $scriptLocation = $group->{scriptLocation};
	my $scriptName = Variant(VT_BSTR|VT_BYREF, $group->{scriptName});
	
	{ # add $group->{scriptName} script
		#print "Scripts Count: ".$lrScenario->Scripts->Count()."\n";
		$rc = $lrScenario->Scripts->Add($scriptLocation, $scriptName);
		if ($rc != 0) {
			say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
			say "	lrScenario->Scripts->Add($scriptLocation, $scriptName):rc: $rc";
		}
		#print "Scripts Count: ".$lrScenario->Scripts->Count()."\n";
		#my $lrScript = $lrScenario->Scripts->Item($scriptName);
		#print "Win32::OLE::LastError: ".Win32::OLE::LastError()."\n";
		#print "lrScript->Name: ".$lrScript->Name()."\n";
	}
	#############################################################################
	my $groupName = Variant(VT_BSTR|VT_BYREF, $group->{groupName});
	
	{ # add $group->{groupName} group
		$rc = $lrScenario->Groups->Add($groupName);
		if ($rc != 0) {
			say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
			say "	lrScenario->Groups->Add:rc: $rc";
		}
		$rc = $lrScenario->Groups->Item($groupName)->AddVusers($scriptName, $hostname, $group->{vuserCount});
		if ($rc != $group->{vuserCount}) {
			say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
			say "	lrScenario->Groups->Item($groupName)->AddVusers:rc: $rc";
		}
	}
	#############################################################################
	{ # change $group->{groupName} group run time settings
		my $RTS = Variant(VT_BSTR|VT_BYREF, '');
		my $ActionLogic = Variant(VT_BSTR|VT_BYREF, '');
		$rc = $lrScenario->Groups->Item($groupName)->GetRunTimeSettings($RTS, $ActionLogic);
		if ($rc != 0) {
			say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
			say "	lrScenario->Groups->Item($groupName)->GetRunTimeSettings:rc: $rc";
		}
		
		#$ActionLogic =~ s/RunLogicNumOfIterations=\"\d+\"/RunLogicNumOfIterations="1"/;
		
		use Config::Tiny;
		my $Config = Config::Tiny->new();
		##########################################################################
		open FILE, ">$groupName.ActionLogic1.txt";
		print FILE $ActionLogic;
		close FILE;
		
		$ActionLogic =~ s/\\r\\n/\n/g;
		$Config = Config::Tiny->read_string($ActionLogic);
		say "	RunLogicRunRoot:RunLogicNumOfIterations: ".$Config->{'RunLogicRunRoot'}->{'RunLogicNumOfIterations'};
		$Config->{'RunLogicRunRoot'}->{'RunLogicNumOfIterations'} = 100; # testing 
		if ($Config->{'Profile Actions'}->{'Profile Actions name'} ne $group->{profileActionsName}) {
			print "	\$Config->{'Profile Actions'}->{'Profile Actions name'} is not correct\n";
		}
		#if ($Config->{'RunLogicRunRoot'}->{'RunLogicActionOrder'} ne $group->{runLogicActionOrder}) {
		#	print "	\$Config->{'RunLogicRunRoot'}->{'RunLogicActionOrder'} is not correct\n";
		#}
		#if ($Config->{'RunLogicRunRoot'}->{'MercIniTreeSons'} ne $group->{mercIniTreeSons}) {
		#	print "	\$Config->{'RunLogicRunRoot'}->{'MercIniTreeSons'} is not correct\n";
		#}
		$ActionLogic = $Config->write_string();
		$ActionLogic =~ s/\n/\\r\\n/g;
		
		open FILE, ">$groupName.ActionLogic2.txt";
		print FILE $ActionLogic;
		close FILE;
		##########################################################################
		open FILE, ">$groupName.RTS1.txt";
		print FILE $RTS;
		close FILE;
		
		$RTS =~ s/\\r\\n/\n/g;
		$Config = Config::Tiny->read_string($RTS);
		$Config->{'WEB'}->{'EnableIPCache'} = "Yes";
		$Config->{'WEB'}->{'ResourcePageTimeoutIsWarning'} = "No";
		$Config->{'WEB'}->{'ParseHtmlContentType'} = "TEXT";
		$Config->{'WEB'}->{'ConnectTimeout'} = 600;
		$Config->{'WEB'}->{'ReceiveTimeout'} = 600;
		$Config->{'WEB'}->{'PageDownloadTimeout'} = 600;
		$Config->{'WEB'}->{'NetBufSize'} = 12288;
		$Config->{'WEB'}->{'Retry401ThinkTime'} = 0;
		$Config->{'WEB'}->{'DomMemBlockSize'} = 16384;
		$Config->{'WEB'}->{'DomMaximumTimeout'} = 5;
		$Config->{'WEB'}->{'DomMaximumAccumulativeTimeout'} = 15;
		$Config->{'WEB'}->{'ZlibHeadersInCompressedRequestBody'} = "Yes";
		#Parameters
		$Config->{'Log'}->{'MsgClassData'} = 1;
		#
		$Config->{'ThinkTime'}->{'Limit'} = 23;
		$Config->{'ThinkTime'}->{'LimitFlag'} = 1;
		$RTS = $Config->write_string();
		$RTS =~ s/\n/\\r\\n/g;
		
		open FILE, ">$groupName.RTS2.txt";
		print FILE $RTS;
		close FILE;
		##########################################################################
		$rc = $lrScenario->Groups->Item($groupName)->SetRunTimeSettings($RTS, $ActionLogic);
		if ($rc != 0) {
			say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
			say "	lrScenario->Groups->Item($groupName)->GetRunTimeSettings:rc: $rc";
		}
	}
	

}

my $scheduleXML = Variant(VT_BSTR|VT_BYREF, qq{<?xml version="1.0" encoding="utf-16"?>
<LoadTest>
  <Schedulers>
    <CurrentSchedulerId>1</CurrentSchedulerId>
    <StartMode>
      <StartModeType>Immediately</StartModeType>
      <StartModes>
        <Immediately />
        <DelayAfterLTStart>0</DelayAfterLTStart>
        <StartAt>2011-09-28T16:42:33.2579742-04:00</StartAt>
      </StartModes>
    </StartMode>
    <Scheduler ID="1">
      <Name>Schedule 1</Name>
      <Manual>
        <SchedulerType>Groups</SchedulerType>
        <Global>
          <Scheduling>
            <IsDefaultScheduler>true</IsDefaultScheduler>
            <DynamicScheduling>
              <RampUp>
                <StartCondition>
                  <PrevAction />
                </StartCondition>
                <Batch>
                  <Count>2</Count>
                  <Interval>15</Interval>
                </Batch>
                <TotalVusersNumber>20</TotalVusersNumber>
              </RampUp>
              <Duration>
                <StartCondition>
                  <PrevAction />
                </StartCondition>
                <RunFor>300</RunFor>
              </Duration>
              <RampDownAll>
                <StartCondition>
                  <PrevAction />
                </StartCondition>
                <Batch>
                  <Count>5</Count>
                  <Interval>30</Interval>
                </Batch>
              </RampDownAll>
            </DynamicScheduling>
          </Scheduling>
        </Global>
        <Groups>
          <InitAllBeforeStart>false</InitAllBeforeStart>
          <GroupScheduler>
            <GroupName>querybyfile_load</GroupName>
            <StartupMode>
              <StartAtScenarioBegining />
            </StartupMode>
            <Scheduling>
              <IsDefaultScheduler>true</IsDefaultScheduler>
              <DynamicScheduling>
                <RampUp>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <Batch>
                    <Count>1</Count>
                    <Interval>1</Interval>
                  </Batch>
                  <TotalVusersNumber>10</TotalVusersNumber>
                </RampUp>
                <Duration>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <RunFor>600</RunFor>
                </Duration>
                <RampDownAll>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <Batch>
                    <Count>1</Count>
                    <Interval>5</Interval>
                  </Batch>
                </RampDownAll>
              </DynamicScheduling>
            </Scheduling>
          </GroupScheduler>
          <GroupScheduler>
            <GroupName>customersearchmaintain_load</GroupName>
            <StartupMode>
              <StartAtScenarioBegining />
            </StartupMode>
            <Scheduling>
              <IsDefaultScheduler>true</IsDefaultScheduler>
              <DynamicScheduling>
                <RampUp>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <Batch>
                    <Count>2</Count>
                    <Interval>2</Interval>
                  </Batch>
                  <TotalVusersNumber>10</TotalVusersNumber>
                </RampUp>
                <Duration>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <RunFor>720</RunFor>
                </Duration>
                <RampDownAll>
                  <StartCondition>
                    <PrevAction />
                  </StartCondition>
                  <Batch>
                    <Count>5</Count>
                    <Interval>2</Interval>
                  </Batch>
                </RampDownAll>
              </DynamicScheduling>
            </Scheduling>
          </GroupScheduler>
        </Groups>
      </Manual>
    </Scheduler>
  </Schedulers>
</LoadTest>});
my $pErrStr = Variant(VT_BSTR|VT_BYREF, '');
say "lrScenario->ManualScheduler->GetCurrentSchedule()->SetScheduleData()";
$rc = $lrScenario->ManualScheduler->GetCurrentSchedule()->SetScheduleData($scheduleXML, $pErrStr);
say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
say "	rc:$rc";
say "	scheduleXML:$scheduleXML";
say "	pErrStr:$pErrStr";




exit;
#say "lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule)";
#$rc = $lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule); #LrManualScheduleMode -> lrGroupSchedule = 1
say "lrScenario->ManualScheduler->SetScheduleMode(1, lrGroupSchedule)";
$rc = $lrScenario->ManualScheduler->SetScheduleMode(1, lrGroupSchedule); #LrManualScheduleMode -> lrGroupSchedule = 1
say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
say "	rc:$rc";

my $scheduleXML = Variant(VT_BSTR|VT_BYREF, '');
my $pErrStr = Variant(VT_BSTR|VT_BYREF, '');
say "lrScenario->ManualScheduler->GetCurrentSchedule()->GetScheduleData()";
$rc = $lrScenario->ManualScheduler->GetCurrentSchedule()->GetScheduleData($scheduleXML, $pErrStr);
say "	Win32::OLE::LastError: ".Win32::OLE::LastError();
say "	rc:$rc";
say "	scheduleXML:$scheduleXML";
say "	pErrStr:$pErrStr";
exit;

say "lrScenario->ManualScheduler->GetCurrentSchedule()->{Duration}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{Duration};
$lrScenario->ManualScheduler->GetCurrentSchedule()->{Duration} = 1200;
say "lrScenario->ManualScheduler->GetCurrentSchedule()->{Duration}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{Duration};

say "lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupBatchSize}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupBatchSize};
$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupBatchSize} = 1;
say "lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupBatchSize}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupBatchSize};

say "lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupTimeInterval}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupTimeInterval};
$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupTimeInterval} = 5;
say "lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupTimeInterval}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{LoadRampupTimeInterval};

say "lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupBatchSize}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupBatchSize};
$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupBatchSize} = 2;
say "lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupBatchSize}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupBatchSize};

say "lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupTimeInterval}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupTimeInterval};
$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupTimeInterval} = 3;
say "lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupTimeInterval}:".$lrScenario->ManualScheduler->GetCurrentSchedule()->{RampupTimeInterval};

exit;
################################################################################
say "##########################################";
#my $lrManualScheduleData = $lrScenario->ManualScheduler->GetCurrentSchedule();
#GetScheduleData:
#Duration:         300
#DurationMode:     0
#LoadDurationMode: 0
#LoadRampupMode:   0
#RampdownMode:     0
#RampupMode:       0
#StartTimeMode:

my $lrManualScheduleData = $lrScenario->ManualScheduler->Schedule('Schedule 1');
say "RampupMode:       ".$lrManualScheduleData->RampupMode(); 	#LrRampupMode, 
																#lrRampupByGroupBatches = 1, Load Vusers by batches in 'By Group' mode
																#lrRampupByScenarioBatches = 2, Load Vusers by batches in 'By Scenario' mode
																#lrRampupSimultaneously = 0, Load all Vusers simultaneously
say "GetScheduleData: ".$lrManualScheduleData->GetScheduleData();
say "Duration:         ".$lrManualScheduleData->Duration();
say "DurationMode:     ".$lrManualScheduleData->DurationMode();	#LrDurationMode, lrRunUntilCompletion = 0, lrRunForTime = 1, lrRunIndefinitely = 2
say "LoadDurationMode: ".$lrManualScheduleData->LoadDurationMode(); #LrInitDurationMode, lrStartRampUpImmediately = 0, lrStartRampUpWithDelay = 1
say "LoadRampupMode:   ".$lrManualScheduleData->LoadRampupMode(); #LrInitRampupMode, lrInitRampupByBatches = 1, lrInitRampupDisabled = 0, lrInitRampupSimultaneously = 2
say "RampdownMode:     ".$lrManualScheduleData->RampdownMode(); #LrRampdownMode, lrRampdownByBatches = 1, lrRampdownSimultaneously = 0
say "StartTimeMode:    ".$lrManualScheduleData->StartTimeMode(); 	#LrGroupStartTimeMode
																	#lrStartAfterGroup = 2, Start after specified group finishes
																	#lrStartAtScenarioBeginning = 0, Start at the Scenario beginning
																	#lrStartDurationAfterScenarioBeginning = 1, Start duration after the Scenario beginning

exit;
################################################################################
my $schedule1Name = Variant(VT_BSTR|VT_BYREF, 'Schedule 1');
if (0) { # doesnt work, schedule 1 can not be set to group schedule
	say "lrScenarioSchedule: ".lrScenarioSchedule;
	say "lrGroupSchedule: ".lrGroupSchedule;
	print "\$lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule):";
	$lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule); #LrManualScheduleMode ->  lrGroupSchedule = 1, lrScenarioSchedule = 0
	say "Win32::OLE::LastError: ".Win32::OLE::LastError();
}	
#say "ScenarioStartTimeMode: ".$lrScenario->ManualScheduleData->{'ScenarioStartTimeMode'}; #Can't use an undefined value as a HASH reference at LR.pl line 185.
#say "ScenarioStartTimeMode: ".$lrScenario->ManualScheduler->{'ScenarioStartTimeMode'}; #ScenarioStartTimeMode: 0
#my $lrManualScheduleData = $lrScenario->ManualScheduler->GetCurrentSchedule();
#say "\$lrManualScheduleData->{'Duration'}: ".$lrManualScheduleData->{'Duration'};
#exit;
my $scheduleName = Variant(VT_BSTR|VT_BYREF, 'Schedule123');

my $lrManualScheduleData = $lrScenario->ManualScheduler->AddSchedule($scheduleName, lrGroupSchedule); # Scenario schedule mode
if (!$lrManualScheduleData) {
	say "Win32::OLE::LastError: ".Win32::OLE::LastError();
	say "lrScenario->ManualScheduler->AddSchedule:rc: $rc";
}
$rc = $lrScenario->ManualScheduler->SetCurrentSchedule($scheduleName);
if ($rc != 0) {
	say "Win32::OLE::LastError: ".Win32::OLE::LastError();
	say "lrScenario->ManualScheduler->SetCurrentSchedule:rc: $rc";
}
print "\$lrScenario->ManualScheduler->SetScheduleMode($scheduleName, lrGroupSchedule):";
$lrScenario->ManualScheduler->SetScheduleMode($scheduleName, lrGroupSchedule); #LrManualScheduleMode ->  lrGroupSchedule = 1, lrScenarioSchedule = 0
say "Win32::OLE::LastError: ".Win32::OLE::LastError();

$lrManualScheduleData->LetProperty('InitAllBeforeRun', 'QueryByFile_Load', True);
$lrManualScheduleData->LetProperty('DurationMode', 'QueryByFile_Load', 1);         # Run for specified time 
$lrManualScheduleData->LetProperty('Duration', 'QueryByFile_Load', (60 * 60));       # 1 hours in seconds

$lrManualScheduleData->LetProperty('RampupBatchSize', 'QueryByFile_Load', 1);      # Vusers
$lrManualScheduleData->LetProperty('RampupMode', 'QueryByFile_Load', lrRampupByGroupBatches); #  Ramp up by Group batches. 
$lrManualScheduleData->LetProperty('RampupTimeInterval', 'QueryByFile_Load', 5);   # seconds?

$lrManualScheduleData->LetProperty('RampdownBatchSize', 'QueryByFile_Load)', 1);    # Vusers
$lrManualScheduleData->LetProperty('RampdownMode', 'QueryByFile_Load)', lrRampdownByBatches); #  Ramp up by Group batches.   
$lrManualScheduleData->LetProperty('RampdownTimeInterval', 'QueryByFile_Load)', 5); # seconds?

$rc = $lrScenario->ManualScheduler->{'ScenarioStartTimeMode'} = 0; # Start scenario without delay 

say "$schedule1Name: ".$lrScenario->ManualScheduler->Schedule($schedule1Name)->{'Duration'};
say "$scheduleName: ".$lrScenario->ManualScheduler->Schedule($scheduleName)->{'Duration'};

print "\$lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule):";
$lrScenario->ManualScheduler->SetScheduleMode($schedule1Name, lrGroupSchedule); #LrManualScheduleMode ->  lrGroupSchedule = 1, lrScenarioSchedule = 0
say "Win32::OLE::LastError: ".Win32::OLE::LastError();

my $i = 0;
my $lrGroups = Win32::OLE::Enum->new($lrScenario->Groups);
foreach my $lrGroup ($lrGroups->All) {
	print "$i:".$lrGroup->Name."\n";
	#DependantGroup
	
	#GetMaxVuserId
	$i++;
}

#$lrScenario->Start();


__DATA__
Duration
DurationMode
InitialLoadDuration
InitialLoadPercentage
LoadDuration
LoadDurationMode
LoadRampupBatchSize
LoadRampupMode
LoadRampupTimeInterval
RampdownBatchSize
RampdownMode
RampdownTimeInterval
RampupBatchSize
RampupMode
RampupTimeInterval
StartTimeDelay
StartTimeMode

		With eng.Scenario.ManualScheduler
		'Get a LrManualScheduleData object by adding a schedule
        Set ScheduleData = .AddSchedule(ScheduleName, _
                                    lrScenarioSchedule)
        If IsNull(ScheduleData) Then
             MsgBox "Failed to get schedule data"
             NewManualScheduleData = False
             Exit Function
        End If

        ' Make the schedule active
        .SetCurrentSchedule ScheduleName

        ' The alternatives are schedule mode and group mode
        .SetScheduleMode ScheduleName, lrScenarioSchedule

        'Start in an hour
        dDate = DateAdd("h", 1, Now)
        YY = Year(dDate): mon = Month(dDate): Dd = Day(dDate)
        Hh = Hour(dDate): Min = Minute(dDate): Ss = Second(dDate)

        .ScenarioStartTimeMode = lrAtTimeDelay
        rc = .SetScenarioStartTime(YY, mon, Dd, Hh, Min, Ss)

        'Confirm times
        .GetScenarioStartTime YY, mon, Dd, Hh, Min, Ss
        Debug.Print YY, mon, Dd, Hh, Min, Ss

        Debug.Print .ScenarioStartTimeDelay

    End With 'eng.Scenario.ManualScheduler

   'Set the schedule data
    With ScheduleData
        .InitAllBeforeRun = True
        'DurationMode can also be lrRunForTime or lrRunIndefinitely
        .DurationMode = lrRunUntilCompletion
        .Duration = (60 * 5) ' 5 minutes in seconds
        .RampupBatchSize = 8 'Vusers
        .RampdownBatchSize = 8 'Vusers
        .RampdownMode = lrRampdownByBatches
        .RampupMode = lrRampdownByBatches
        .RampdownTimeInterval = 1 'Minutes
        .RampupTimeInterval = 1 'Minutes
    End With ' ScheduleData

	 
################################################################################

    ' AddVusersEx can only be called after the group
    ' has been populated with a test and host.
    ' The call to AddVusers immediately above assigns
    ' the test (scriptName) and host (LOADGENERATOR).
    ' This call adds users to an existing group:
    rc = .Groups.Item(GroupName).AddVusersEx(numOfVusers)

    'Alternatively, the two extended methods can be used as
    ' a pair to create a group with the test and host using
    ' AddEx, then add users with AddVusersEx
    aGroupName = GroupName & "_a"
    rc = .Groups.AddEx(aGroupName, scriptName, LOADGENERATOR)
    rc = .Groups.Item(aGroupName).AddVusersEx(numOfVusers)






print "wait";<>;

#Set oScen = LrEngine.Scenario

'How many vusers allowed for Web protocol?
rc = eng.GetVuserTypeLicenseLimit("WebLogic", LicenseLimit)


say "Duration:         ".$lrManualScheduleData->Duration();
say "DurationMode:     ".$lrManualScheduleData->DurationMode();	#LrDurationMode, lrRunUntilCompletion = 0, lrRunForTime = 1, lrRunIndefinitely = 2
say "LoadDurationMode: ".$lrManualScheduleData->LoadDurationMode(); #LrInitDurationMode, lrStartRampUpImmediately = 0, lrStartRampUpWithDelay = 1
say "LoadRampupMode:   ".$lrManualScheduleData->LoadRampupMode(); #LrInitRampupMode, lrInitRampupByBatches = 1, lrInitRampupDisabled = 0, lrInitRampupSimultaneously = 2
say "RampdownMode:     ".$lrManualScheduleData->RampdownMode(); #LrRampdownMode, lrRampdownByBatches = 1, lrRampdownSimultaneously = 0
say "RampupMode:       ".$lrManualScheduleData->RampupMode(); 	#LrRampupMode, 
																#lrRampupByGroupBatches = 1, Load Vusers by batches in 'By Group' mode
																#lrRampupByScenarioBatches = 2, Load Vusers by batches in 'By Scenario' mode
																#lrRampupSimultaneously = 0, Load all Vusers simultaneously
say "StartTimeMode:    ".$lrManualScheduleData->StartTimeMode(); 	#LrGroupStartTimeMode
																	#lrStartAfterGroup = 2, Start after specified group finishes
																	#lrStartAtScenarioBeginning = 0, Start at the Scenario beginning
																	#lrStartDurationAfterScenarioBeginning = 1, Start duration after the Scenario beginning
