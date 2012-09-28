use Win32::Pipe;

$PipeName = "\\\\localhost\\pipe\\My Named Pipe";
print "Connecting to $PipeName\n";

if( $Pipe = new Win32::Pipe( $PipeName ) )
{
  my $Data = "Time on " . Win32::NodeName() . " is: " . localtime() . "\n";
  print "\nPipe has been opened, writing data to it...\n";
  
  $Pipe->Write( $Data );
  $Pipe->Close();
}
else
{
  print "Error connecting: " . Win32::FormatMessage( $Win32::Pipe::Error ) . "\n";
}