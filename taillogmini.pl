#!/usr/bin/perl
use strict;
use warnings;
use File::Tail;
my $ct = 0;
my %hash;
my $lflow = File::Tail->new(name      => "/var/log/nginx/access.host.log",
                      interval      => 0.1,
                      maxinterval   => 0.5,
                      maxbuf        => 512000);
print "Log have been read\n" if defined($lflow);
while (defined(my $line= $lflow->read)) {
   my ($domain, $req_time, $req_ip, $date, $URL, $resp_st, $size, $ref, $ua ) = $line =~
   m/^"(\S+)" - (\S+) (\S+) - - \[(.*)] "(.*)" (\d+) (\d+) "(.*)" "(.*)"/;
   %hash = ( %hash,$ct => {
     domain  => $domain,
     ip      => $req_ip,
     req     => $URL,
     ua      => $ua,
   },
   );
   $ct++;
   if ($ct >= 1500) {
     $ct = 0;
     foreach my $key (keys %hash) {
      if ($hash{$key}->{domain} =~ m/\S+ornocaldo\.com/  ) {
         if ( $hash{$key}->{req} =~ m/GET \/.*\?.*\S+ HTTP.*/  ) {
           #exit 0;
           my $banip = $hash{$key}->{ip};
           print "Banned: $banip\t".$hash{$key}->{req}."\n";
           system ("/usr/sbin/ipset add test $banip -exist timeout 36000");
           }
         }
       }
    }
 };
