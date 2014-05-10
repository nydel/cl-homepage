#!/usr/bin/perl -wT

print "content-type: text/html\n\n";

use LWP::Simple;
my $url = 'http://nydel.sdf.org:9903/';
my $content = get $url;
die "couldn't resolve $url" unless defined $content;

print $content;
