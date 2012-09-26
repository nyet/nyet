use strict;
use warnings;
use Net::SMTP::TLS;
use YAML qw(LoadFile);

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
my $to   = 'xxx@to.com';
my $a    = 'addtl data';

$mailer->mail("$from");
$mailer->to("$to");
$mailer->data;
$mailer->datasend("To: $to\n");
$mailer->datasend("Subject: subject\n");
$mailer->datasend("\n");
$mailer->datasend("Additional data: $a");
$mailer->dataend;
$mailer->quit;

#Net::SMTP::TLS & YAML are not P5.16.1 x86 core modules