use DBI;

open FILE, "";

__DATA__
my $host = "xxx.xxx.xxx.xxx";
my $dbh = DBI->connect("dbi:ODBC:driver=SQL Server;server=$host;database=xxx;Trusted Connection=yes", "", "", {
	PrintError => 0,
	RaiseError => 0,
}) or die "\n\nthe mssql connection died with the following error: \n\n$DBI::errstr\n\n";
print "dbh: $dbh\n";
my $sth0 = $dbh->prepare(qq{SELECT *  FROM TABLE WHERE XXX = '1';});
$sth0->execute();
my $hash_ref = $sth0->fetchrow_hashref;
foreach my $key (keys %{$hash_ref}) {
	print "$key: $hash_ref->{$key}\n";
}
$sth0->finish();
$dbh->disconnect;

#__DATA__
http://www.perlmonks.org/?node_id=639105
http://www.perlmonks.org/index.pl?node_id=673578
