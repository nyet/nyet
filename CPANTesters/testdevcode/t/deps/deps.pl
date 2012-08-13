use strict;
use v5.10.1;
use Data::Dumper;
use CPAN;
use LWP::UserAgent;
use YAML::XS;
use File::Basename;
use File::Path;
use Cwd;

my $platform = 'Perl5.16.0_64';

my $currDir = getcwd; #CPAN causes the current dir to change, use cwd.

#get lib core folder
(my $perlInstallDir = $^X) =~ s/[\\\/]bin[\\\/]perl.exe//;	#C:\CPANTesters\Perl5.16.0_64\bin\perl.exe
my $libCoreDir = "$perlInstallDir\\lib";

# test:
#my $mod = 'FreezeThaw';
#   Can not open Perl5.16.0_64/I/IL/ILYAZ/modules/FreezeThaw-0.5001.tar.gz.txt at deps.pl line 271.
#                                         ^       
#                                         |- additional directory
#my $mod = 'Task::BeLike::LESPEA';
#   Warning: 362 subroutine calls had negative time! The clock being used (-1) is probably unstable, so the results will be as well.
#   This is ok.
#my $mod = 'HTML::Tested::JavaScript'; 
#   Invalid version format (version required) at C:\CPANTesters\Perl5.16.0_64\site\lib/strictures.pm line 21.
#   2012/08/12: the error msg above is not reproduced anymore.
#my $mod = 'App::EvalServer';  
#   POE cause infinite loop dependencies.
#   2012/08/12: fixed.
#my $mod = 'App::RabbitTail';										# OK
#my $mod = 'Perinci'; 												# OK 
#TODO: Find mod that doesn't have Meta.YML
################################################################################
#notes:
#my $mod = 'Test::Fork';
# -> This is ok: Could not read metadata file. Falling back to other methods to determine prerequisites
#my $mod = '';

my $dependencies;
my $modules_scanned = {};
$dependencies = getDeps($mod, $dependencies, $modules_scanned);
print "dependencies: ".Dumper($dependencies);
print "modules_scanned: ".Dumper($modules_scanned);

sub getDepFile {
	my ($module) = @_;
	say "getDepFile:$module";
	if ($module =~ /::/) {
		use CPAN::SQLite;
		my $query = CPAN::SQLite->new(db_dir => 'C:/CPANTesters/cpan',
											max_results => 1);
		#$query->index(setup => 1);
		$query->query(mode => 'module', name => $module);
		my $results = $query->{results};
		my $cpanid = $results->{'cpanid'};
		my $dir1  = substr $cpanid, 0, 1;
		my $dir2  = substr $cpanid, 0, 2;
		return "$platform/$dir1/$dir2/$cpanid/$results->{'dist_file'}.txt";
	}
	else {
		if ($module =~ /^(.+?)[\/\\]/) {
			my $cpanid = $1;
			my $dir1  = substr $cpanid, 0, 1;
			my $dir2  = substr $cpanid, 0, 2;
			return "$platform/$dir1/$dir2/$module.txt";
		}
	}
	return "";
}

sub getDeps {
	my ($module, $deps_all, $scanned) = @_;
	
	my $deps = {};
	print "deps1:".Dumper $deps;
	my $lt = time;
	(my $logFileName = $module) =~ s/\W/_/g; 
	open my $LOG, ">$currDir/$0-$logFileName-$lt.log" or die "Can not open $0-$logFileName-$lt.log";
	say {$LOG} "perlInstallDir: $perlInstallDir";
	say {$LOG} "libCoreDir: $libCoreDir";
	say {$LOG} "module: $module";
	
	if ($module !~ /[\/\\]/) {
		my $old = $module; 
		use CPAN::SQLite;
		my $query = CPAN::SQLite->new(db_dir => 'C:/CPANTesters/cpan',
											max_results => 1);
		#$query->index(setup => 1);
		$query->query(mode => 'module', name => $module);
		my $results = $query->{results};
		print {$LOG} "	CPAN::SQLite query results: ".Dumper($results);
		$module = "$results->{'cpanid'}/$results->{'dist_file'}";
		say {$LOG} "	$old -> $module";
		say        "	$old -> $module";
	}
	
	#* install Module-A.
	#my $file = 'C:\CPANTesters\cpan\sources\authors\id\A\AB\ABIGAIL\Regexp-Common-2011121001.tar.gz';
	#my $module = 'ABIGAIL/Algorithm-Numerical-Sample-2010011201.tar.gz';
	#my $module = 'ABIGAIL/Acme-Time-Baby-2010090301.tar.gz';
	#my $module = 'PYTHIAN/DBD-Oracle-1.48.tar.gz';
	#my $module = 'PYTHIAN/DBD-Oracle-1.47_00.tar.gz';
	#my $module = 'CVEGA/WWW-MediaTemple-0.02.tar.gz';
	#my $module = 'DRTECH/Elastic-Model-0.08.tar.gz';
	my $cpanid;
	my $moduleName;
	my $moduleVersion;
	if ($module =~ /^(.+?)[\/\\]/) {
		$cpanid = $1;
	}
	say {$LOG} "	cpanid: $cpanid";
	
	#* Deps of Module-A -> Module-B and Module-C (%deps)
	my $dir1  = substr $module, 0, 1;
	my $dir2  = substr $module, 0, 2;
	my $file = "C:/CPANTesters/cpan/sources/authors/id/$dir1/$dir2/$module";
	say "	file: $file";
	if (!-f $file) {
		#CPAN::Shell->get($module); #Don't use this: http://stackoverflow.com/questions/11926684/any-idea-why-cpan-is-locked-in-circular-dependencies-although-i-only-issue-get/
		#say {$LOG} "	CPAN::Shell->get($module)";
		
		my $ua = LWP::UserAgent->new;
		$ua->agent("FetchAlaNyet/0.1");
		my $req = HTTP::Request->new(GET => "cpan:modules/by-authors/id/$dir1/$dir2/$module");
		my $res = $ua->request($req);
		if ($res->is_success) {
			mkpath(dirname($file)) if !-d dirname($file);
			open my $DISTRO, ">", $file or die "Can not open $file";
			binmode $DISTRO;
			print {$DISTRO} $res->content;
			close $DISTRO;
		}
		else {
			say {$LOG} "	ERROR: failed fetching $module, stat: ".$res->status_line;
			close $LOG;
			die $res->status_line;
		}
		say {$LOG} "	fetched $module -> $file";
	}
	else {
		say {$LOG} "	file($file) exists";
	}
	
	use Archive::Tar;
	my $tar = Archive::Tar->new;
	$tar->read($file);
	#say join("\n", $tar->list_files());
	my $whole;
	#print "	deps2:".Dumper \%deps;
	foreach my $archiveFile ($tar->list_files()) {
		if ($archiveFile =~ /[\\\/]META.yml$/) {
			$whole = $tar->get_content($archiveFile);
			#print $whole;
			my $yml = Load $whole;
			print {$LOG} "	META.yml:".Dumper $yml;
			
			$Data::Dumper::Pad = "\t";
			$moduleName = $yml->{name};
			$moduleVersion = $yml->{version};
			say {$LOG} "	moduleName: $moduleName";
			say {$LOG} "	moduleVersion: $moduleVersion";
			if (exists $yml->{requires}) {
				print        "	requires:".Dumper $yml->{requires};
				print {$LOG} "	requires:".Dumper $yml->{requires};
				$deps = merge_modules($yml->{requires}, $deps, $deps_all);
			}
			if (exists $yml->{build_requires}) {
				print        "	build_requires:".Dumper $yml->{build_requires};
				print {$LOG} "	build_requires:".Dumper $yml->{build_requires};
				$deps = merge_modules($yml->{build_requires}, $deps, $deps_all);
			}
			if (exists $yml->{test_requires}) {
				print        "	test_requires:".Dumper $yml->{test_requires};
				print {$LOG} "	test_requires:".Dumper $yml->{test_requires};
				$deps = merge_modules($yml->{test_requires}, $deps, $deps_all);
			}
			
			sub merge_modules {
				my ($yml_def_1, $deps_1, $deps_all_1) = @_;
				#print Dumper $yml_def;
				foreach my $module ( keys %{$yml_def_1} ) {
					#say "	merge module $module";
					if (exists $deps_1->{$module}) {
						if ($deps_1->{$module} < $yml_def_1->{$module}) {
							$deps_1->{$module} = $yml_def_1->{$module};
						}
					}
					else {
						$deps_1->{$module} = $yml_def_1->{$module};
					}
					
					if (exists $deps_all_1->{$module}) {
						if ($deps_all_1->{$module} < $yml_def_1->{$module}) {
							$deps_all_1->{$module} = $yml_def_1->{$module};
						}
					}
					else {
						$deps_all_1->{$module} = $yml_def_1->{$module};
					}
				}
				return $deps_1;
			}
			print {$LOG} "	deps:".Dumper $deps;
			print        "	$moduleName:deps3:".Dumper $deps;
		}
	}
	if (!$whole) {
		say {$LOG} "	META.yml doesn't exist";
	}
	
	(my $moduleNameSpace = $moduleName) =~ s/-/::/g;
	$deps_all->{$moduleNameSpace} = 0; #<-only module name
	
	say {$LOG} "	Check the modules:";
	
	my @modules_tobedeleted;
	#* if Module-B is installed:
	foreach my $module ( keys %{$deps} ) {
		if ($module eq 'perl') {
			say {$LOG} "		$module($deps->{$module}) => $]";
			# TODO need to work on this.
		}
		else {
			my $moduleInstalledVersion;
			eval "require $module";
			if ($@) {
				say {$LOG}	"		$module is not detected";
				say      	"		$module is not detected";
				#-> spawn another one to get the dependencies of this module.
				#system "start perl deps.pl $module";
				my $distribution;
				if ($module !~ /[\/\\]/) {
					use CPAN::SQLite;
					my $query = CPAN::SQLite->new(db_dir => 'C:/CPANTesters/cpan',
														max_results => 1);
					#$query->index(setup => 1);
					$query->query(mode => 'module', name => $module);
					my $results = $query->{results};
					#print {$LOG} "	CPAN::SQLite query results: ".Dumper($results);
					$distribution = "$results->{'cpanid'}/$results->{'dist_file'}";
					#say        "	$module -> $distribution";
				}
				if (!exists $scanned->{$distribution}) {
					$deps_all = getDeps($module, $deps_all, $scanned);
				}
			}
			else {
				$moduleInstalledVersion = $module->VERSION;
				say {$LOG} "		$module => $moduleInstalledVersion";
				
				(my $pm_file = $module) =~ s/(::|-)/\//g;
				$pm_file .= ".pm";
				my $found = 0;
				LIBDIR:foreach my $libDir (@INC) {
					if ($libDir ne $libCoreDir) {
						if (-f "$libDir/$pm_file") {
							say {$LOG}	"			module is NOT CORE"; # the module is already installed, do nothing
							$found = 1;
							last LIBDIR;
						}
					}
					else {
						if (-f "$libDir/$pm_file") {
							if ($moduleInstalledVersion < $deps->{$module}) {
								say {$LOG}	"			module is CORE, but need to be upgraded";
							}
							else {
								say {$LOG}	"			module is CORE installed($moduleInstalledVersion) >= needed($deps->{$module})"; #do nothing
								say {$LOG}	"			delete \$deps->{$module}";
								say      	"			delete \$deps->{$module}";
								push @modules_tobedeleted, $module;
								#print "	$moduleName:deps4:".Dumper($deps);
							}
							$found = 1;
							last LIBDIR;
						}
					}
				}
				if (!$found) {
					say {$LOG}	"			ERROR in logic:module is not found -> trace: $pm_file";
				}
			}
		}
	}
	
	map { 
		delete $deps->{$_};
		delete $deps_all->{$_}; 
	} @modules_tobedeleted;
	
	print {$LOG} "	deps:".Dumper($deps);
	print        "	$moduleName:deps5:".Dumper($deps);
	my $ymlDumpFile = "$currDir/$platform/$dir1/$dir2/$module.txt";
	if (!-d dirname($ymlDumpFile)) {
		mkpath(dirname($ymlDumpFile));
	}
	open YML, ">$ymlDumpFile" or die "Can not open $ymlDumpFile";
	print YML Dump($deps);
	close YML;
	
	#Can not open Perl5.16.0_64/T/TE/TELS/math/Math-Big-1.12.tar.gz.txt at deps.pl line 267.
	#Warning: 272 subroutine calls had negative time! The clock being used (-1) is probably unstable, so the results will be as well.
	
	$scanned->{$module} = 0;
	
	return $deps_all;
}

__DATA__
perl deps.pl MooseX::Types::Moose
perl deps.pl DROLSKY/MooseX-Types-0.35.tar.gz
perl deps.pl PHAYLON/MooseX-Types-0.34.tar.gz
perl deps.pl Elastic::Model
perl deps.pl HTML::Tested::JavaScript
ElasticSearch::SearchBuilder
################################################################################
my @arrays = keys %{$modulesToTrace};
while ($#arrays != -1) {
	foreach my $mod (keys %{$modulesToTrace}) {
		my $depFile = getDepFile($mod);
		if (!-f $depFile) {
			my ($dep, $mods) = getDeps($mod);
		}
		else {
			
		}
	}
	@arrays = keys %{$modulesToTrace};
}
################################################################################
say "MooseX::Types: ".getDepFile("MooseX::Types");
say "PHAYLON/MooseX-Types-0.34.tar.gz: ".getDepFile("PHAYLON/MooseX-Types-0.34.tar.gz");
MooseX::Types: Perl5.16.0_64/D/DR/DROLSKY/MooseX-Types-0.35.tar.gz.txt
PHAYLON/MooseX-Types-0.34.tar.gz: Perl5.16.0_64/P/PH/PHAYLON/MooseX-Types-0.34.tar.gz.txt
################################################################################
use Parse::CPAN::Packages;
my $p = Parse::CPAN::Packages->new("C:/CPANTesters/cpan/sources/modules/02packages.details.txt.gz");
my $m = $p->package($module);
say "\$m->package: ".$m->package;
say "\$m->version: ".$m->version;
my $d = $m->distribution();
say "\$d->cpanid: ".$d->cpanid;
################################################################################
C:\Users\vmuser\Desktop>perl deps.pl MooseX::Types::Moose
Set up gcc environment - gcc.exe (rubenvb-4.5.4) 4.5.4
$VAR1 = {
          'mod_id' => 77702,
          'auth_id' => 3147,
          'dslip' => undef,
          'dist_file' => 'MooseX-Types-0.35.tar.gz',
          'dist_id' => 16111,
          'mod_vers' => '0.35',
          'mod_abs' => undef,
          'mod_name' => 'MooseX::Types::Moose',
          'email' => 'autarch@urth.org',
          'dist_vers' => '0.35',
          'chapterid' => undef,
          'dist_name' => 'MooseX-Types',
          'fullname' => 'Dave Rolsky',
          'cpanid' => 'DROLSKY',
          'dist_abs' => undef,
          'download' => 'D/DR/DROLSKY/MooseX-Types-0.35.tar.gz'
        };
################################################################################
		foreach my $module ( keys %{$yml->{requires}} ) {
			$deps{$module} = $yml->{requires}->{$module};
			if ($module eq 'perl') {
				printf("%-20s: %s\n", $module, $]);
			}
			else {
				eval "require $module";
				if ($@) {
					say "$module is not detected";
				}
				else {
					printf( "%-20s: %s\n", $module, $module->VERSION );
				}
			}
		}
cpan -get ABIGAIL/Acme-CPANAuthors-Booking-2012062101.tar.gz
cpan> get ABIGAIL/Games-Word-Wordlist-Enable-2010090401.tar.gz -> works, but has to be inside the shell
cpan -i ABIGAIL/Tie-Pick-2009110701.tar.gz -> install!
cpan -D ABIGAIL/Tie-Counter-2009110701.tar.gz -> not working.
cpan -g ABIGAIL/The-Net-2009110702.tar.gz -> borked

$VAR1 = {
          'no_index' => {
                          'directory' => [
                                           't',
                                           'inc'
                                         ]
                        },
          'resources' => {
                           'repository' => 'git://github.com/Abigail/Regexp--Common.git'
                         },
          'test_requires' => {
                               'strict' => 0
                             },
          'meta-spec' => {
                           'version' => '1.4',
                           'url' => 'http://module-build.sourceforge.net/META-spec-v1.4.html'
                         },
          'generated_by' => 'ExtUtils::MakeMaker version 6.56',
          'distribution_type' => 'module',
          'version' => 2011121001,
          'name' => 'Regexp-Common',
          'author' => [
                        'Abigail <regexp-common@abigail.be>'
                      ],
          'license' => 'mit',
          'keywords' => [
                          'regular expression',
                          'pattern'
                        ],
          'build_requires' => {
                                'strict' => 0,
                                'ExtUtils::MakeMaker' => 0
                              },
          'requires' => {
                          'strict' => 0,
                          'perl' => '5.00473',
                          'vars' => 0
                        },
          'abstract' => 'Provide commonly requested regular expressions',
          'configure_requires' => {
                                    'strict' => 0,
                                    'ExtUtils::MakeMaker' => 0
                                  }
        };
################################################################################
--- #YAML:1.0
name:               Regexp-Common
version:            2011121001
abstract:           Provide commonly requested regular expressions
author:
    - Abigail <regexp-common@abigail.be>
license:            mit
distribution_type:  module
configure_requires:
    ExtUtils::MakeMaker:  0
    strict:               0
build_requires:
    ExtUtils::MakeMaker:  0
    strict:               0
requires:
    perl:    5.00473
    strict:  0
    vars:    0
resources:
    repository:  git://github.com/Abigail/Regexp--Common.git
no_index:
    directory:
        - t
        - inc
generated_by:       ExtUtils::MakeMaker version 6.56
meta-spec:
    url:      http://module-build.sourceforge.net/META-spec-v1.4.html
    version:  1.4
keywords:
    - regular expression
    - pattern
test_requires:
    strict:  0
################################################################################
use Archive::Extract; 
# flat extract can not limit to only a file inside a giant file. -> http://www.perlmonks.org/?node_id=808001
my $ae = Archive::Extract->new( archive => $file );
my $ok = $ae->extract( to => 'tmp' ) or die $ae->error;
my $files   = $ae->files;
use Data::Dumper;
print Dumper $files;



