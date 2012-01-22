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
#my $photoset_id = '72157625766911910'; # project 365/2011
my $photoset_id = '72157628833049955'; # project 365/2012

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
			'is_public' => 1,
			'is_friend' => 0,
			'is_family' => 0,
			'async' => 0,
		);
		say "upload result: $result";
		say {$LOG} Dumper $result;
		
		if ((length($result) > 5)&&($result =~ /^\d+$/)) {
			# when a picture is uploaded, it will return a picture id
			use File::Path;
			mkpath("2upload/uploaded") if !-d "2upload/uploaded";
			use File::Copy;
			move $file, "2upload/uploaded";
			
			my $response = $ua->execute_method('flickr.photosets.addPhoto', {
				auth_token => $conf->{flickr_auth_token},
				photoset_id  => $photoset_id,
				photo_id => $result,
			});
			#say "add photo to set response: ".Dumper($response);
			#say {$LOG} Dumper $response;
		}
	}
	last PICTURES;
}
close $LOG;
