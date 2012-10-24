use Config::Tiny;


$ini_file_contents = qq{
[CommandArguments]
[ModemSpeed]
EnableModemSpeed=0
CustomModemSpeed=
EnableCustomModemSpeed=0
ModemSpeed=14400
[WEB]
CacheAlwaysCheckForNewerPages=No
StartRecordingIsDst=0
ScreenAvailWidth=1204
GraphBytesPerSecond=1
};


my $Config = Config::Tiny->new();
$Config = Config::Tiny->read_string($ini_file_contents);
print "WEB:ScreenAvailWidth: ".$Config->{'WEB'}->{'ScreenAvailWidth'}."\n";
#1204

$Config->{'WEB'}->{'ScreenAvailWidth'} = 23044;
print "WEB:ScreenAvailWidth: ".$Config->{'WEB'}->{'ScreenAvailWidth'}."\n";


$RTS
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

$Config->{'ThinkTime'}->{'Limit'} = 23;
$Config->{'ThinkTime'}->{'LimitFlag'} = 1;


$ActionLogic
$Config->{'Profile Actions'}->{'Profile Actions name'} eq 'vuser_init,CreateCPL,MainExec,CreateReport,SearchCPL,SearchPolicy,CreatePJG,Login,Logout,vuser_end'
$Config->{'RunLogicRunRoot'}->{'RunLogicActionOrder'} eq 'MainExec'
$Config->{'RunLogicRunRoot'}->{'MercIniTreeSons'} eq 'MainExec'





print "Config:\n";
print $Config->write_string();


__DATA__
use Config::IniFiles;
#my $cfg = new Config::IniFiles( -file => "RTS1.ini" );
my $cfg = new Config::IniFiles( -file => $ini_file_contents );

print "The value is ".$cfg->val('WEB','ScreenAvailWidth')."\n";
#1204

$cfg->setval('WEB','ScreenAvailWidth', '2305');
print "The value is ".$cfg->val('WEB','ScreenAvailWidth')."\n";

