use v5.10.1;
use Win32::DriveInfo;
use Data::Dumper;

$TotalNumberOfFreeBytes = (Win32::DriveInfo::DriveSpace('c:'))[6];
say "TotalNumberOfFreeBytes: $TotalNumberOfFreeBytes";

#use Win32::AdminMisc;
#my @drives=Win32::AdminMisc::GetDrives(DRIVE_FIXED);
#foreach my $drive (@drives) {
#	say $drive;
#}

#foreach my $drive ( Win32::DriveInfo::DrivesInUse ) {
	#say $drive;
	
	#next unless Win32::DriveInfo::DriveType($drive) == FIXED_DISK;
	
	#my $serial = (Win32::DriveInfo::VolumeInfo($drive))[1];
	
	#next if $seen{$serial}++;
	#say Dumper Win32::DriveInfo::VolumeInfo($drive);
#}

#40_932_114_432