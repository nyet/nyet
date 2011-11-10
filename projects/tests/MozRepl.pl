use MozRepl;

my $repl = MozRepl->new;
$repl->setup; ### You must write it.
print $repl->repl_inspect({ source => 'window.getBrowser().contentWindow.location' });

#$repl->execute(q|window.alert("Internet Explorer:<")|);
#print $repl->repl_inspect({ source => "window" });
#print $repl->repl_search({ pattern => "^getElement", source => "document"});

#https://github.com/bard/mozrepl/wiki/Tutorial

#activemq 