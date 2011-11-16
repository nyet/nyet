# $Id$

package MT::Plugin::Refeed;
use strict;
use warnings;

use base qw( MT::Plugin );

our $VERSION = '1.0';
my $plugin = MT::Plugin::Refeed->new({
    id                      =>  'refeed',
    name                    =>  'Refeed',
    version                 => $VERSION,
    blog_config_template    => 'blog_config.tmpl',
    author_name             => 'Benjamin Trott',
    author_link             => 'http://www.sixapart.com/',
    settings                => new MT::PluginSettings([
        [ 'feeds',  { Default => '', Scope => 'blog' } ],
        [ 'author', { Default => '', Scope => 'blog' } ],
    ]),
    description             =>  'Refeed allows you to pull in RSS and Atom feeds automatically into your Movable Type-powered blog.',
});
MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        tasks => {
            CheckFeeds => {
                label       => 'Check for updates to feeds (Refeed)',
                frequency   => 1 * 60,
                code        => sub {
                    check_feeds( $plugin );
                },
            },
        },
    });
}

sub check_feeds {
    my $plugin = shift;

    require DB_File;
    require Encode;
    require Feed::Find;
    require URI::Fetch;
    require XML::Feed;

    require File::Spec;
    my $history = File::Spec->catfile(
        MT->instance->static_file_path, 'support', 'refeed-history.db'
    );
    tie my %seen, 'DB_File', $history
        or die "Can't create history database $history: $!";

	use Data::Dumper;
	print "seen:".Dumper(\%seen);
	
    my $warn = sub {
        my $log = MT::Log->new;
        $log->message( 'Refeed: ' . $_[0] );
        $log->level( MT::Log->WARNING );
        MT->log( $log );
    };

    require MT::Author;
    require MT::Blog;
    my $iter = MT::Blog->search;
    while ( my $blog = $iter->() ) {
		print "Refeed:blog id:".$blog->id."\n";
        my $feeds = $plugin->get_config_value( 'feeds', 'blog:' . $blog->id )
            or next;
        my @feeds = split /\s+/, $feeds;

        my $name = $plugin->get_config_value( 'author', 'blog:' . $blog->id )
            or $warn->("No author defined for blog " . $blog->name), next;
        my( $author ) = MT::Author->search({ name => $name })
            or $warn->("No author by the name $name"), next;

		print "Refeed:author($name): $author\n";
		
        for my $uri ( @feeds ) {
			print "Refeed:uri: $uri\n";
            my @feeds = Feed::Find->find($uri)
                or $warn->("Can't find any feeds for $uri, skipping."), next;

            my $res = URI::Fetch->fetch( $feeds[0] )
                or $warn->("Can't fetch feed $feeds[0], skipping"), next;

            my $feed = XML::Feed->parse( \$res->content )
                or $warn->("Can't parse feed $feeds[0], skipping"), next;

            for my $entry ($feed->entries) {
                next if $seen{ $blog->id . $entry->id };

                my $id = post_to_mt( $author, $blog, $feed, $entry );
                MT->log(
                    sprintf "Refeed: Posted entry %s ('%s') as entry %d",
                        $entry->id, $entry->title, $id,
                );
                $seen{ $blog->id . $entry->id } = $id;
            }
        }
    }
}

sub post_to_mt {
    my( $author, $blog, $feed, $entry ) = @_;

    ## Ensure time is set properly by converting to UTC here.
    my $issued = $entry->issued;
    $issued->set_time_zone('UTC');

    my $content = sprintf <<HTML, $entry->content->body, $entry->link, $feed->link, $feed->title;
%s

<p>Read <a href="%s">this entry</a> on <a href="%s">%s</a>.</p>
HTML

    require MT::Permission;
    my($perms) = MT::Permission->search({
        author_id   => $author->id,
        blog_id     => $blog->id,
    });

    require MT::XMLRPCServer;

    no warnings 'redefine';
    local *MT::XMLRPCServer::_login = sub {
        return( $author, $perms );
    };
    local *MT::XMLRPCServer::Util::mt_new = sub {
        return MT->instance;
    };
    local *SOAP::Data::type = sub {
        my $class = shift;
        my( %param ) = @_;
        return $param{string};
    };

    my $id = metaWeblog->newPost(
        $blog->id,
        '',
        '',
        {
            title               => join(': ', $feed->title, $entry->title),
            description         => $entry->content->body,
            dateCreated         => $issued->iso8601 . 'Z',
            mt_convert_breaks   => 0,
            mt_keywords         => $entry->link,
        },
        1,
    );

    return $id;
}

1;
