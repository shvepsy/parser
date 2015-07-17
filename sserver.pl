#!/bin/perl
use strict;
use warnings;
#use Socket;
use IO::Socket;;
#SocServer
my $port = '8888';
my $ipash = `ifconfig`;
my($ipsrv) = $ipash =~ m/inet addr:(\S+)\s+Bcast/;
my $socket = IO::Socket::INET->new(
LocalAddr => $ipsrv,
LocalPort => $port,
Proto     => 'tcp') or die "Couldn't create socket on $port port : $@\n";
setsockopt($socket, SOL_SOCKET, SO_REUSEADDR, 1);
print ("Connections wait on $ipsrv:$port...\n");
listen($socket, SOMAXCONN);
while (my $client_addr = accept(CLIENT, $socket)) {
  my ($clinet_port,$client_ip) = sockaddr_in($client_addr);
  my $client_ipn  = inet_ntoa($client_ip);
my $data = <$socket>;
my $count = sysread(CLIENT, $data, 1024);
print "Received ${count} byts from ${client_ipn} :\n";
print $data;
print CLIENT "Data accepted.\n";
close(CLIENT);
}
close($socket);
