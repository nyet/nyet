use strict;
use MIME::Lite;
use Net::SMTP;

#my $smtpserver = 'smurf';
my $smtpserver = '10.146.98.76';
#my $smtpserver = 'localhost';
my $login = 'noone';
my $password = 'sqapassword';
my $emailfrom = 'qascript@fnf.com';

my $To = 'leo.susanto@fnf.com';



my $msg = MIME::Lite->new(
                 From    => $emailfrom,
                 To      => $To,
                 #Cc      => 'some@other.com, some@more.com',
                 Subject => 'A message with 2 parts...',
                 Type    => 'multipart/mixed'
                 );

    $msg->attach(Type     =>'TEXT',
                 Data     =>"Here's the GIF file you wanted"
                 );
    $msg->attach(Type     =>'image/gif',
                 Path     =>'activeperl.gif',
                 Filename =>'me.gif',
                 Disposition => 'attachment'
                 );

my $str = $msg->as_string;
	print $str;






		my $smtp = Net::SMTP->new($smtpserver,
			Timeout => 30,
			Debug   => 1,
		);
		if (defined $smtp) {
			$smtp->auth($login, $password);
			$smtp->mail($emailfrom);
			$smtp->to($To);
			$smtp->data();
			#$smtp->datasend("To: $To\n");
			#$smtp->datasend("Subject: SMTP test from BANGALORE\n");
			#$smtp->datasend("\n");
			$smtp->datasend($str);
			$smtp->dataend();
			$smtp->quit;
		}
		else {
			print "can not find smtp mail";
		}