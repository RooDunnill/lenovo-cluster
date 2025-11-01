#!/usr/bin/env bash
set -e

# checks for root access
echo "Checking for root access..."
if [[ $EUID -ne 0 ]]; then                                   
    echo "Must have root access to run"
    exit 1
fi
echo "Root access has been confirmed"

# Creating a secure environment
tmpdir=$(mktemp -d /tmp/wireguard.XXXXXX)
trap "rm -rf $tmpdir" EXIT

# checks that wireguard is installed
echo "Checking Wireguard is installed"
if ! command -v wg >/dev/null 2>&1; then                    
    echo "Wireguard is not installed, attempting installation"
    apt update && apt install -y wireguard
    if ! command -v wg >/dev/null 2>&1; then 
        echo "Still can't install it, ending program"
        exit 1
    fi
fi

key_num=10

# generate the server keys
echo "Generating server key pair"
server_priv_key=$(wg genkey)
server_pub_key=$(echo "$server_priv_key" | wg pubkey)

# create the inital section of the server config file
echo "Initialising server config file"
touch $tmpdir/server_config.conf
cat << EOF > "$tmpdir/server_config.conf"
[Interface]
PrivateKey = $server_priv_key
Address = 10.0.0.200/24
ListenPort = 51830

EOF

# generate the client keys
echo "Generating the client key pairs"
for i in $(seq 1 "$key_num"); do
    eval "client_priv_keys$i=\$(wg genkey)"
    eval "client_pub_key$i=\$(echo \${client_priv_keys$i} | wg pubkey)"

    # adds the peer to the server config file
    echo "Appending client setup $((i+1)) to server config"
    cat << EOF >> "$tmpdir/server_config.conf"
[Peer]
PublicKey = $client_pub_key$i
AllowedIps = 10.0.0.$((200+i+1))/32

EOF

    # creates the client config file
    echo "Creating client $((i+1)) config file"
    touch $tmpdir/client_config_$((i+1)).conf
    cat << EOF > "$tmpdir/client_config_$((i+1)).conf"
[Interface]
PrivateKey = $client_priv_key$i
Address = 10.0.0.$((200+i+1))/32

[Peer]
PublicKey = $server_pub_key
Endpoint = home.ddns.serendipitous-squirrel.com:51830
AllowedIPs = 0.0.0.0/0
PersistentKeepAlive = 25
EOF

    # copies the file over
    echo "Copying config file to node $((i+1))"
    if ! sudo -u user scp $tmpdir/client_config_$i.conf cluster@192.168.0.$((100+$i+1)):/tmp/wg-cluster-unlock.conf; then
        echo "Failed to copy client $((i+1)) config file across"
        exit 1
    fi

    sudo -u user ssh cluster@192.168.0.$((100+$i+1)) "sudo chmod 600 /etc/wireguard/wg-cluster-unlock.conf"
    eval "$client_pub_key$i=key"
    eval "$client_priv_key$i=key"
    unset client_pub_key$i
    unset client_priv_key$i
done

# copies server config file to main node
echo "Copying config file to main node"
sudo -u user scp $tmpdir/server_config.conf celebrimbor@192.168.0.100:/tmp/wg-cluster-unlock.conf 
sudo -u user ssh celebrimbor@192.168.0.100 "sudo chmod 600 /etc/wireguard/wg-cluster-unlock.conf"

# security checks
echo "Cleaning up temporary files"
rm -rf $tmpdir
eval "$server_pub_key=key"
eval "$server_priv_key=key"
unset server_pub_key
unset server_priv_key

# move files with ansible
source /home/user/Documents/ansible/bin/activate
ansible allhosts -m shell -a "sudo mv /tmp/wg-cluster-unlock.conf /etc/wireguard/wg-cluster-unlock.conf" --become -K


echo "Complete!"