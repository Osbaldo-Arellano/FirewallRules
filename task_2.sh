#!/bin/bash

# Blocks all incoming and outgoing traffic that is not whitelisted.
iptables -P INPUT DROP      
iptables -P OUTPUT DROP 

# Allow localhost traffic.
iptables -A INPUT -i lo -j ACCEPT

# Allow responses to outgoing traffic.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 

# Allow SSH connections on port 22 from 198.51.100.1 from eth0.
iptables -A INPUT -i eth0 -p tcp --dport 22 -s 198.51.100.1 -m state --state NEW -j ACCEPT

# Log any dropped incoming packets.
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: "   

# Allow traffic from 192.168.1.0/24 from interface eth1 to eth0.
iptables -A FORWARD -i eth1 -o eth0 -s 192.168.1.0/24 -j ACCEPT

# Allow DMZ 10.0.0.0/24 to send DNS and NTP traffic over UDP.
iptables -A FORWARD -i eth2 -o eth0 -s 10.0.0.0/24 -p udp -m multiport --dports 53,123 -m state --state NEW -j ACCEPT

# Allow DMZ 10.0.0.0/24 to send DNS and NTP traffic over TCP.
iptables -A FORWARD -i eth2 -o eth0 -s 10.0.0.0/24 -p tcp --dport 53 -m state --state NEW -j ACCEPT

# Drop all other outbound traffic from the DMZ.
iptables -A FORWARD -i eth2 -o eth0 -s 10.0.0.0/24 -j DROP

# Traffic from the internet to 10.0.0.10 from eth2 is allowed on ports 80 (HTTP) and 443 (HTTPS).
iptables -A FORWARD -i eth0 -o eth2 -d 10.0.0.10 -p tcp -m multiport --dports 80,443 -m state --state NEW -j ACCEPT

# Allow FTP traffic (port 21) to the FTP server in the DMZ (10.0.0.20) from 203.0.113.0/24.
iptables -A FORWARD -i eth0 -o eth2 -d 10.0.0.20 -p tcp --dport 21 -s 203.0.113.0/24 -m state --state NEW -j ACCEPT

# Drop all other incoming traffic from the internet destined for any DMZ host.
iptables -A FORWARD -i eth0 -o eth2 -d 10.0.0.0/24 -j DROP

# Allow SMTP traffic (port 25) from the internet to the internal mail server at  192.168.1.200 only if the source is in smtp_whitelist.
iptables -A FORWARD -i eth0 -o eth1 -d 192.168.1.200 -p tcp --dport 25 -m state --state NEW -m set --match-set smtp_whitelist src -j ACCEPT

# Drop all other traffic from the internet attempting to reach the internal network.
iptables -A FORWARD -i eth0 -o eth1 -d 192.168.1.0/24 -j DROP

# Log any dropped forwarded packets.
iptables -A FORWARD -j LOG --log-prefix "IPTables-Dropped: "