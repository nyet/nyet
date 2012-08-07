use strict;
use v5.10.1;
use Cwd;
use Data::Dumper;
use File::Glob ':glob';
use Flickr::API;
use Flickr::Upload;
use XML::Parser::Lite::Tree::XPath;
use YAML::Syck;

my $conffile = "ida_leo-1LTR.conf";
my $conf = undef;
if (-f $conffile) {
	$conf = LoadFile($conffile);
}
else {
	die "$conffile is not found";
}

say "flickr_key: ".$conf->{flickr_key};
say "flickr_secret: ".$conf->{flickr_secret};
say "flickr_auth_token: ".$conf->{flickr_auth_token};
my $api = new Flickr::API({
	'key' => $conf->{flickr_key}, 
	'secret' => $conf->{flickr_secret},
});

open my $LOG, ">$0.log";
open my $HTML4, ">$0.4.html";
print {$HTML4} qq{<table border="0">\n};
close $HTML4;
open my $HTML5, ">$0.5.html";
print {$HTML5} qq{<table border="0">\n};
close $HTML5;
my $page_idx = 1;
while (1) {
	print "	page_idx: $page_idx\n";
	my $response = $api->execute_method('flickr.people.getPublicPhotos', {
		safe_search => 3,
		#user_id => '39912293@N00', #'@nyet',
		user_id => '45759651@N08', #'ida & leo',
		#user_id => $flickr_id,
		extras => 'url_sq, url_t, url_s, url_m, url_z, url_l, url_o, date_taken, description, tags, views',
		#description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, machine_tags, o_dims, media, path_alias, url_sq, url_t, url_s, url_m, url_z, url_l, url_o
		per_page => 100,
		page => $page_idx,
	});
	
	print {$LOG} Dumper($response);
	
	#http://search.cpan.org/~iamcal/XML-Parser-Lite-Tree-XPath-0.24/lib/XML/Parser/Lite/Tree/XPath.pm
	my $xpath = new XML::Parser::Lite::Tree::XPath($response->{tree});
	my $notes = $xpath->select_nodes('//photo');
	if ($#{$notes} < 0) {
		is_stop();
	}
	print "	note count: ".$#{$notes}."\n";
	
	open my $HTML4, ">>$0.4.html";
	open my $HTML5, ">>$0.5.html";
	#print LOG Dumper($notes)."\n";
	foreach my $note (@$notes) {
		#print {$LOG} Dumper($note)."\n";
		my $id    = $note->{attributes}->{id};
		my $views = $note->{attributes}->{views};

		if ($views =~ /4/) {
			print {$HTML4} qq{<tr><td>$views</td><td><a href="http://www.flickr.com/photos/ida_leo/$id" target="_newtab">$id</a></td></tr>\n};
		}
		elsif ($views =~ /5/) {
			print {$HTML5} qq{<tr><td>$views</td><td><a href="http://www.flickr.com/photos/ida_leo/$id" target="_newtab">$id</a></td></tr>\n};
		}
	}
	close $HTML4;
	close $HTML5;

	#'id' => '5730646509',
	#Large 		(900 x 900)	'url_l' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7_b.jpg',
	#Medium 640 	(640 x 640)	'url_z' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7_z.jpg',
	#Medium 500	(500 x 500)	'url_m' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7.jpg',
	#Small		(240 x 240)	'url_s' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7_m.jpg',
	#Thumbnail	(100 x 100)	'url_t' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7_t.jpg',
		#'height_t' => '100',
		#'width_t' => '100',
	#Square		(75 x 75)	'url_sq' => 'http://farm3.static.flickr.com/2647/5730646509_c83dee8bd7_s.jpg',
	$page_idx++;
	#exit;
}


close $LOG;

open my $HTML4, ">>$0.4.html";
print {$HTML4} qq{</table>\n};
close $HTML4;
open my $HTML5, ">>$0.5.html";
print {$HTML5} qq{</table>\n};
close $HTML5;

sub is_stop {
	if (-e "stop.txt") {
		print "stop.txt is detected, exiting...\n";
		exit 0;
	}
	else {
		my $dir = getcwd;
		print "cwd:$dir\n";
	}
	#TODO: check ICANHASINTERNET? stop if none detected
	exit;
}

__DATA__
#my $photoset_id = '72157625766911910'; # project 365/2011
#my $photoset_id = '72157628833049955'; # project 365/2012


