# $Id$

##
# this test checks the parsing capabilities of XML::LibXML
# it relies on the success of t/01basic.t

use strict;
use warnings;

use Test::More tests => 1;
use IO::File;

use XML::LibXML::Common qw(:libxml);
use XML::LibXML::SAX;
use XML::LibXML::SAX::Builder;

use constant XML_DECL => "<?xml version=\"1.0\"?>\n";

use Errno qw(ENOENT);

my $badfile2 = "does_not_exist.xml";

my $parser = XML::LibXML->new();

# 1.2 PARSE A FILE


{
    # This is to fix https://rt.cpan.org/Public/Bug/Display.html?id=69248
    # Testing for localised error messages.
    $! = ENOENT;
    my $err_string = "$!";
    $! = 0;

    my $re = qr/\ACould not create file parser context for file "\Q$badfile2\E": \Q$err_string\E/;

    eval { $parser->parse_file($badfile2); };
    like($@, $re, "error parsing non-existent $badfile2");
    
    print "the error message: $@";
}


#the error message: Could not create file parser context for file "does_not_exist.xml": No error at t/02parse-191.t line 37.
