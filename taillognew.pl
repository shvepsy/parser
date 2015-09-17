#!/usr/bin/perl
use strict;
use warnings;
use File::Tail;
use Digest::MD5 qw(md5 md5_hex md5_base64);
my $ct = 0;
my $border = 50; #
my %hash;
my %hs;
my $count;
my @ua;
my $txt = "";
my $pr = "";
my $lflow = File::Tail->new(name      => "/var/log/nginx/access.host.log",
                      interval      => 0.1,
                      maxinterval   => 0.5,
                      maxbuf        => 512000);
print "Log read.\n" if defined($lflow);

# Parse string
while (defined(my $line= $lflow->read)) {
   my ($domain, $upstream_cache_status, $request_time, $req_ip, $xz, $xz2, $date, $timezone, $method, $url, $http_v, $resp_st, $size, $ref, @ua ) = split(" ", $line);
#   print join( " ",($domain, $upstream_cache_status, $request_time, $req_ip, $xz, $xz2, $date, $timezone, $method, $url, $http_v, $resp_st, $size, $ref, @ua, " \n" ));
  my $ua = join (" ", @ua);


   # Save that req in hash
   %hash = (
     %hash, $ct => {
       domain => $domain,
       req_ip => $req_ip,
       date   => $date,
       method => $method,
       url    => $url,
       http_v => $http_v,
       size   => $size,
       ref    => $ref,
       ua     => $ua,
     },
   );
   write;
   $ct++;
    exit 0 if $ct == 1000;
 };


 format STDOUT =
 @<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<< @*
  $hash{$ct}->{domain}, $hash{$ct}->{req_ip}, $hash{$ct}->{ua}
.
