use v5.10.1;
use File::Glob 'bsd_glob';
use MP3::Tag;

my @titles;
foreach my $file (bsd_glob('pops/*.mp3')) {
	my $mp3 = MP3::Tag->new($file);
	my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();

	push @titles, "$artist|$title|";
	say           "$artist|$title|";
}
open  TARGET, ">$0.log";
say   TARGET join("\n", sort(@titles));
close TARGET;

