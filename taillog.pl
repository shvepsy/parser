#!/usr/bin/perl
use strict;
use warnings;
use File::Tail;
use Digest::MD5 qw(md5 md5_hex md5_base64);
my $ct = 0;
#my @ips2000;
my %hash;
my $count;
my $txt = "";
my $pr = "";
my $lflow = File::Tail->new(name      => "/var/log/nginx/access.host.log",
                      interval      => 0.1,
                      maxinterval   => 0.5,
                      maxbuf        => 512000);
print "Log have been read\n" if defined($lflow);
while (defined(my $line= $lflow->read)) {
   my ($domain, $req_time, $req_ip, $date, $URL, $resp_st, $size, $ref, $ua ) = $line =~
   m/^"(\S+)" - (\S+) (\S+) - - \[(.*)] "(.*)" (\d+) (\d+) "(.*)" "(.*)"/;
   my $md5 = md5_base64("$URL,$ua");
   %hash = ( %hash,$ct => {
     domain  => $domain,
     ip      => $req_ip,
     req     => $URL,
     ua      => $ua,
     md      => $md5,
   },
   );
   $ct++;
   if ($ct >= 1000) {
     $ct = 0;
     foreach my $key ( sort sort_func keys %hash) {
       $txt = $txt.$hash{$key}->{domain}." ".$hash{$key}->{ip}." ".$hash{$key}->{md}."\n";
     }
     sub sort_func { $hash{$a}->{domain} cmp $hash{$b}->{domain} ||
      $hash{$a}->{ip} cmp $hash{$b}->{ip};
      }
      foreach my $ks (keys %hash) {
        my $iphsh = $hash{$ks}->{ip};
        $count = $txt =~ s/$iphsh//g;
        $pr = $pr.$hash{$ks}->{ip}." ".$count."\n";
      }
      $pr =~ s/\S+\s\n//g ;
      #split ( /\n/, $pr)
      print $pr;
    exit 0;
   };
 };
