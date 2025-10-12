#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then                  #checks that the user has run the file as root
    echo "Must have root access to run"
    false
fi

IFACE="eth0"
GATEWAY="192.168.0.1" 

echo "Bringing up interface: $IFACE"
ip link set "$IFACE" up         #starts up the ethernet interface

echo "Flushing existing IPs and routes"
ip addr flush dev "$IFACE"      #resets the IP for $IFACE
ip route flush dev "$IFACE"     #resets the gateway for $IFACE

read -p "Enter static IP address of the server: " IP_ADDRESS     #reads the chosen IP

if [ -z "$IP_ADDRESS" ]; then
    echo "No static IP provided. Exiting..."
    exit 1
fi

if [[ ! "$IP_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then  #checks IP is of the correct form
    echo "Invalid IP format"
    exit 1
fi

echo "Configuring new interface"
ip addr add "$IP_ADDRESS"/24 dev "$IFACE"                      #adds the given IP address for the eth0 interface
ip route add default "$GATEWAY"                                #adds the router IP

echo "Updating DNS IP routing in /etc/resolv.conf"
: > /etc/resolv.conf                                           #clears the file
{
    echo "nameserver 9.9.9.9" > /etc/resolv.conf               #adds Quad 9 DNS to the DNS routing
    echo "nameserver 8.8.8.8" > /etc/resolv.conf               #adds Cloudflare DNS to the DNS routing
} >> /etc/resolv.conf                                          #appends to the file


echo "Testing network connectivity..."
ping -c 4 "$GATEWAY" && echo "Gateway IP reachable" || echo "Cannot connect to gateway"   #checks gateway connection
ping -c 4 8.8.8.8 && echo "Internet reachable" || echo "No internet access"               #pings cloudflare with 4 packets
echo "Test complete"


