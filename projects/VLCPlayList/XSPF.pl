# Somehow XML::XSPF is not working well. Created this script to collect all mp3 
# files in the current folder and create a playlist for VLC 


my $xml = qq{<?xml version="1.0" encoding="UTF-8"?>
<playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
	<title>Playlist</title>
	<trackList>};
use Cwd;
my $dir = getcwd;
use File::Glob ':glob';
my $i=1;
foreach my $file (bsd_glob('*.mp3')) {
	$dir =~ s/\\/\//g;
	$xml .= qq{
		<track>
			<location>file:///$dir/$file</location>
			<extension application="http://www.videolan.org/vlc/playlist/0">
				<vlc:id>$i</vlc:id>
			</extension>
		</track>};
	$ext_xml .= qq{		<vlc:item tid="$i"/>\n};
	$i++;
}

$xml .= qq{
	</trackList>
	<extension application="http://www.videolan.org/vlc/playlist/0">};
$xml .= $ext_xml;
$xml .= qq{
	</extension>
</playlist>};


open  FILE, ">$0.xspf";
print FILE $xml;
close FILE;
