#!/usr/bin/perl
use strict;
use warnings;
use File::Tail;
use Digest::MD5 qw(md5 md5_hex md5_base64);
my $ct = 0;
#my @ips2000;
my %hash;
my $lflow = File::Tail->new(name      => "/var/log/nginx/access.host.log",
                      interval      => 0.1,
                      maxinterval   => 0.5,
                      maxbuf        => 512000);
print "Log have been read\n" if defined($lflow);
while (defined(my $line= $lflow->read)) {
   #print "$line";
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

#print $hash{$ct}->{ip}."\n";
   if ($ct >= 500) {
     $ct = 0;
     foreach my $key ( sort sort_func keys %hash) {
       print $hash{$key}->{domain}." ".$hash{$key}->{ip}." ".$hash{$key}->{md}."\n";
     }
     sub sort_func { $hash{$a}->{domain} cmp $hash{$b}->{domain} ||
     $hash{$a}->{ip} cmp $hash{$b}->{ip};
      }
         # print $hash;
   #foreach my $value(values %hash) {
  #   print "$value\n";
  # };
  exit 0;
   };
   $ct++;
 };

#2000ips
#$ips2000[$ct] = "$req_ip $URL $ua\n";
#$ip[$ct] = "$ips";

#if ($ct >= 2000) {
  #print @ips2000;
#  my @uniq = @ips2000;
#  my $ident = @ips2000 =~ m/\.d+/g ;
#  print $ident;
#  $ct = 0;
#};
#my $dg = md5_base64($domain,$req_ip,$URL);
#print $dg."\n\n";
  #print "$domain\t\t\t$req_ip\t$URL\t\n";

#} ;
