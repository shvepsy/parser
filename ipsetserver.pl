#!/usr/bin/env perl
use strict;
use Socket;
use POSIX qw(strftime);

# use port 4444 as default
my $port = shift || 4444;
my $proto = getprotobyname('tcp');
my $server = "10.10.100.61";
my $logpath = "/var/log/unban.log";
my $listpath = "ipset -L";
my $delpath = "ipset del";

# create a socket
socket(SOCKET, PF_INET, SOCK_STREAM, $proto)
 or die "Can't open socket $!\n";
setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1)
 or die "Can't set socket option to SO_REUSEADDR $!\n";

# bind to a port, then listen
bind( SOCKET, pack_sockaddr_in($port, inet_aton($server)))
 or die "Can't bind to port $port! \n";

listen(SOCKET, SOMAXCONN) or die "listen: $!";

open (LOG, ">>$logpath") or die "Cannot open $logpath: $!";
my $time = strftime "%e %b %H:%M:%S %Y", localtime;
print LOG "$time\tServer started on port $port\n";
LOG->flush();

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

   # execute
   if ($req_method eq "check" ) {
     my (@ipset) = Check($req_ip);
     my $time = strftime "%e %b %H:%M:%S %Y", localtime;
     print LOG "$time - $client_ip - $req_method $ipset[0] $ipset[1]\n";
     print NEW_SOCKET "$ipset[1] banned in $ipset[0] table.\n";
    }
    elsif ($req_method eq "del" ) {
      my ($del,@ipset) = Delete($req_ip);
      if (!$del) {my $time = strftime "%e %b %H:%M:%S %Y", localtime; print LOG "$time - $client_ip - $req_method   $ipset[0] $ipset[1]\n"; print NEW_SOCKET "Unbanned!\n";} else {print NEW_SOCKET "ERROR:ban\n"};
    }
    else  { print NEW_SOCKET "ERROR: Case\n" }
   close NEW_SOCKET;
   LOG->flush();
}
close LOG;

# func Check: getting ipset tablename and hash:ip,port,ip int @ipset for check or delete from table
sub Check {
  my ($req_ip) = @_;
  my $cmd = "$listpath | egrep \'Name: BAN|$req_ip\' | sed -e \'s| timeout.*||g\' -e \'s|Name: ||g\' | grep -P \'^\\\d\+\' -B 1 | grep -v \'^--\'";
  my @ipset = `$cmd`;
  print @ipset;
  print $#ipset;
  my $c = $#ipset;
  print "\'$c\'" ;
  if (!$ipset[1] or $ipset[1] !~ /$req_ip\,/ ) { print NEW_SOCKET "Not banned.\n"; close NEW_SOCKET; next }
  chomp (@ipset);
  return @ipset;
  }

# func Delete: ipset del tablename hash from @ipset
sub Delete {
  my ($req_ip) = @_;
  my (@ipset) = Check($req_ip);
  my $cmd = "$delpath $ipset[0] $ipset[1]";
  my $del = `$cmd`;
  return $del, @ipset;
}
