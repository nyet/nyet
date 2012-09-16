use strict;
use XML::XSPF;
use XML::XSPF::Track;
my $xspf  = XML::XSPF->new;
$xspf->title('Bicycles & Tricycles');

my $track = XML::XSPF::Track->new;
$track->title('Prime Evil');
$track->location('http://orb.com/PrimeEvil.mp3');
$xspf->trackList($track);

my $track2 = XML::XSPF::Track->new;
$track2->title('Prime Evil 2');
$track2->location('http://orb.com/PrimeEvil2.mp3');
$xspf->trackList($track2);



print $xspf->toString;
