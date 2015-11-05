#!/usr/bin/env perl

use strict;
use Socket;

# use port 4444 as default
my $port = shift || 4444;
my $proto = getprotobyname('tcp');
my $server = "192.168.1.36";

# create a socket
socket(SOCKET, PF_INET, SOCK_STREAM, $proto)
 or die "Can't open socket $!\n";
setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1)
 or die "Can't set socket option to SO_REUSEADDR $!\n";

# bind to a port, then listen
bind( SOCKET, pack_sockaddr_in($port, inet_aton($server)))
 or die "Can't bind to port $port! \n";

listen(SOCKET, SOMAXCONN) or die "listen: $!";

print "Server started on port $port\n";

# accepting a connection
my $client_addr;
while ($client_addr = accept(NEW_SOCKET, SOCKET)) {
   # send them a message, close connection
   my ($clinet_port,$client_ipn) = sockaddr_in($client_addr);
   my $client_ip = inet_ntoa($client_ipn);
   my $data = <NEW_SOCKET>;
   my ($req_method, $req_ip ) = split(" ", $data) ;

   # verification received data
   unless ($req_method eq "check"||$req_method eq "del") { print NEW_SOCKET "ERROR: Invalid method\n"; close NEW_SOCKET; next; };
   unless ($req_ip=~/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ &&(($1<=255  && $2<=255 && $3<=255  &&$4<=255 ))) { print NEW_SOCKET "ERROR: Invalid IP\n"; close NEW_SOCKET; next; };
   my $ipset[2] = "BAN";
   # execute
   if ($req_method eq "check" ) {
      my $cmd = "ipset -L | egrep \'Name: BAN|$req_ip\' | sed -e \'s| timeout.*||g\' -e \'s|Name: ||g\' | grep -P \'^\\\d\+\' -B 1 | grep -v \'^--\' | head -n 2";
      my @ipset = `$cmd`;
      chomp ($ipset[0],$ipset[1]);
      if (!@ipset[1]) { print NEW_SOCKET "Not ban.\n"; close NEW_SOCKET; next };
      print "$req_method $ipset[0] $ipset[1]\n";
      print NEW_SOCKET "$ipset[1] banned in $ipset[0] table.\n"
    }
    elsif ($req_method eq "del" ) {
      my $cmd = "ipset -L | egrep \'Name: BAN|$req_ip\' | sed -e \'s| timeout.*||g\' -e \'s|Name: ||g\' | grep -P \'^\\\d\+\' -B 1 | grep -v \'^--\' | head -n 2";
      my @ipset = `$cmd`;
      chomp ($ipset[0],$ipset[1]);
      print "$req_method @ipset";
      #my $cmd = "/home/firewall/firewall.sh ipsetdel $ipset[0] $ipset[1]";
      my $cmd = "ipset del $ipset[0] $ipset[1]";
      my @del = `$cmd`;
      #print "\"@del\"";
      if (@del == "") { print NEW_SOCKET "Not banned\n" } else { print NEW_SOCKET "Unbanned!\n" };
    }
    else  { print NEW_SOCKET "ERROR: Case\n" }
    my (@ipset, $cmd, @del) = "0";
   close NEW_SOCKET;
}
