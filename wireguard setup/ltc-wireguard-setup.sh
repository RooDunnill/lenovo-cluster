#!/usr/bin/env bash
set -e

echo "Checking for root access..."
if [[ $EUID -ne 0 ]]; then                                     #checks that the user has run the file as root
    echo "Must have root access to run"
    exit 1
fi
echo "Root access has been confirmed"

echo "Checking Wireguard is installed"
if ! command -v wg >/dev/null 2>&1; then                       #checks wireguard is installed
    echo "Wireguard is not installed, attempting installation"
    apt update && apt install -y wireguard
    if ! command -v wg >/dev/null 2>&1; then 
        echo "Still can't install it, ending program"
        exit 1
    fi
fi

HOSTNAME=$(hostname)
ID=$(echo "$HOSTNAME" | tail -c 3 | head -c 2)                 #finds the last two digits of the hostname
TUNNEL_IP=10.0.0.1${ID}/24

mkdir -p /etc/wireguard/keys                                   #makes the folder if it doesn't exist
chmod 700 /etc/wireguard/keys                                  #locks the folder to only be accessible to root
chown root:root /etc/wireguard/keys                            #makes sure the folder is owned by root


if [ ! -f "/etc/wireguard/keys/cluster-privatekey" ]; then     #checks if the keypair has been generated
    echo "Generating key pair"
    wg genkey > /etc/wireguard/keys/cluster-privatekey
    wg pubkey < /etc/wireguard/keys/cluster-privatekey > /etc/wireguard/keys/cluster-publickey
fi

chmod 600 /etc/wireguard/keys/cluster-privatekey               #locks the private key to only root access
chmod 644 /etc/wireguard/keys/cluster-publickey                #locks the editting of the file to only root

echo "Creating config file"
touch /etc/wireguard/wg-cluster.conf
   
cat <<EOF > /etc/wireguard/wg-cluster.conf                     #adds the contents below to the wireguard config file
[Interface]
PrivateKey = /etc/wireguard/keys/cluster-privatekey
Address = $TUNNEL_IP

[Peer]
PublicKey = /etc/wireguard/keys/cluster-publickey
Endpoint = home.ddns.serendipitous-squirrel.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "Script Complete"