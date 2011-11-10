use strict;
use Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ sep_char => "\t", }) or
	die "Cannot use CSV: ".Text::CSV->error_diag ();
	
open my $FH, ">analyze_af_gc.log";
if (1) {
	my $file = 'Gc.log';
	
	my $Gc_elapse_total = 0;
	my $Gc_freed_total = 0;
	my %Gc_elapse = (
		"GC (1<x<2s) count" => 0,
		"GC (>2s) count" => 0,
		"GC (>5s) count" => 0,
		"GC (>5s) elapse total" => 0,
	);
	
	my $lineno = 0;
	open my $io, $file or die "$file: $!";
	IO1:while (my $row = $csv->getline ($io)) {
		#foreach my $this (@$row) {
		#	print "$this|";
		#}
		#print "\n";
		
		$Gc_elapse_total += ${$row}[5];
		if ((1000 <= ${$row}[5]) && (${$row}[5] < 2000)) {
			$Gc_elapse{"GC (1<x<2s) count"}++;
		}
		if (${$row}[5] >= 2000 ) {
			$Gc_elapse{"GC (>2s) count"}++;
		}
		if (${$row}[5] >= 5000 ) {
			$Gc_elapse{"GC (>5s) count"}++;
			$Gc_elapse{"GC (>5s) elapse total"} += ${$row}[5];
		}
		
		$Gc_freed_total += ${$row}[3];
		
		#last IO1 if $lineno > 5;
		$lineno++;
	}
	close $io;
	
	print {$FH} sprintf("%.2f", ($Gc_elapse_total/($lineno-1)))."\n";
	print {$FH} $Gc_elapse{"GC (1<x<2s) count"}."\n";
	print {$FH} $Gc_elapse{"GC (>2s) count"}."\n";
	print {$FH} $Gc_elapse{"GC (>5s) count"}."\n";
	if ($Gc_elapse{"GC (>5s) count"} == 0) {
		print {$FH} "-\n";
	}
	else {
		print {$FH} $Gc_elapse{"GC (>5s) elapse total"}/$Gc_elapse{"GC (>5s) count"}."\n";
	}
	print {$FH} sprintf("%.0f", ($Gc_freed_total/($lineno-1)/1024))."\n";
}

if (1) {

	my $file = 'Af.log';
	my %Af_need = (
		"AF need (<1KB)" => 0, 
		"AF need (1KB<= X <100KB)" => 0, 
		"AF need (100KB<= X <500KB)" => 0,
		"AF need (500KB<= X <1MB)" => 0,
		"AF need (1MB <= X <2MB)" => 0,
		"AF need (2MB <= X <3MB)" => 0,
		"AF need (3MB <= X <4MB)" => 0,
		"AF need (4MB <= X <5MB)" => 0,
		"AF need (5MB <= X <6MB)" => 0,
		"AF need (6MB <= X <7MB)" => 0,
		"AF need (7MB <= X <8MB)" => 0,
		"AF need (8MB <= X <9MB)" => 0,
		"AF need (9MB <= X <10MB)" => 0,
		"AF need (10MB >= X)" => 0,
	);
	
	my $lineno = 0;
	open my $io, $file or die "$file: $!";
	IO2:while (my $row = $csv->getline ($io)) {
		#foreach my $this (@$row) {
		#	print "$this|";
		#}
		#print "\n";
		
		if (${$row}[2] < 1024) {
			#print "$lineno:${$row}[2]\n"; 
			$Af_need{"AF need (<1KB)"}++ 
		}
		elsif ((1024 <=${$row}[2]) && (${$row}[2] < 100 * 1024)) {
			$Af_need{"AF need (1KB<= X <100KB)"}++ 
		}
		elsif ((100 * 1024 <=${$row}[2]) && (${$row}[2] < 512 * 1024)) {
			$Af_need{"AF need (100KB<= X <500KB)"}++ 
		}
		elsif ((512 * 1024 <=${$row}[2]) && (${$row}[2] < 1024 * 1024)) {
			$Af_need{"AF need (500KB<= X <1MB)"}++ 
		}
		elsif ((1024 * 1024 <=${$row}[2]) && (${$row}[2] < 2 * 1024 * 1024)) {
			$Af_need{"AF need (1MB <= X <2MB)"}++ 
		}
		elsif ((2 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 3 * 1024 * 1024)) {
			$Af_need{"AF need (2MB <= X <3MB)"}++ 
		}
		elsif ((3 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 4 * 1024 * 1024)) {
			$Af_need{"AF need (3MB <= X <4MB)"}++ 
		}
		elsif ((4 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 5 * 1024 * 1024)) {
			$Af_need{"AF need (4MB <= X <5MB)"}++ 
		}
		elsif ((5 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 6 * 1024 * 1024)) {
			$Af_need{"AF need (5MB <= X <6MB)"}++ 
		}
		elsif ((6 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 7 * 1024 * 1024)) {
			$Af_need{"AF need (6MB <= X <7MB)"}++ 
		}
		elsif ((7 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 8 * 1024 * 1024)) {
			$Af_need{"AF need (7MB <= X <8MB)"}++ 
		}
		elsif ((8 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 9 * 1024 * 1024)) {
			$Af_need{"AF need (8MB <= X <9MB)"}++ 
		}
		elsif ((9 * 1024 * 1024 <=${$row}[2]) && (${$row}[2] < 10 * 1024 * 1024)) {
			$Af_need{"AF need (9MB <= X <10MB)"}++ 
		}
		elsif (${$row}[2] >= 10 * 1024 * 1024) {
			$Af_need{"AF need (10MB >= X)"}++ 
		}
		
		#last IO2 if $lineno > 5;
		$lineno++;
	}
	close $io;
	
	#use Data::Dumper;
	#print Dumper \%Af_need;
	print {$FH} $Af_need{"AF need (<1KB)"}."\n"; 
	print {$FH} $Af_need{"AF need (1KB<= X <100KB)"}."\n"; 
	print {$FH} $Af_need{"AF need (100KB<= X <500KB)"}."\n";
	print {$FH} $Af_need{"AF need (500KB<= X <1MB)"}."\n";
	print {$FH} $Af_need{"AF need (1MB <= X <2MB)"}."\n";
	print {$FH} $Af_need{"AF need (2MB <= X <3MB)"}."\n";
	print {$FH} $Af_need{"AF need (3MB <= X <4MB)"}."\n";
	print {$FH} $Af_need{"AF need (4MB <= X <5MB)"}."\n";
	print {$FH} $Af_need{"AF need (5MB <= X <6MB)"}."\n";
	print {$FH} $Af_need{"AF need (6MB <= X <7MB)"}."\n";
	print {$FH} $Af_need{"AF need (7MB <= X <8MB)"}."\n";
	print {$FH} $Af_need{"AF need (8MB <= X <9MB)"}."\n";
	print {$FH} $Af_need{"AF need (9MB <= X <10MB)"}."\n";
	print {$FH} $Af_need{"AF need (10MB >= X)"}."\n";
	print {$FH} ($lineno-1)."\n";
}