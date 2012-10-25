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
		Audacity => {
			Every => 10*24*3600-600,
			URL => 'http://portableapps.com/apps/music_video/audacity_portable',
			File => 'portableapps.com/apps/music_video/audacity_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		BleachBit => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/bleachbit_portable',
			File => 'portableapps.com/apps/utilities/bleachbit_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		CrystalDiskInfo => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/crystaldiskinfo_portable',
			File => 'portableapps.com/apps/utilities/crystaldiskinfo_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		DataBaseBrowser => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/development/database_browser_portable',
			File => 'portableapps.com/apps/development/database_browser_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Diffpdf => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/diffpdf_portable',
			File => 'portableapps.com/apps/utilities/diffpdf_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FileZilla => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/filezilla_portable',
			File => 'portableapps.com/apps/internet/filezilla_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FinanceExplorer=> {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/office/finance_explorer_portable',
			File => 'portableapps.com/apps/office/finance_explorer_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FireFox => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/firefox_portable',
			File => 'portableapps.com/apps/internet/firefox_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FocusWriter => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/office/focuswriter_portable',
			File => 'portableapps.com/apps/office/focuswriter_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FoxitReader => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/office/foxit_reader_portable',
			File => 'portableapps.com/apps/office/foxit_reader_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		FreeDownloadManager => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/free-download-manager-portable',
			File => 'portableapps.com/apps/internet/free-download-manager-portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Frhed => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/development/frhed_portable',
			File => 'portableapps.com/apps/development/frhed_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Ghostscript => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/ghostscript_portable',
			File => 'portableapps.com/apps/utilities/ghostscript_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		GIMP => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/graphics_pictures/gimp_portable',
			File => 'portableapps.com/apps/graphics_pictures/gimp_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		GNUCash => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/office/gnucash_portable',
			File => 'portableapps.com/apps/office/gnucash_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		GoogleChrome => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/google_chrome_portable',
			File => 'portableapps.com/apps/internet/google_chrome_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		IcoFX => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/graphics_pictures/icofx_portable',
			File => 'portableapps.com/apps/graphics_pictures/icofx_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		InfraRecorder => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/infrarecorder_portable',
			File => 'portableapps.com/apps/utilities/infrarecorder_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Iron => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/iron_portable',
			File => 'portableapps.com/apps/internet/iron_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		javaLauncher => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/java_portable_launcher',
			File => 'portableapps.com/apps/utilities/java_portable_launcher',
			TimeStamp => "$year-$mon-$mday",
		},
		java => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/java_portable',
			File => 'portableapps.com/apps/utilities/java_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		KeePass => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/keepass_portable',
			File => 'portableapps.com/apps/utilities/keepass_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		KiTTY => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/kitty-portable',
			File => 'portableapps.com/apps/internet/kitty-portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Lightscreen => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/lightscreen_portable',
			File => 'portableapps.com/apps/utilities/lightscreen_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		MicroSIP => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/microsip-portable',
			File => 'portableapps.com/apps/internet/microsip-portable',
			TimeStamp => "$year-$mon-$mday",
		},
		NotepadPP => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/development/notepadpp_portable',
			File => 'portableapps.com/apps/development/notepadpp_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		PeaZip => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/peazip_portable',
			File => 'portableapps.com/apps/utilities/peazip_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		PhotoFiltre => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/graphics_pictures/photofiltre_portable',
			File => 'portableapps.com/apps/graphics_pictures/photofiltre_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Pidgin => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/pidgin_portable',
			File => 'portableapps.com/apps/internet/pidgin_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		PuTTY => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/putty_portable',
			File => 'portableapps.com/apps/internet/putty_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		RawTherapee => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/graphics_pictures/rawtherapee-portable',
			File => 'portableapps.com/apps/graphics_pictures/rawtherapee-portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Skype => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/skype_portable',
			File => 'portableapps.com/apps/internet/skype_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		SMPlayer => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/music_video/smplayer_portable',
			File => 'portableapps.com/apps/music_video/smplayer_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		SqliteDataBaseBrowser => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/development/sqlite_database_browser_portable',
			File => 'portableapps.com/apps/development/sqlite_database_browser_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Sqliteman => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/development/sqliteman-portable',
			File => 'portableapps.com/apps/development/sqliteman-portable',
			TimeStamp => "$year-$mon-$mday",
		},
		SystemExplorer => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/system_explorer_portable',
			File => 'portableapps.com/apps/utilities/system_explorer_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		SWIProlog => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/development/swi-prolog_portable',
			File => 'portableapps.com/apps/development/swi-prolog_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		Thunderbird => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/thunderbird_portable',
			File => 'portableapps.com/apps/internet/thunderbird_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		uTorrent => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/internet/utorrent_portable',
			File => 'portableapps.com/apps/internet/utorrent_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		VLC => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/music_video/vlc_portable',
			File => 'portableapps.com/apps/music_video/vlc_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		WinDirStat => {
			Every => 7*24*3600-600,
			URL => 'http://portableapps.com/apps/utilities/windirstat_portable',
			File => 'portableapps.com/apps/utilities/windirstat_portable',
			TimeStamp => "$year-$mon-$mday",
		},
		#WiseRegistryCleaner => {
		#	Every => 7*24*3600-600,
		#	URL => 'http://portableapps.com/apps/utilities/wise-registry-cleaner-portable',
		#	File => 'portableapps.com/apps/utilities/wise-registry-cleaner-portable',
		#	TimeStamp => "$year-$mon-$mday",
		#},
		XnView => {
			Every => 3*24*3600-600,
			URL => 'http://portableapps.com/apps/graphics_pictures/xnview_portable',
			File => 'portableapps.com/apps/graphics_pictures/xnview_portable',
			TimeStamp => "$year-$mon-$mday",
		},
	},
	gnuwin32 => {
		grep => {
			Every => 3*24*3600-600,
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

		my @app_data; #some page might have more than 1 download (e.g.: http://portableapps.com/apps/utilities/java_portable has 32 bit and 64 bit downloads)
		my $URL;
		my $VERSION;
		my $to_download = 0;
		{	#simple parsing first		
			# some of the page doesn't use download-box anymore e.g.: http://portableapps.com/apps/utilities/peazip_portable
			# need to parse the version and the download URL manually.
			# href="http://sourceforge.net/projects/portableapps/files/PeaZip%20Portable/Additional%20Versions/PeaZipPortable_4.7.paf.exe/download"
			
			local $/ = undef;
			open my $LOCAL, $Page;
			my $whole = <$LOCAL>;
			close $LOCAL;
			
			my $i = 0;
			while ($whole =~ m|"(http://downloads.sourceforge.net/.+?)\?download"|g) { 
				#<a href="http://downloads.sourceforge.net/portableapps/KeePassPortable_1.24.paf.exe?download" class="sourceforge_accelerator_link"
				$URL = $1;
				$app_data[$i]->{URL} = $URL;
				$i++;
			}
			while ($whole =~ m|"(http://downloads.sourceforge.net/.+?\.exe)"\s+class="sourceforge_accelerator_link"|g) { 
				#<a href="http://downloads.sourceforge.net/portableapps/SWI-PrologPortable_6.2.1_English.paf.exe" class="sourceforge_accelerator_link"
				$URL = $1;
				$app_data[$i]->{URL} = $URL;
				$i++;
			}
			#http://portableapps.com/bouncer?t=http%3A%2F%2Fdownload.portableapps.com%2Fportableapps%2Fwiseregistrycleanerportable%2FWiseRegistryCleanerPortable_7.51.paf.exe
			#http://downloads.sourceforge.net/portableapps/SqlitemanPortable_1.2.2.paf.exe?accel_key=69%3A1348633465%3Ahttp%253A//portableapps.com/apps/development/sqliteman-portable%3A1fd6a6ee%24a6580a02528bd71d88fd0dba1247e86b002e5027&click_id=0dfe536e-0792-11e2-a7c5-0200ac1d1d8a&source=accel
			while ($whole =~ m|"(http://sourceforge.net/.+?)/download"|g) {
				$URL = $1;
				$app_data[$i]->{URL} = $URL;
				$i++;
			}
			$i = 0;	
			while ($whole =~ m|<strong>Version (.+?)<\/strong>|g) {
				$VERSION = $1;
				$app_data[$i]->{VERSION} = $VERSION;
				$i++;
			}
			
			if ($URL && $VERSION) {
				$current{$App}{version} = $VERSION;
				$current{$App}{url}     = $URL;
				$current{$App}{time}    = $time;
				$to_download = 1;
				tee("	DumpFile(\@app_data): ".Dumper(\@app_data));
			}
		}
		
		if (!$to_download) { #URL & version parsing via download-box
			tee("	URL & version parsing via download-box");
			use HTML::TreeBuilder::XPath;
			my $tree= HTML::TreeBuilder::XPath->new;
			$tree->parse_file($Page);
			my $i = 0;
			foreach my $product ($tree->findnodes('//div[@class="download-box"]')) {
				my $thisNode = $product->clone;
				#print "PRODUCT:".$product->as_XML()."\n\n";
				#print $thisNode->as_XML();
				
				sub getVersion {
					#get $product->as_XML(): Download 5.9.3
					$_[0] =~ /\<strong\>Download (.+?)\<\//;return $1 || '5.9.3';
				};
				#get the first instance of a/@href->[0] = http://downloads.sourceforge.net/portableapps/NotepadPlusPlusPortable_5.9.3.paf.exe?download
				$URL = $thisNode->findvalue('(//a)[1]/@href');
					
				#get the version = 5.9.3
				$VERSION = getVersion($thisNode->as_XML());
				if (!$VERSION) { # check if the parser is broken
					tee("	PortableApps parser is broken: VERSION($VERSION) is not found");
					my $result = $nt->update("\@nyet PortableApps parser is broken: VERSION($VERSION) is not found");
					tee("	result: $result");
				}
				else {
					$current{$App}{version} = $VERSION;
					$current{$App}{url}     = $URL;
					$current{$App}{time}    = $time;
					
					$app_data[$i]->{VERSION} = $VERSION;
					$app_data[$i]->{URL} = $URL;
					
					$to_download = 1;
					$i++;
				}
			}
		}

		if ($to_download){ #download
			my $currentFile = "PortableApps/Apps-$timestamp.yaml";
			DumpFile($currentFile, \%current);
			tee("	DumpFile(\%current): $currentFile");
			
			sub updateData {
				my ($App, $version, $url, $i) = @_;
				
				(my $tmpurl = $url) =~ s/\%2f/\//gi;
				tee("	tmpurl:$tmpurl");
				if ($tmpurl =~ /.+\/(.+)/) {
					my ($filename) = split /\?/, $1;
					
					if (!-f "$bkupFolder\\$filename") {
						my $cmd = qq{wget -O $bkupFolder\\$filename $url};
						system($cmd);
						tee("	File($filename) is downloaded");
						my $result = $nt->update("\@nyet File($filename) is downloaded");
						tee("	result: $result");

						$data->{$App}{version} = $version;
						$data->{$App}{url}     = $url;
						$data->{$App}{time}    = $time;
						
						if ($i == 0) {
							DumpFile($PortableAppsFile, $data);
							tee("	DumpFile(\$data): $PortableAppsFile");
						}
					}
					else {
						tee("	File($filename) is already downloaded");
					}
				}
			}
			
			
			#Flat dump of Java (2 downloads in 1 page)
			#'URL' => 'http://sourceforge.net/projects/portableapps/files/Java%20Portable/Additional%20Versions/jPortable_7_Update_6_online.paf.exe',
			#'VERSION' => '7 Update 6 (32-bit)'
			#'URL' => 'http://sourceforge.net/projects/portableapps/files/Java%20Portable/Additional%20Versions/jPortable64_7_Update_6_online.paf.exe',
			#'VERSION' => '7 Update 6 (64-bit)'
			my $i = 0;
			foreach my $d (@app_data) {
				my $VERSION = $d->{VERSION};
				my $URL     = $d->{URL};
				if (exists $data->{$App}) {
					if (exists $data->{$App}{version}) {
						if ($data->{$App}{version} eq $VERSION) {
							tee("	Old $App($VERSION), $URL");
						}
						else {
							tee("	New $App(new=$VERSION,old=$data->{$App}{version}), $URL");
							updateData($App, $VERSION, $URL, $i);
						}
					}
					else {
						tee("	New $App($VERSION), $URL");
						updateData($App, $VERSION, $URL, $i);
					}
				}
				else {
					tee("	New $App($VERSION), $URL");
					updateData($App, $VERSION, $URL, $i);
				}
				$i++;
			}
			
		}		
		else {
			tee("	PortableApps parser for $App is broken: URL($URL) and/or version($VERSION) is not found");
			my $result = $nt->update("\@nyet PortableApps parser for $App is broken: URL($URL) and/or version($VERSION) is not found");
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




