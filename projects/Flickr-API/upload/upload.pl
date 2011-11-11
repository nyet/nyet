use strict;
use v5.10.1;
use Cwd;
use Data::Dumper;
use File::Glob ':glob';
use Flickr::API;
use Flickr::Upload;
use XML::Parser::Lite::Tree::XPath;
use YAML::Syck;

my $conffile = "../nyet-prototype.conf";
my $conf = undef;
if (-f $conffile) {
	$conf = LoadFile($conffile);
}
else {
	die "$conffile is not found";
}
my $photoset_id = '72157625766911910';

say "flickr_key: ".$conf->{flickr_key};
say "flickr_secret: ".$conf->{flickr_secret};
say "flickr_auth_token: ".$conf->{flickr_auth_token};
my $ua = new Flickr::Upload({
	'key' => $conf->{flickr_key}, 
	'secret' => $conf->{flickr_secret},
});

open my $LOG, ">$0.log";
PICTURES:foreach my $file (bsd_glob('2upload/*')) {
	if (-f $file) {
		say $file;
		
		my $result = $ua->upload(
			'photo' => $file,
			'auth_token' => $conf->{flickr_auth_token},
			#'tags' => 'me myself eye',
			'is_public' => 0,
			'is_friend' => 1,
			'is_family' => 1,
			'async' => 0,
		);
		say "upload result: $result";
		
		my $response = $ua->execute_method('flickr.photosets.addPhoto', {
			auth_token => $conf->{flickr_auth_token},
			photoset_id  => $photoset_id,
			photo_id => $result,
		});
		say "add photo to set response: ".Dumper($response);
		say {$LOG} Dumper $response;
		
	}
	last PICTURES;
}
close $LOG;
