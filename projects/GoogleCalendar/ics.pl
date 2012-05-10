use strict;
use v5.10.1;
# Import ics file from O'Reilly Event to Google Calendar 

use Config::Tiny;
my $Config = Config::Tiny->new;
$Config = Config::Tiny->read("$0.conf");

my $user_email    = $Config->{google}->{user_email};
my $user_password = $Config->{google}->{user_password};

use URI::Escape;
my $user_email_url = uri_escape($user_email);

use Data::ICal;
use DateTime;
use DateTime::Format::ISO8601;
use List::Util qw(min max);
use Math::BigInt;
use Data::Dumper;
use Net::Google::Calendar;
use Net::Google::Calendar::Calendar;
use Net::Google::Calendar::Entry;
use Net::Google::AuthSub;
use File::Glob ':glob';
use File::Copy;

use File::Path;
mkpath("archive") if !-e "archive";

my $error = '';

my $gcal = Net::Google::Calendar->new();
$gcal->login($user_email, $user_password);
my $gcl;
foreach my $c ($gcal->get_calendars) {
	say "Google Calendar: ".$c->title;
	#print $c->id."\n\n";
	$gcl = $c if ($c->id eq "http://www.google.com/calendar/feeds/default/allcalendars/full/$user_email_url");
	#print Dumper $c;
}
$gcal->set_calendar($gcl);

	
ICSFILE:foreach my $icsFile (bsd_glob("*.ics")) {
	say $icsFile;
	
	my $whole;
	{
		local $/ = undef;
		open FILE, $icsFile;
		$whole = <FILE>;
		close FILE;
		
		#Data::ICal doesn't recognize: url=uri
		$whole =~ s/url=uri/URL/i;
	}
	
	my $cal = Data::ICal->new(data => $whole);
	my @entries = @{$cal->entries};
	foreach my $entry (@entries) {
		if ( $entry->ical_entry_type eq 'VEVENT' ) {
			say "event detected";
			
			my $UID      = $entry->property('UID')->[0]->value;
			if ($UID =~ /events.oreilly.com/) {
				say "events.oreilly.com event detected";
				my $SUMMARY      = $entry->property('SUMMARY')->[0]->value;
				my $DTSTART      = $entry->property('DTSTART')->[0]->value;
				my $DTSTART_TZID = $entry->property('DTSTART')->[0]->{'_parameters'}->{'TZID'};
				my $URL          = $entry->property('URL')->[0]->value;
				
				say "SUMMARY:  $SUMMARY";
				say "DTSTART:  $DTSTART";
				
				my $iso8601 = DateTime::Format::ISO8601->new;
				my $dtStart = $iso8601->parse_datetime($DTSTART);
				if ($DTSTART_TZID eq 'US-Pacific') {
					$dtStart->set_time_zone('America/Los_Angeles');
				}
				else {
					$error = "ERROR:DTSTART_TZID ($DTSTART_TZID) is not US-Pacific anymore";
					print $error;
					next ICSFILE;
				}
				#say "dtStart:  $dtStart";
				say "URL:      $URL";
				
				my $gentry = Net::Google::Calendar::Entry->new();
				$gentry->title($SUMMARY);
				$gentry->content($URL);
				$gentry->location('');
				$gentry->transparency('transparent');
				$gentry->status('confirmed');
				$gentry->when(
						$dtStart,
						$dtStart + DateTime::Duration->new( hours => 1 )
				);
				$gentry->reminder(
						'alert',
						'minutes',
						5
				);
				$gentry->reminder(
						'email',
						'hours',
						2
				);
				$gcal->add_entry($gentry);
			}
		}
		else {
			print $entry->ical_entry_type;
		}
	}
	
	move($icsFile, "archive/$icsFile");
}

