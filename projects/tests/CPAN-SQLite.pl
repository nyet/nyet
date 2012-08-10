use strict;
use Data::Dumper;
use CPAN::SQLite;
my $query = CPAN::SQLite->new(
					db_dir => 'C:/CPANTesters/cpan',
					max_results => 1);
#$query->index(setup => 1);
$query->index(reindex => 'DBD::Oracle');

$query->query(mode => 'module', name => 'DBD::Oracle');
my $results = $query->{results};
print "DBD::Oracle: ".Dumper($results);

$query->query(mode => 'module', name => 'PYTHIAN/DBD-Oracle-1.47_00.tar.gz');
my $results = $query->{results};
print "DBD::Oracle: ".Dumper($results);

