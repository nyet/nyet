use strict;
use Win32;
use Win32::API;
use Win32API::File qw( :Func );

my $PipeName = "My Named Pipe";
use constant { 
    PIPE_NAME => "//./pipe/X"
    , PIPE_ACCESS_INBOUND => 0x00000001
    , FILE_FLAG_FIRST_PIPE_INSTANCE => 0x00080000
    , PIPE_TYPE_MESSAGE => 0x00000004
    , PIPE_READMODE_MESSAGE => 0x00000002
};
my $NULL = 0;

# Note warning on LPSECURITY_ATTRIBUTES, but used only as NULL pointer
Win32::API->Import('kernel32'
  ,'HANDLE CreateNamedPipe( LPCTSTR lpName '
    . ', DWORD dwOpenMode, DWORD dwPipeMode, DWORD nMaxInstances'
    . ', DWORD nOutBufferSize, DWORD nInBufferSize'
    . ', DWORD nDefaultTimeOut'
    . ', LPSECURITY_ATTRIBUTES lpSecurityAttributes)' );

# Note warning on LPOVERLAPPED, but used only as NULL pointer.
Win32::API->Import('kernel32'
  ,'BOOL ConnectNamedPipe(HANDLE hNamedPipe'
    . ', LPOVERLAPPED lpOverlapped )');

Win32::API->Import('kernel32'
  ,'BOOL DisconnectNamedPipe(HANDLE hNamedPipe)');


my $pipehandle = CreateNamedPipe( PIPE_NAME 
        , PIPE_ACCESS_INBOUND + FILE_FLAG_FIRST_PIPE_INSTANCE
        , PIPE_TYPE_MESSAGE + PIPE_READMODE_MESSAGE
        , 1        , 512    , 512    , 10000    , $NULL ) 
    or die "Unable to create pipe:". Win32::GetLastError() ;
my( $res, $message);

my $bServerContinue = 1;
while( $bServerContinue ) {
	print "Waiting for a client to connect...\n";
	ConnectNamedPipe($pipehandle,$NULL) 
		or die "Connect failed: ".  Win32::GetLastError();
	$res = ReadFile($pipehandle,$message, 512, [], [] );
	print "message: $message\n";
	$bServerContinue = 0 if $message eq 'bb';
	$res = DisconnectNamedPipe($pipehandle);
	if( $message eq "exit" ) { 
		last;
	}
}
$res = CloseHandle($pipehandle);

#http://www.perlmonks.org/?node_id=715874
#http://www.perlmonks.org/?node_id=726593