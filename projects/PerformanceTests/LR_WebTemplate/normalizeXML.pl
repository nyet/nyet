open TARGET, ">OrderInfo.c";
open FILE, "OrderInfo.c.1";
while (my $line = <FILE>) {
	$line =~ /^(\s+)/;
	my $white = $1;
	
	$line =~ s|(<\/\w+>)|$1\"\n$white\"|g;
	$line =~ s|(\w)><(\w)|$1>\"\n$white\"<$2|g;
	$line =~ s|\/><|\/>\"\n$white\"<|g;
	print TARGET $line;
}
close FILE;
close TARGET;