use PPM::Make;
use ActivePerl::Config;

#my $repo = 'http://search.cpan.org/CPAN/authors/id/D/DC/DCONWAY/Acme-Bleach-1.12.tar.gz';
#my $repo = 'http://cpan.yahoo.com/modules/by-module/MIME/MIME-Lite-3.01.tar.gz';
#my $repo = 'http://cpan.yahoo.com/modules/by-module/Statistics/Statistics-Descriptive-Discrete-0.07.tar.gz';
my $repo = 'http://cpan.yahoo.com/modules/by-module/WebService/GRAY/WebService-Google-Reader-0.08.tar.gz';

#http://angrybots.com/ppm/as_p5_8_b822/x86/sandbox

#Statistics::Descriptive::Discrete
$PPM::Make::Util::build_dir = "build";

my $ppm = PPM::Make->new( 
	dist => $repo,
	arch => 'MSWin32-x86-multi-thread-5.8',
	os => 'MSWin32',
	binary => 'http://angrybots.com/ppm/as_p5_8_b822/x86/sandbox',
	force => 1,
	upload => {
		ppd => '/as_p5_8_b822/x86/sandbox',
		ar => '/as_p5_8_b822/x86/sandbox',
		zip => '/as_p5_8_b822/x86/sandbox/zips',
		host => 'angrybots.com', 
		user => 'xxx',
		passwd => 'xxx',
	},
	vsz => 1, # to add version number to zip file
	zipdist => 1,
);
$ppm->make_ppm();


