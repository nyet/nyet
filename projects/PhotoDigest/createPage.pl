use strict;
use v5.10.1;
use Data::Dumper;
use File::Path;
use HTML::Entities;
use XML::Simple;

open my $LOG, ">$0.log";

open FILE, "download.pl.download.log";
my %photos;
while (my $line = <FILE>) {
	if ($line =~ /^\d/) {
		# do nothing
		#print $line;
		my @data = split /\t/, $line;
		my $photoid = $data[1];
		my $time = $data[2];
		my $url = $data[6];
		my $title = "";
		if ($line =~ /\|\|([\S\s]+)\|\|/) {
			$title = $1;
		}
		say "$photoid $time $url $title";
		#http://www.flickr.com/photos/nyet/6347585425
		
		$photos{$time} = {
			time => $time,
			photoid => $photoid,
			url => $url,
			title => $title,
		};
	}
}
close FILE;
say {$LOG} Dumper \%photos;

open XML, ">nyet.xml";
say  XML  "<photos>";
my @photos;
my %day;
my $i = 0;
PHOTO:foreach my $key (reverse sort keys %photos) {
	push @photos, $photos{$key};
	say XML  "	<photo>";
	say XML  "		<id>$photos{$key}{photoid}</id>";
	say XML  "		<url>$photos{$key}{url}</url>";
	say XML  "		<time>$photos{$key}{time}</time>";
	say XML  "		<title>".encode_entities($photos{$key}{title})."</title>";
	say XML  "	</photo>";
	if ($photos{$key}{time} =~ /(\d{4}-\d{1,2}-\d{1,2})/) {
		my $date = $1;
		unshift @{$day{$date}}, qq{<a href="http://www.flickr.com/photos/nyet/$photos{$key}{photoid}" title="}.encode_entities($photos{$key}{title}).qq{"><img src="$photos{$key}{url}" alt="}.encode_entities($photos{$key}{title}).qq{" /></a>};
	}
	if ($i>=20) {
		last PHOTO;
	}
	$i++;
}
say {$LOG} Dumper(\@photos);
say {$LOG} XMLout(\@photos);
say {$LOG} Dumper(\%day);
say   XML "</photos>";
close XML;

mkpath("nyet");
open HTML, ">nyet/index.html";
say  HTML "<html><head><title>\@nyet</title></head><body><table>";
foreach my $date (reverse sort keys %day) {
	say HTML "<tr><td>$date</td><td>".join("", @{$day{$date}})."</td>";
}
say   HTML "</table></body></html>";
close HTML;

close $LOG;
