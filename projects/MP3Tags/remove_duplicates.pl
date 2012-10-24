use strict;
use v5.10.1;
my $folder = 'xxx';

use Data::Dumper;
use File::Glob 'bsd_glob';
use MP3::Tag;

my $record_section = 0;
my %titles;
open FILE, "collections.txt";
while (my $line = <FILE>) {
	#if ($line =~ /^\[Copied\]/) {
	#	$record_section = 1;
	#	$line = <FILE>;
	#}
	#elsif ($line =~ /^\[/) {
	#	$record_section = 0;
	#}
	
	if ($line =~ /[^\[]/) {
		chomp $line;
		if ($line ne "") {
			say $line;
			my ($artist, $title) = split /\|/, $line;
			
			$titles{lc($title)}{lc($artist)} = 1;
		}
	}
}
close FILE;
foreach my $file (bsd_glob("pops/*.mp3")) {
	my $mp3 = MP3::Tag->new($file);
	my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
	$mp3->close();	
	$titles{lc($title)}{lc($artist)} = 1;
}
################################################################################
open  TARGET, ">$0.log";
#say   TARGET Dumper \%titles;
foreach my $file (bsd_glob("$folder/*.mp3")) {
	my $mp3 = MP3::Tag->new($file);
	my ($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
	$mp3->close();
	
	if (exists $titles{lc($title)}){
		if (exists $titles{lc($title)}{lc($artist)}) {
			say        "DELETE: $artist|$title:$file";
			say TARGET "DELETE: $title";
			#unlink $file or warn "Could not unlink $file: $!";
			$file =~ s/\//\\/g;
			system qq{del "$file"}; 
		}
		else {
			say TARGET "DECIDE: $artist|$title:$file";
		}
	}
	else {
		#say TARGET "KEEP: $title";
	}
}
say   TARGET Dumper \%titles;
close TARGET;


__DATA__
attrib -r "F:\MP3 tags" /s