use strict;
use warnings;
use Net::SMTP::TLS;
use YAML qw(LoadFile);
use File::Slurp;

my $smtpConfig = LoadFile("gmail_template.yml");
my $mailer = new Net::SMTP::TLS(
	$smtpConfig->{'Host'},
	Hello   => $smtpConfig->{'Hello'},
	Port    => $smtpConfig->{'Port'},
	User    => $smtpConfig->{'User'},
	Password=> $smtpConfig->{'Password'},
	Timeout => 10,
	Debug   => 1,
);

my $from = 'xxx@gmail.com';
my $to   = 'x1@gmail.com;x2@gmail.com';
my $a    = 'addtl data';

my $zipFileContent  = read_file('attachment.zip', binmode => ':raw');
my $textFileContent = read_file('attachment.txt') ;

my @recipients = split(';', $to);
$mailer->mail("$from");
$mailer->to(@recipients);
$mailer->data;
$mailer->datasend("To: $to\n");
$mailer->datasend("Subject: subject\n");
$mailer->datasend("MIME-Version: 1.0\n");
$mailer->datasend("Content-Type: multipart/mixed; boundary=\"BLABLABLA\"\n");
$mailer->datasend("--BLABLABLA\n");
$mailer->datasend("Content-Type: text/plain\n\n"); # body
$mailer->datasend("$a\n");
$mailer->datasend("--BLABLABLA\n");
$mailer->datasend("Content-Type: application/text; name=attachment.txt\n\n");
$mailer->datasend($textFileContent);
$mailer->datasend("--BLABLABLA\n");
$mailer->datasend("Content-Type: application/zip; name=attachment.zip\n");
$mailer->datasend("Content-Transfer-Encoding: base64\n\n");
use MIME::Base64;
$mailer->datasend(encode_base64($zipFileContent));
$mailer->dataend();
$mailer->quit;

#Net::SMTP::TLS & YAML & File::Slurp are not P5.16.1 x86 core modules