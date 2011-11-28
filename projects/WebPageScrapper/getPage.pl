use strict;
use v5.10;
use Data::Dumper;
use File::Compare;
use File::Copy;
use File::Path;
use Net::Twitter;
use YAML::Syck;
# TODO
# 1. test for link that gives 404
# 2. parse the content of sysinternals
# 3. parse the content of dilbert

my $logfile = "$0.log";
my $conffile = "$0.conf";
my $pagesfile = "$0.pages";

my $conf = undef;
if (-f $conffile) {
	$conf = LoadFile($conffile);
}

if (!$conf->{twitter_consumer_key}) {
	die "twitter_consumer_key is not defined";
}

my $nt = Net::Twitter->new(
    traits              => [qw/API::REST OAuth API::Search WrapError/],
    consumer_key        => $conf->{twitter_consumer_key},
    consumer_secret     => $conf->{twitter_consumer_secret},
    access_token        => $conf->{twitter_access_token},
    access_token_secret => $conf->{twitter_access_token_secret},
);

my %months = (
	Jan=>1, Feb=>2, Mar=>3, Apr=>4,  May=>5,  Jun=>6, 
	Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12,
	January=>1,  February=>2,  March=>3, 
	April=>4,    May=>5,       June=>6, 
	July=>7,     August=>8,    September=>9, 
	October=>10, November=>11, December=>12,
);

my $time = time;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year+=1900;
$mon++;
$mon  = "0$mon"  if length($mon)==1;
$mday = "0$mday" if length($mday)==1;
$hour = "0$hour" if length($hour)==1;
$min  = "0$min"  if length($min)==1;
$sec  = "0$sec"  if length($sec)==1;
my $timestamp = "$year-$mon-$mday";

my $previousUpdate = 0;
if ($conf->{lastUpdate}) {
	$previousUpdate = $conf->{lastUpdate};
}
tee("previousUpdate: $previousUpdate");
tee("current:        $time");
$conf->{lastUpdate} = $time;
DumpFile($conffile, $conf);

my %grab = (
	BorrowLenses => {
		ForSale => {
			Every => 24*3600-600,
			URL => 'http://www.borrowlenses.com/category/For_Sale',
			File => 'www.borrowlenses.com/category/For_Sale',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	PortableApps => {
		Frhed => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/development/frhed_portable',
			File => 'portableapps.com/apps/development/frhed_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FileZilla => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/filezilla_portable',
			File => 'portableapps.com/apps/internet/filezilla_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		NotepadPP => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/development/notepadpp_portable',
			File => 'portableapps.com/apps/development/notepadpp_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Pidgin => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/pidgin_portable',
			File => 'portableapps.com/apps/internet/pidgin_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		PuTTY => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/putty_portable',
			File => 'portableapps.com/apps/internet/putty_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Skype => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/skype_portable',
			File => 'portableapps.com/apps/internet/skype_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		SqliteDataBaseBrowser => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/development/sqlite_database_browser_portable',
			File => 'portableapps.com/apps/development/sqlite_database_browser_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		VLC => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/music_video/vlc_portable',
			File => 'portableapps.com/apps/music_video/vlc_portable',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	gnuwin32 => {
		grep => {
			Every => 7*24*3600-600,
			URL => 'http://gnuwin32.sourceforge.net/packages/grep.htm',
			File => 'gnuwin32.sourceforge.net\packages\grep.htm',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	arcamax => {
		garfield => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/garfield',
			File => 'www.arcamax.com/thefunnies/garfield',
			TimeStamp => "$year-$mon-$mday",
		},
		mutts => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/mutts',
			File => 'www.arcamax.com/thefunnies/mutts',
			TimeStamp => "$year-$mon-$mday",
		},
		ninechickweedlane => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/ninechickweedlane',
			File => 'www.arcamax.com/thefunnies/ninechickweedlane',
			TimeStamp => "$year-$mon-$mday",
		},
		nonsequitur => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/nonsequitur',
			File => 'www.arcamax.com/thefunnies/nonsequitur',
			TimeStamp => "$year-$mon-$mday",
		},
		pearlsbeforeswine => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/pearlsbeforeswine',
			File => 'www.arcamax.com/thefunnies/pearlsbeforeswine',
			TimeStamp => "$year-$mon-$mday",
		},
		thebarn => {
			Every => 24*3600-600,
			URL => 'http://www.arcamax.com/thefunnies/thebarn',
			File => 'www.arcamax.com/thefunnies/thebarn',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	sysinternals => {
		Autologon => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb963905',
			File => 'technet.microsoft.com/en-us/sysinternals/bb963905',
			TimeStamp => "$year-$mon-$mday",
		},
		Autoruns => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb963902',
			File => 'technet.microsoft.com/en-us/sysinternals/bb963902',
			TimeStamp => "$year-$mon-$mday",
		},
		Disk2vhd => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/ee656415',
			File => 'technet.microsoft.com/en-us/sysinternals/ee656415',
			TimeStamp => "$year-$mon-$mday",
		},
		DiskUsage => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896651',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896651',
			TimeStamp => "$year-$mon-$mday",
		},
		FindLinks => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/hh290814',
			File => 'technet.microsoft.com/en-us/sysinternals/hh290814',
			TimeStamp => "$year-$mon-$mday",
		},
		Handle => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896655',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896655',
			TimeStamp => "$year-$mon-$mday",
		},
		Junction => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896768',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896768',
			TimeStamp => "$year-$mon-$mday",
		},
		ListDLLs => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896656',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896656',
			TimeStamp => "$year-$mon-$mday",
		},
		ProcessExplorer => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896653',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896653',
			TimeStamp => "$year-$mon-$mday",
		},
		ProcessMonitor => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896645',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896645',
			TimeStamp => "$year-$mon-$mday",
		},
		PsTools => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb896649',
			File => 'technet.microsoft.com/en-us/sysinternals/bb896649',
			TimeStamp => "$year-$mon-$mday",
		},
		VMMap => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/dd535533',
			File => 'technet.microsoft.com/en-us/sysinternals/dd535533',
			TimeStamp => "$year-$mon-$mday",
		},
		SysinternalsSuite => {
			Every => 7*24*3600-600,
			URL => 'http://technet.microsoft.com/en-us/sysinternals/bb842062',
			File => 'technet.microsoft.com/en-us/sysinternals/bb842062',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	dilbert => {
		dilbert => {
			Every => 24*3600-600,
			URL => 'http://dilbert.com',
			File => 'dilbert.com/index.html',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	cmegroup => {
		'light-sweet-crude' => {
			Every => 1800-600,
			URL => 'http://www.cmegroup.com/trading/energy/crude-oil/light-sweet-crude.html',
			File => 'www.cmegroup.com/trading/energy/crude-oil/light-sweet-crude.html',
			TimeStamp => "$year-$mon-$mday-$hour$min",
		},
	},
	#
	#http://www.cmegroup.com/trading/energy/crude-oil/crude-oil-volatility-index-vix-futures.html
);

#Get Webpage
my %Pages = ();
foreach my $website (keys %grab) {
	foreach my $webpage (keys %{$grab{$website}}) {
		my $previousUpdate = $conf->{Pages}{$website}{$webpage}{Lastupdate};
		if ($time-$previousUpdate > $grab{$website}{$webpage}{Every}) {
			my $webpageURL = $grab{$website}{$webpage}{URL};
			my $cmd = qq{wget -p -k -H --user-agent="Mozilla/5.0 (Linux; U; Android 0.5; en-us) AppleWebKit/522+ (KHTML, like Gecko) Safari/419.3" $webpageURL};
			mkpath("wget") if !-d "wget";
			my $backupdir = $year;
			chdir("wget");
			system($cmd);
			chdir("..");
			tee("wget: $webpageURL");
			#Backup the source
			mkpath("$website/$backupdir") if !-d "$website/$backupdir";
			my $bkupFile = "$website/$backupdir/$webpage.$grab{$website}{$webpage}{TimeStamp}.txt";
			copy("wget/".$grab{$website}{$webpage}{File}, $bkupFile);
			tee("backedup to: $bkupFile");
			$Pages{$website}{$webpage}{File} = $bkupFile;
			$conf->{Pages}{$website}{$webpage}{Lastupdate} = $time;
			DumpFile($conffile, $conf);
			DumpFile($pagesfile, \%Pages);
		}
	}
}

if (exists $Pages{arcamax}) {
	foreach my $comic (keys %{$Pages{arcamax}}) {
		my $Page = $Pages{arcamax}{$comic}{File};
		
		my $bkupFolder = "C:/private__/comic/$comic";
		mkpath($bkupFolder) if !-d $bkupFolder;
		
		tee("Start parsing arcamax:$comic: $Page");
		use HTML::Entities;
		use HTML::TreeBuilder::XPath;
		my $tree= HTML::TreeBuilder::XPath->new;
		$tree->parse_file($Page);
		my @srcs = $tree->findvalues('//img/@src');
		my @alts = $tree->findvalues('//img/@alt');
		my $src = '';
		my $alt = '';
		GETSRC:foreach my $src1 (@srcs) {
			$src = $src1;
			if ($src =~ /newspics/) {
				last GETSRC;
			}
		}
		GETSRC:foreach my $src1 (@alts) {
			$alt = $src1;
			if ($src1 =~ /(.+?) Cartoon for (\w{3})\/(\d{1,2})\/(\d{4})/) {
				last GETSRC;
			}
		}
		say "	found:$src:$alt";

		#my $src = $tree->findvalue('(//img)[2]/@src');
		tee("	img src: $src");
		#my $alt = $tree->findvalue('(//img)[2]/@alt');
		tee("	img alt: $alt");

		if ($alt =~ /(.+?) Cartoon for (\w{3})\/(\d{1,2})\/(\d{4})/) {
			my $cartoon = decode_entities($1);
			my $mon = $months{$2}; $mon = "0$mon" if length($mon)==1;
			my $mday = $3;$mday = "0$mday" if length($mday)==1;
			my $year = $4;

			if ($src =~ /(newspics.+)\.(.+)$/) {
				my $source = "wget/www.arcamax.com/$1.$2";
				my $target = "$bkupFolder/$cartoon-$year-$mon-$mday.$2";
				tee("	source: $source");
				tee("	target: $target");
				use File::Copy;
				my $result = copy($source, $target);
				tee("	copy result: $result");
				if ($result == 1) {
					tee("	All is good");
				}
				else {
					tee("ERROR:result is not 1:copy($source, $target)");
					my $result = $nt->update("\@nyet arcamax:$comic file copy is bad");
				}
			}
			else {
				tee("ERROR:Can not parse src: $src");
				my $result = $nt->update("\@nyet arcamax:$comic parser is broken");
			}
		}
		else {
			tee("ERROR:Can not parse alt: $alt");
			my $result = $nt->update("\@nyet arcamax:$comic parser is broken");
		}
		tee("End parsing arcamax:$comic");
	}
}


if (exists $Pages{BorrowLenses}) {
	if (exists $Pages{BorrowLenses}{ForSale}) {
		my $Page = $Pages{BorrowLenses}{ForSale}{File};
		tee("Start parsing BorrowLenses:ForSale: $Page");
		
		my $data = undef;
		my $previousFile = "";
		my $BorrowLensesForSaleFile = "BorrowLenses/ForSale.yaml";
		if (-f $BorrowLensesForSaleFile) {
			$data = LoadFile($BorrowLensesForSaleFile);
			tee("	LoadFile $BorrowLensesForSaleFile");
			$previousFile = $data->{file};
		}
		else {
			tee("	BorrowLensesForSaleFile($BorrowLensesForSaleFile) doesn't exist");
		}
		tee("	previousFile: $previousFile");
		
		my %stuff;
		use HTML::TreeBuilder::XPath;
		my $tree= HTML::TreeBuilder::XPath->new;
		$tree->parse_file($Page);
		foreach my $product ($tree->findnodes('//td[@class="product"]')) {
			my $thisNode = $product->clone;
			#print "PRODUCT:".$product->as_XML()."\n\n";
			#print $thisNode->as_XML();
			
			sub usedPrice {
				#get $product->as_XML(): Buy Used\s+$405.00
				$_[0] =~ /Buy Used:\s+(\$[\d\.\,]+)/;return $1 || '$0.00';
			};
			
			my %info = (
				#get the first instance of a/@href->[0] = http://www.borrowlenses.com/product/For_Sale/Canon_EF_135mm_f2.8L_soft
				'url' => $thisNode->findvalue('(//a)[1]/@href'),
				#get the first instance of img/@src->[0] = ../images/store/12064_sm.jpg
				'img' => $thisNode->findvalue('(//img)[1]/@src'),
				#get the first instance of img/@title = Canon EF 135mm f/2.8 Autofocus Lens Soft Focus
				'title' => $thisNode->findvalue('(//img)[1]/@title'),
				'used' => usedPrice($thisNode->as_XML()),
			);
			my $key = $thisNode->findvalue('(//td)[1]/@id');
			
			$stuff{$key} = \%info;
		}
		
		if (!exists $stuff{'productList-Tshirt'}) { # check if the parser is broken
			tee("	BorrowLenses parser is broken: productList-Tshirt is not found");
			my $result = $nt->update("\@nyet BorrowLenses parser is broken: productList-Tshirt is not found");
			tee("	result: $result");
		}
		else {
			my $currentFile = "BorrowLenses/ForSaleItems-$grab{BorrowLenses}{ForSale}{TimeStamp}.yaml";
			DumpFile($currentFile, \%stuff);
			tee("	DumpFile(\%stuff): $currentFile");
			
			$data->{file} = $currentFile;
			DumpFile($BorrowLensesForSaleFile, $data);
			tee("	DumpFile(\$data): $BorrowLensesForSaleFile");
			
			if (!-f $previousFile) {
				tee("	New for sale items are detected: http://www.borrowlenses.com/category/For_Sale");
				my $result = $nt->update("\@nyet New borrowlenses for sale items are detected: http://www.borrowlenses.com/category/For_Sale");
				tee("	result: $result");
			}
			elsif (compare($previousFile, $currentFile) != 0) {
				tee("	New for sale items are detected: http://www.borrowlenses.com/category/For_Sale");
				my $result = $nt->update("\@nyet New borrowlenses for sale items are detected: http://www.borrowlenses.com/category/For_Sale");
				tee("	result: $result");
			}
		}
		tee("End parsing BorrowLenses:ForSale");
	}
}

if (exists $Pages{PortableApps}) {
	my $timestamp = "$year-$mon-$mday";
	my $bkupFolder = 'C:\work\install\PortableApps';
	mkpath($bkupFolder) if !-d $bkupFolder;
	
	my $data = {};
	my $PortableAppsFile = "PortableApps/Apps.yaml";
	if (-f $PortableAppsFile) {
		$data = LoadFile($PortableAppsFile);
		tee("LoadFile $PortableAppsFile");
	}
	else {
		tee("PortableAppsFile($PortableAppsFile) doesn't exist");
	}
	
	my %current;
	foreach my $App (keys %{$Pages{PortableApps}}) {
		my $Page = $Pages{PortableApps}{$App}{File};
		tee("Start parsing PortableApps:$App: $Page");
		
		use HTML::TreeBuilder::XPath;
		my $tree= HTML::TreeBuilder::XPath->new;
		$tree->parse_file($Page);
		foreach my $product ($tree->findnodes('//div[@class="download-box"]')) {
			my $thisNode = $product->clone;
			#print "PRODUCT:".$product->as_XML()."\n\n";
			#print $thisNode->as_XML();
			
			sub getVersion {
				#get $product->as_XML(): Download 5.9.3
				$_[0] =~ /\<strong\>Download (.+?)\<\//;return $1 || '5.9.3';
			};
			#get the first instance of a/@href->[0] = http://downloads.sourceforge.net/portableapps/NotepadPlusPlusPortable_5.9.3.paf.exe?download
			my $url = $thisNode->findvalue('(//a)[1]/@href');
				
			#get the version = 5.9.3
			my $version = getVersion($thisNode->as_XML());
			if (!$version) { # check if the parser is broken
				tee("	PortableApps parser is broken: version($version) is not found");
				my $result = $nt->update("\@nyet PortableApps parser is broken: version($version) is not found");
				tee("	result: $result");
			}
			else {
				$current{$App}{version} = $version;
				$current{$App}{url}     = $url;
				$current{$App}{time}    = $time;
				my $currentFile = "PortableApps/Apps-$timestamp.yaml";
				DumpFile($currentFile, \%current);
				tee("	DumpFile(\%current): $currentFile");
				
				sub updateData {
					my ($App, $version, $url) = @_;
					
					(my $tmpurl = $url) =~ s/\%2f/\//gi;
					tee("	tmpurl:$tmpurl");
					if ($tmpurl =~ /.+\/(.+)/) {
						my ($filename) = split /\?/, $1;
						
						my $cmd = qq{wget -O $bkupFolder\\$filename $url};
						system($cmd);
						tee("	File($filename) is downloaded");
						my $result = $nt->update("\@nyet File($filename) is downloaded");
						tee("	result: $result");
				
						$data->{$App}{version} = $version;
						$data->{$App}{url}     = $url;
						$data->{$App}{time}    = $time;
						
						DumpFile($PortableAppsFile, $data);
						tee("	DumpFile(\$data): $PortableAppsFile");
					}
				}
				
				if (exists $data->{$App}) {
					if (exists $data->{$App}{version}) {
						if ($data->{$App}{version} eq $version) {
							tee("	Old $App($version), $url");
						}
						else {
							tee("	New $App(new=$version,old=$data->{$App}{version}), $url");
							updateData($App, $version, $url);
						}
					}
					else {
						tee("	New $App($version), $url");
						updateData($App, $version, $url);
					}
				}
				else {
					tee("	New $App($version), $url");
					updateData($App, $version, $url);
				}
			}
		}
		
		tee("End parsing PortableApps:$App");
	}
}



sub tee {
	my ($note) = @_;
	
	print getTimeStamp().":$note\n";
	open  my $LOG, ">>$logfile";
	print {$LOG} getTimeStamp().":$note\n";
	close $LOG;
}

sub getTimeStamp {
	my $time = time;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$year += 1900;
	$mon++;
	$mon = "0$mon" if (length $mon == 1);
	$mday = "0$mday" if (length $mday == 1);
	$sec = "0$sec" if (length $sec == 1);
	$min = "0$min" if (length $min == 1);
	$hour = "0$hour" if (length $hour == 1);
	return "$year-$mon-$mday-$hour$min$sec";
}

__DATA__




