#!/bin/bash

KEY_DIR="/etc/wireguard/keys/cluster-pub-keys"
CONFIG_FILE="/etc/wireguard/wg-cluster.conf"
counter=1

for PUB_KEY_FILE in $KEY_DIR/*.txt; do
    if [ -f "$PUB_KEY_FILE" ]; then
	CLIENT_NAME=ltc-node-0
        PUBLIC_KEY=$(cat "$PUB_KEY_FILE")
        echo "[Peer]" >> $CONFIG_FILE
	echo "PublicKey = $PUBLIC_KEY" >> $CONFIG_FILE
        echo "AllowedIPs = 10.0.0.10${counter}/32" >> $CONFIG_FILE
        echo "" >> $CONFIG_FILE
	((counter++))
    fi
done
