#!/usr/bin/env bash
set -e

# Creating a secure environment
tmpdir=$(mktemp -d $HOME/wireguard.XXXXXX)
chmod 700 $tmpdir
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
    client_priv_key=$(wg genkey)
    client_pub_key=$(echo "$client_priv_key" | wg pubkey)

    # adds the peer to the server config file
    echo "Appending client setup $i to server config"
    cat << EOF >> "$tmpdir/server_config.conf"
[Peer]
PublicKey = $client_pub_key
AllowedIPs = 10.0.0.$((200+i))/32

EOF

    # creates the client config file
    echo "Creating client $i config file"
    touch $tmpdir/client_config_$i.conf
    cat << EOF > "$tmpdir/client_config_$i.conf"
[Interface]
PrivateKey = $client_priv_key
Address = 10.0.0.$((200+i))/32

[Peer]
PublicKey = $server_pub_key
Endpoint = home.ddns.serendipitous-squirrel.com:51830
AllowedIPs = 0.0.0.0/0
PersistentKeepAlive = 25
EOF

    # copies the file over
    echo "Copying config file to node $i"
    if ! scp -q $tmpdir/client_config_$i.conf cluster@192.168.0.$((100+$i)):/tmp/wg-unlock-cluster-temp.conf; then
        echo "Failed to copy client $i config file across"
        exit 1
    fi

    unset client_pub_key
    unset client_priv_key
done

# copies server config file to main node
echo "Copying config file to main node"
scp -q $tmpdir/server_config.conf celebrimbor@192.168.0.100:/tmp/wg-unlock-cluster-temp.conf

# security checks
echo "Cleaning up temporary files"
rm -rf $tmpdir
unset server_pub_key
unset server_priv_key

# move files with ansible
source /home/user/Documents/venvs/ansible/bin/activate
echo "Running ansible to move files to /etc/wireguard"
ansible nodesubgroup -m shell -a "sudo mv /tmp/wg-unlock-cluster-temp.conf /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K
echo "Running ansible to change file perms"
ansible nodesubgroup -m shell -a "sudo chmod 600 /etc/wireguard/wg-unlock-cluster-temp.conf && sudo chown root:root /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K


# become passwords are different and haven't configured correctly yet so must be done seperately (will remove later)
echo "Running ansible to move files to /etc/wireguard"
ansible 192.168.0.100 -m shell -a "sudo mv /tmp/wg-unlock-cluster-temp.conf /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K
echo "Running ansible to change file perms"
ansible 192.168.0.100 -m shell -a "sudo chmod 600 /etc/wireguard/wg-unlock-cluster-temp.conf && sudo chown root:root /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K

# I have no reason why this doesn't work so i am just going to get ansible to copy the files and delete the old one????
ansible nodesubgroup -m shell -a "sudo cp /etc/wireguard/wg-unlock-cluster-temp.conf /etc/wireguard/dropbear-unlock.conf" --become -K
ansible nodesubgroup -m shell -a "sudo rm /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K
ansible 192.168.0.100 -m shell -a "sudo cp /etc/wireguard/wg-unlock-cluster-temp.conf /etc/wireguard/dropbear-unlock.conf" --become -K
ansible 192.168.0.100 -m shell -a "sudo rm /etc/wireguard/wg-unlock-cluster-temp.conf" --become -K
echo "Complete!"