use strict;
use v5.10.1;
use Digest::MD5 qw(md5_base64);
use File::Glob ':glob';
use File::Slurp;


my $index = {};
indexFiles($index, 'C:\1working\nyet\projects\DuplicateFileFinder');

sub indexFiles {
	my ($index, $file) = @_;
	foreach my $f (bsd_glob("$file/*.*")) {
		if (-d $f) {
			indexFiles($f);
		}
		else {
			my $type = 'unknown';
			if (($f =~ /jpg/i) && ("TODO:some file detection scheme")) {
				$type = 'jpg';
			}
			elsif (1==1) {
				
			}
			
			my $hash = indexFile($f);
			if (exists $index->{$type}{$hash}) {
				say "Duplicate detected: $index->{$type}{$hash} eq $f, $type:$hash";
			}
			else {
				$index->{$type}{$hash} = $f;
			}
		}
	}
}
	

sub indexFile {
	my ($file) = @_;
	say "indexFile($file)";
	
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
	
	my $md5 = md5_base64(read_file( $file, binmode => ':raw' ));
	
	return "$size:$md5";
}