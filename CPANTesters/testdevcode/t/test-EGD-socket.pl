use v5.10;
my $path = 'localhost:708'; 
if (-S $path) {
	say "$path is socket";
}


#-r $Net::SSLeay::random_device

say "\$ENV{EGD_PATH}: $ENV{EGD_PATH}";

#http://perldoc.perl.org/functions/-X.html