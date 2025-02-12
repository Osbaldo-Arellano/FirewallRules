#!/bin/bash

iptables -P INPUT DROP     # Blocks all incoming traffic
iptables -P OUTPUT DROP    # Blocks all outgoing traffic

# Allow localhost traffic
iptables -A INPUT -i lo -j ACCEPT    
iptables -A OUTPUT -o lo -j ACCEPT    

# Allow DNS queries for both UDP and TCP
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT   
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT   

# Allow outgoing web traffic for HTTP and HTTPS
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m state --state NEW -j ACCEPT

# Allows outgoing TCP web traffic on ports 80 (HTTP) and 443 (HTTPS)
iptables -A OUTPUT -p udp -m multiport --dports 443 -m state --state NEW -j ACCEPT

# Allow established connections for inbound and outbound traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allows approved incoming traffic
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Log any packets that are dropped.
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: "
iptables -A OUTPUT -j LOG --log-prefix "IPTables-Dropped: "
