#!/bin/perl
use strict;
use warnings;
#use Socket;
use IO::Socket;
#SocClient

my $host="10.10.100.240";
my $port="8888";

my $socket = IO::Socket::INET->new(
PeerAddr  => $host,
PeerPort  => $port,
Proto     => 'tcp',
Timeout   => 50,
Type      => SOCK_STREAM) or die "Couldn't connect to $host:$port : $@\n";

#socket(SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
#my $iaddr = inet_aton("$host"); # IP to binary
#print $iaddr;
#my $faddr = sockaddr_in($port, $iaddr); # IP:port to SOCK
#connect(SOCK, $faddr);
#send (SOCK, "GET / HTTP/1.1\nHost: $host\n\n", 0);
print $socket "GET / HTTP/1.1\nHost: $host\n\n";
while ( <$socket> ) { print "response: $_" };
#my @resp = <$socket>;
#print @resp;
#my @data=<SOCK>;
#close(SOCK);
#print @data;
