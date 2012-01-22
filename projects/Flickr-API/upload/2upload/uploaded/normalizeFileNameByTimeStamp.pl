use strict;
use v5.10.1;
use Image::ExifTool qw(:Public);
use File::Glob ':glob';

open my $LOG, ">>$0.log";

my $tool = Image::ExifTool->new();

foreach my $file (bsd_glob('*.jpg')) {
	sub rname {
		my ($file) = @_;
		my $tag = 'DateTimeOriginal';
		$tool->ExtractInfo($file);
		my $val = $tool->GetValue($tag);
		if (ref $val eq 'ARRAY') {
			say {$LOG} "	ERROR:$tag is a list of values";
		} elsif (ref $val eq 'SCALAR') {
			say {$LOG} "	ERROR:$tag represents binary data";
		} else {
			$val =~ s/\://g;
			if (length($val) > 0) {
				say {$LOG} "	$tag is a simple scalar: $val";
				if (!-f "$val.jpg") {
					say {$LOG} "	Rename $file to $val.jpg";
					rename $file, "$val.jpg";
				}
				else {
					# if there is a duplication
					my $idx = 1;
					my $targetfilename = "$val.t$idx.jpg";
					while (-f $targetfilename) {
						$idx++;
						$targetfilename = "$val.t$idx.jpg";
					}
					say {$LOG} "	Rename $file to $targetfilename";
					rename $file, $targetfilename;
				}
			}
		}
	}
	
	if ($file =~ /^P\d+\.jpg/i) {
		say {$LOG} "Renaming $file";
		rname($file);
	}
	elsif ($file =~ /^DSC_\d+\.jpg/i) {
		say {$LOG} "Renaming $file";
		rname($file);
	}
	else {
		say {$LOG} "Do nothing with $file";
	}	
}

close $LOG;