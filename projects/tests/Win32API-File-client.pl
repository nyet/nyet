use strict;
use Win32;
use Win32API::File qw( :Func :Misc :GENERIC_ );

my $PipeName = "bb";
use constant {
    PIPE_NAME => "//./pipe/X" 
};
my $pipehandle;
while( ! $pipehandle ) {
    # Open client side of pipe.
    $pipehandle = CreateFile( PIPE_NAME, GENERIC_WRITE, 0, []
        , OPEN_EXISTING , 0, [] );
    if( ! $pipehandle ) { # Error during opening
        my $e = Win32::GetLastError();
        my $m = Win32::FormatMessage($e); 
        print "Error ($e):$m\n";
        exit;
    }
}
#write the message and close
my $res = WriteFile($pipehandle, $PipeName, length($PipeName), [], [] );
my $res = CloseHandle($pipehandle);