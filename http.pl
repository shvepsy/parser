#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Cookies;
require HTTP::Request;
my $site = shift;

if (defined $site == 0) {
  print "Enter site URL: ";
  $site = (<STDIN>);
};

#on what site
my $pr = (print"Site: $site\n");

#init uagent
my $ua = LWP::UserAgent->new;
$ua->agent("ChromeFrome/0.1");

#Go request
my $req = HTTP::Request->new(GET => "http://$site");
#$req->content_type('text/html');

my $res = $ua->request($req);

#check response
if ($res->is_success) {
my $rez = $res->content;
#print "$rez\n\n";
$rez =~ s|><|>\n<|g ;
print "$rez";
}
else {
print $res->status_line, "\n";
}
;
#windows win+R wait
my $wait = (<STDIN>);
