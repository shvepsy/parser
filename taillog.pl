GNU nano 2.2.6                                                                   File: taillog.pl

#!/usr/bin/perl
use strict;
use warnings;
use File::Tail;
use Digest::MD5 qw(md5 md5_hex md5_base64);
my $ct = 0;
my $lflow = File::Tail->new(name      => "/var/log/nginx/access.host.log",
                      interval      => 0.1,
                      maxinterval   => 0.5,
                      maxbuf        => 512000);
print "Log have been read\n" if defined($lflow);
while (defined(my $line= $lflow->read)) {
   #print "$line";
my ($domain, $req_time, $req_ip, $date, $URL, $resp_st, $size, $ref, $ua ) = $line =~
m/^"(\S+)" - (\S+) (\S+) - - \[(.*)] "(.*)" (\d+) (\d+) "(.*)" "(.*)"/;
my $ips200[$ct] = $ip ;
++$ct;
if ($ct >= 200) {
  print @ips200;
  $ct = 0;
}

#my $dg = md5_base64($domain,$req_ip,$URL);
#print $dg."\n\n";
  #print "$domain\t\t\t$req_ip\t$URL\t\n";

} ;
