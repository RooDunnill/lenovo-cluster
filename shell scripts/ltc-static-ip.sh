#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then                  #checks that the user has run the file as root
    echo "Must have root access to run"
    exit 1
fi

IP_GATEWAY=$(ip route show | grep default | awk '{print $3}')
INT_GATEWAY=$(ip route show | grep default | awk '{print $5}')

if [ -n "$IP_GATEWAY" ]; then                                       #checks that the ip exists
    echo "Gateway IP is: $IP_GATEWAY"
else
    echo "Gateway IP could not be found, check internet connection"
    exit 1
fi

if [[ ! "$IP_GATEWAY" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then  #checks IP is of the correct form
    echo "Gateway IP has the wrong format, command 'ip route show' is returning an unexpected value"
    exit 1
fi

if [ -n "$INT_GATEWAY" ]; then                                      #checks the the interface exists
    echo "Gateway interface is: $INT_GATEWAY"
else
    echo "Gateway interface could not be found, check internet connection"
    exit 1
fi

NET_INT="/etc/network/interfaces"                                   #file location
CP_NET_INT="/etc/network/interfaces-backup"                         #backup file location

if [ -f "$NET_INT" ]; then       
    cp "$NET_INT" "$CP_NET_INT"                                     #makes a backup
    echo "Copied $NET_INT to location $CP_NET_INT"
else
    echo "$NET_INT file does not exist, now creating one"
    touch "$NET_INT"                                                #creates a blank file
fi

read -p "Enter the static IP for this server: " IP_STATIC

if [ -z "$IP_STATIC" ]; then
    echo "No static IP provided. Exiting..."
    exit 1
fi

TEXT="
# /etc/network/interfaces

# The loopback network interface
auto lo
iface lo inet loopback

# Ethernet interface $INT_GATEWAY
auto $INT_GATEWAY
iface $INT_GATEWAY inet static
        address $IP_STATIC
        netmask 255.255.255.0
        gateway $IP_GATEWAY
"


echo "$TEXT" > "$NET_INT"

echo "$NET_INT correctly configured to set the static ip $IP_STATIC with gateway ip $IP_GATEWAY for interface $INT_GATEWAY"
systemctl restart networking     #instantly restarts the network to reflect the new ip address