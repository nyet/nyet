use AnyEvent::Twitter::Stream; #AnyEvent-Twitter-Stream

  my $guard = AnyEvent::Twitter::Stream->new(
      username => 'nyet',
      password => 'pa55word',
      method   => "filter",
      track    => "perl",
      on_tweet => sub { 
		my $tweet = shift;
		printf "%s: %s\n", $tweet->{user}{screen_name}, $tweet->{text};
      },
  );


# http://bulknews.typepad.com/blog/2009/09/asynchronous-programming-with-anyevent.html