use strict;
use File::Glob ':glob';


my $startDir = 'C:\folder';

listFiles($startDir);


sub listFiles {
	my ($folder) = @_;

	my @files = bsd_glob("$folder/*");
	foreach my $file (@files) {
		if (-d $file) {
			listFiles($file);
		}
		elsif (-f $file) {
			print "$file\n";
		}
		else {
			print "$file is not handled.\n";
		}
	}
}