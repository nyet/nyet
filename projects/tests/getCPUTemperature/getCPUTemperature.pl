#!/usr/bin/perl -w
use strict;
use warnings;

use Win32::OLE;
use Data::Dumper;

my $wmi = Win32::OLE->GetObject("winmgmts://./root/WMI") or die "Failed getobject\n";
my $list = $wmi->InstancesOf("MSAcpi_ThermalZoneTemperature") or die "Failed getobject\n";
foreach my $v (in $list) {
	print "CurrentTemperature:".($v->{CurrentTemperature}/10-273.15)."\n";
}

__DATA__
my $class = "MSAcpi_ThermalZoneTemperature";
my $key = 'Name';
################################################################################
my $wmi = Win32::OLE->GetObject("WinMgmts://./root/cimv2") or die "Failed: GetObject\n";
my $list, my $v;
$list = $wmi->InstancesOf("Win32_Processor") or die "Failed: InstancesOf\n";
print "list:".Dumper $list;
my $i=0;
foreach $v (Win32::OLE::in $list){
	print "\$v[$i]: ".Dumper($v);
	print "CPU:\n";
	print "\t", $v->{Name}, "\n";
	print "\t", $v->{Caption}, "\n";
	$i++;
}
################################################################################
my @properties = qw(CurrentTemperature);
print Dumper \@properties;
my $wmi = Win32::OLE->GetObject("winmgmts://./root/WMI") or die "Failed getobject\n";
my $list, my $v;
$list = $wmi->InstancesOf("$class") or die "Failed getobject\n";
print "list:".Dumper $list;
my $i=0;
my $hash;
foreach $v (in $list) {
	print "\$v[$i]: ".Dumper($v);
	#print "\$v->{Properties_}: ".Dumper $v->{Properties};
	#print "\$v->{\$key}: ".$v->{$key}."\n";
	#$hash->{$v->{$key}}->{$_} = $v->{$_} for @properties;
   
   print "CurrentTemperature:".$v->{CurrentTemperature}."\n";
   $i++;
}
#print Dumper $hash;
#print "CurrentTemperature:".$list[0]->{CurrentTemperature}."\n";
################################################################################
CPU:
        Intel(R) Core(TM) i7 CPU       M 620  @ 2.67GHz
        Intel64 Family 6 Model 37 Stepping 5
