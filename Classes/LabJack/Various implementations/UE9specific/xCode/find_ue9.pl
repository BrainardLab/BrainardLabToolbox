#!/usr/bin/perl
# By:	Roger Svenning
# Date:	2012-12-16
 
use strict;
use warnings;
 
use IO::Socket::INET;
 
# Send data immediately without buffering
$| = 1;

# Find out; Our IP-address, our Broadcast_address, our Netmask.
# We use the first running IP interface we find.
# If there are several, this approach may fail. Sending the broadcast on the wrong network.
my $inet_adr__Bcast__Mask = `ifconfig -a | grep 'inet addr:' | grep  'Bcast:' | grep 'Mask:' | head -1`;

# print "$inet_adr__Bcast__Mask" . "\n";

$inet_adr__Bcast__Mask =~ m/\s*inet addr:([0-9,\.]*)\s*Bcast:([0-9,\.]*)\s*Mask:([0-9,\.]*)/;
my $inetAddr = $1;
my $broadCastAddress = $2;
my $netMask = $3;

# print "inetAddr is $inetAddr" . "\n" . "broadCastAddress is $broadCastAddress" . "\n" . "netMask is $netMask" . "\n";

# We need two processes for this;
#	One that listen for the reply from the UE9. (The child.)
#	One that send the broadcast asking for the UE9 to reply. (The parent.)
my $pid = fork;

if ( $pid == 0 ){
	# This is the child process.
	my ($socket,$data);
 
	#  Create a new UDP socket, we want to listen for the reply sent from the UE9.
	$socket = new IO::Socket::INET (
    	LocalPort => 52363,
    	Proto        => 'udp'
	) or die "Child, ERROR creating socket : $!\n";

	print "# Child,  listening on port 52363 (UDP)" . "\n";
 
	my ($datagram,$flags);
	my ($ipAddr1, $ipAddr2, $ipAddr3, $ipAddr4);
	my ($ipGate1, $ipGate2, $ipGate3, $ipGate4);
	my ($ipSubn1, $ipSubn2, $ipSubn3, $ipSubn4);
	my ($portA, $portB);
	my (${mac1}, ${mac2}, ${mac3}, ${mac4}, ${mac5}, ${mac6});

	# Wait for the reply from the UE9.
    	$socket->recv($datagram,42,$flags);

	# Decode (unpack) the reply sent from the UE9.
    	(	${ipAddr1}, ${ipAddr2}, ${ipAddr3}, ${ipAddr4},
    		${ipGate1}, ${ipGate2}, ${ipGate3}, ${ipGate4},
    		${ipSubn1}, ${ipSubn2}, ${ipSubn3}, ${ipSubn4},
		${portA},		${portB},
		${mac1}, ${mac2}, ${mac3}, ${mac4}, ${mac5}, ${mac6}) = unpack ('x10C4C4C4vvxx(H2)12', $datagram);
    	print "# Child,  datagram received:" . "\n";
	print "UE9_IP_address" .  "\t"  . "${ipAddr4}.${ipAddr3}.${ipAddr2}.${ipAddr1}" . "\n";
    	print "UE9_IP_gateway" .  "\t"  . "${ipGate4}.${ipGate3}.${ipGate2}.${ipGate1}" . "\n";
    	print "UE9_IP_subnet " .  "\t"  . "${ipSubn4}.${ipSubn3}.${ipSubn2}.${ipSubn1}" . "\n";
    	print "UE9_portA" .       "\t"  . "${portA}" . "\n";
    	print "UE9_portB" .       "\t"  . "${portB}" . "\n";
    	print "UE9_MAC_address" . "\t"  . "${mac6}:${mac5}:${mac4}:${mac3}:${mac2}:${mac1}" . "\n";
 
	$socket->close();
	exit 0;
}

# This is the parent process.
# Slow down, give the child time to set up the port for listening.
sleep 2;

#print "# Parent, about to initialize socket." . "\n";
my $sock = new IO::Socket::INET(
	LocalAddr => "${inetAddr}",
	PeerAddr => "${broadCastAddress}",
	PeerPort => 52362,
	Proto => 'udp',
	Timeout => 5,
	Broadcast => 1) or die('Parent, Error opening socket.');

$sock->sockopt(SO_BROADCAST, 1);

print "# Parent, about to send broadcast, " .
      "from IP-address: ${inetAddr} to Broadcast-address: ${broadCastAddress}, Port: 52362" . "\n";
my $data = "\x22" . "\x78" . "\x00" . "\xA9" . "\x00" . "\x00";
print ${sock} ${data};

$sock->close();

# Wait for the child to finish.
wait;
#print "# Parent, child terminated." . "\n";
