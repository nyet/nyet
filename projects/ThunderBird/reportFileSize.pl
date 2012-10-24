use strict;
use Data::Dumper;
use File::Glob ':glob';
use Net::SMTP::TLS;
use Sys::Hostname;
use Number::Format qw(:subs :vars);
$THOUSANDS_SEP   = '.';
$DECIMAL_POINT   = ',';
$INT_CURR_SYMBOL = 'DEM';


our $MAIL;
do 'C:\work\data\mail\xxx.txt';
print Dumper $MAIL;

my $host = hostname;

my $baseFolder = '%AppData%\Thunderbird\Profiles\7kjfwi9u.default\Mail\Local Folders';
my $text = "baseFolder: $baseFolder\n";
(my $baseFolderRegEx = $baseFolder) =~ s/(\W)/\\$1/g;
$text .= "\n";
$text .= scanFolder($baseFolder);

my $mailer = new Net::SMTP::TLS(
    $$MAIL{'Host'},
    Hello   => $$MAIL{'Hello'},
    Port    => $$MAIL{'Port'},
    User    => $$MAIL{'User'},
    Password=> $$MAIL{'Password'},
    Timeout => 10,
    Debug   => 1,
);

$mailer->mail($$MAIL{'User'});
$mailer->to("xxx\@gmail.com");
$mailer->data;
$mailer->datasend("To: xxx\@gmail.com\n");
$mailer->datasend("Subject: TBird \@ $host\n");
$mailer->datasend("\n");
$mailer->datasend("$text");
$mailer->dataend;
$mailer->quit;





sub scanFolder {
	my ($folder) = @_;
	my $info = "";
	foreach my $file (bsd_glob("$folder/*")) {
		if (-f $file) {
			if (($file!~/\.msf$/i)&&($file!~/stuff-\d+-\d+-\d+/i)) {
				my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
				if ($size > 20_000_000) {
					
					(my $ff = $file) =~ s/$baseFolderRegEx//;
					$info .= "$ff:".format_number($size)."\n";
				}
			}
		}
		else {
			$info .= scanFolder($file);
		}
	}
	return $info;
}
