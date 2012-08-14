use strict;
use CPAN::Mirror::Finder; #<- too fucking complicated (too many modules dependency) 
use Data::Dumper;
use LWP::UserAgent;

my $finder = CPAN::Mirror::Finder->new;
my @cpan_mirrors = $finder->find_cpan_mirrors;
print Dumper \@cpan_mirrors; 

#$VAR1 = [
#          bless( do{\(my $o = 'http://cpan.yimg.com/')}, 'URI::http' ),
#          bless( do{\(my $o = 'http://ppm.activestate.com/CPAN')}, 'URI::http' ),
#          bless( do{\(my $o = 'http://cpan.perl.org')}, 'URI::http' )
#        ];

my @cpan_mirrors = $finder->find_all_mirrors;
print Dumper \@cpan_mirrors; 

my $ua = LWP::UserAgent->new;
$ua->agent("FetchAlaNyet/0.1");
#my $req = HTTP::Request->new(GET => "cpan:src/latest.tar.gz");
my $req = HTTP::Request->new(GET => "cpan:modules/by-authors/id/I/IL/ILYAZ/modules/Data-Flow-1.02.tar.gz");
my $res = $ua->request($req);
if ($res->is_success) {
	open BIN, ">Data-Flow-1.02.tar.gz";
	binmode BIN;
	print BIN $res->content;
	close BIN;
}
else {
	print $res->status_line, "\n";
}

#foreach my $URL (@cpan_mirrors) {
#	print
#}
#use Mirror::YAML;

