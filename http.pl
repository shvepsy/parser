#!/usr/bin/perl !!!!!!!1
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Cookies;
require HTTP::Request;
my $site = shift;

#$print("$var1 $var2 $var3\n");
#on what site
my $pr = (print"Site: $site\n");
#my $site=(<STDIN>);

#init uagent
my $ua = LWP::UserAgent->new;
$ua->agent("ChromeFrome/0.1");

#Go request
my $req = HTTP::Request->new(GET => "http://$site");
#$req->content_type('text/html');

my $res = $ua->request($req);

#check response
if ($res->is_success) {
print $res->content;
}
else {
print $res->status_line, "\n";
}
;
