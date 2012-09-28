use v5.10;
use Win32::Pipe;
say $Win32::Pipe::VERSION;

$| = 1;

my $PipeName = "My Named Pipe";
say "Creating pipe '$PipeName'";
my $Pipe = new Win32::Pipe($PipeName) || die "Can't Create Named Pipe($PipeName)\n"; 

my $i=1;
my $bServerContinue = 1;
while ($bServerContinue) {
	print "$i:Waiting for a client to connect..."; 
	if ($i == 1) {
		say "blocking";
	}
	else {
		say "NOT blocking";
	}

	if ($Pipe->Connect()) {
		my $In;
      
		#$User = ( $Pipe->GetInfo() )[2];
		#print "Pipe opened by $User.\n";
      
		$In = $Pipe->Read();
      
		say "Client sent us: $In";
		$bServerContinue = 0 if $In eq 'bb';
      
		say "Disconnecting...";
		$Pipe->Disconnect(); 
	}
	if ($i > 10) {
		exit 0;
	}
	$i++;	
}
$Pipe->Close();

#https://rt.cpan.org/Public/Bug/Display.html?id=79924