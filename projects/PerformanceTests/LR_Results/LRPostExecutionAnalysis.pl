use strict;
use v5.10;

use Env;
use Data::Dumper;
use File::Basename;
use Net::SMTP;
use Sys::Hostname;

use Win32::OLE;
use Win32::OLE::Enum;
use Win32::OLE::Variant;
use Win32::OLE::Const 'LoadRunner Automation Library';
use constant False  =>  Variant(VT_BOOL,'');
use constant True  =>  Variant(VT_BOOL,1);

my $name = shift @ARGV;

my $smtpserver = '';
my $login    = '';
my $password = '';

my $from = 'qascript@fnf.com';
my @to   = ('xx@fnf.com', 'xx1@fnf.com');

my $lrEngine = Win32::OLE->new('wlrun.LrEngine') or die "oops\n";
my $lrScenario = $lrEngine->Scenario();
my ($resultFolderName, $directories) = fileparse($lrScenario->{'ResultDir'});
#say $resultFolderName;
#say $directories;
my $text = "result: $resultFolderName\ndirectory: $directories\n";

my $hostname = hostname;

my $smtp = Net::SMTP->new($smtpserver,
	Timeout => 30,
	Debug   => 1,
);
if (defined $smtp) {
	#$smtp->auth($login, $password) if (!$login);
	$smtp->mail($from);
	$smtp->recipient(@to);
	$smtp->data();
	$smtp->datasend("To: ".join(',', @to)."\n");
	$smtp->datasend("Subject: Notification from $hostname: Loadtest ($resultFolderName) is done\n");
	$smtp->datasend("\n");
	$smtp->datasend("$text");
	$smtp->datasend("\n");
	#foreach my $key (sort keys %ENV) {
	#	$smtp->datasend("$key: $ENV{$key}\n");
	#}
	$smtp->datasend("Result folder: $name\n");
	$smtp->dataend();
	$smtp->quit;
}
else {
	print "can not find smtp mail";
}