use strict;
use Cwd;
use Data::Dumper;
use File::Glob ':glob';
use Flickr::API;
use XML::Parser::Lite::Tree::XPath;

my $api = new Flickr::API({
	key => 'xzxx',
	secret => 'xxxx'
}); 

open LOG, ">$0.log";
open my $DWLOG, ">$0.download.log";
			
my $page_idx = 1;
PAGE:while (1) {
	print "	page_idx: $page_idx\n";
	my $response = $api->execute_method('flickr.people.getPublicPhotos', {
		safe_search => 3,
		user_id => '39912293@N00', #'@nyet',
		#user_id => '45759651@N08', #'ida & leo',
		#user_id => $flickr_id,
		extras => 'url_sq, url_t, url_s, url_m, url_z, url_l, url_o, date_taken, description',
		#description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_m, url_z, url_l, url_o
		per_page => 100,
		page => $page_idx,
	});
	
	print LOG Dumper($response);
	
	#http://search.cpan.org/~iamcal/XML-Parser-Lite-Tree-XPath-0.24/lib/XML/Parser/Lite/Tree/XPath.pm
	my $xpath = new XML::Parser::Lite::Tree::XPath($response->{tree});
	my $notes = $xpath->select_nodes('//photo');
	if ($#{$notes} < 0) {
		last PAGE;
	}
	
	#print LOG Dumper($notes)."\n";
	foreach my $note (@$notes) {
		print LOG Dumper($note->{attributes})."\n";
		push my @logdata, $note->{attributes}->{owner};
		push @logdata, $note->{attributes}->{id};
		push @logdata, $note->{attributes}->{datetaken};
		my ($url, $url_type, $width, $height);
		if (exists $note->{attributes}->{url_sq}) {
			$url_type = "url_sq";
			$url    = $note->{attributes}->{url_sq};
			$width  = $note->{attributes}->{width_sq};
			$height = $note->{attributes}->{height_sq};
		}
		elsif (exists $note->{attributes}->{url_o}) {
			$url_type = "url_o";
			$url      = $note->{attributes}->{url_o};
			$width    = $note->{attributes}->{width_o};
			$height   = $note->{attributes}->{height_o};
		}
		elsif (exists $note->{attributes}->{url_l}) {
			$url_type = "url_l";
			$url    = $note->{attributes}->{url_l};
			$width  = $note->{attributes}->{width_l};
			$height = $note->{attributes}->{height_l};
		}
		elsif (exists $note->{attributes}->{url_z}) {
			$url_type = "url_z";
			$url    = $note->{attributes}->{url_z};
			$width  = $note->{attributes}->{width_z};
			$height = $note->{attributes}->{height_z};
		}
		push @logdata, $url_type, $width, $height, $url, "||".$note->{attributes}->{description}."||";
		print {$DWLOG} join("\t", @logdata)."\n";
		
		if (($url ne "N/A")&&($url =~ /\/([^\/]+)$/)) {
			my $filename = $1;
			$filename =~ s/(\?.+)//;
			system qq{lwp-download "$url" "$filename"};
		}
	}
	

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
}

close LOG;
close $DWLOG;
