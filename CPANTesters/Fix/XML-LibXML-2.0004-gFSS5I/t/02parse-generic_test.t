use strict;
use warnings;
use IO::File;
use Errno qw(ENOENT);

my $badfile2 = "does_not_exist.xml";
eval {
	open FILE, "<", $badfile2;
	#open FILE, $badfile2;
	close FILE;
};
print "opening does_not_exist.xml error message: $!\n";
print "opening does_not_exist.xml error message: $@\n";

$! = ENOENT;
my $err_string = "$!";
print "err_string: $err_string\n";