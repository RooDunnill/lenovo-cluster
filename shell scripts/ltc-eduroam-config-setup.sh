#!/usr/bin/env bash
set -e

echo "Starting up venv"
source /home/celebrimbor/venvs/ansible/bin/activate

echo "Creating folder"
ansible nodesubgroup -m shell "sudo touch /usr/local/eduroam/eduroam_wpa.conf" --become -K

# reads sensitive information
read -p "What is your eduroam username?: " EDUSER
read -p "What is your eduroam password?: " EDPWD


# creates the wpa_supplicant file
echo "Creating wpa_supplicant file"
cat << EOF >> "/tmp/eduroam_wpa.conf"
ctrl_interface=DIR=/run/wpa_supplicant GROUP=netdev
update_config=1
country=GB

network={
    ssid="eduroam"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="$EDUSER@ed.ac.uk"
    password="$EDPWD"
    phase1="peapver=0"
    phase2="auth=MSCHAPV2"
    ca_cert="/usr/local/eduroam/AAACertificateServices.crt"
}
EOF


# creates the NetworkManager file
echo "Creating NetworkManager file"
cat << EOF >> "/tmp/eduroam.nmconnection"
  GNU nano 7.2                  Wi-Fi connection 1.nmconnection                            
[connection]
id=eduroam
uuid=d44f1157-99e0-4b05-8655-38dc84a1dbb1
type=wifi
interface-name=wls6f0

[wifi]
mac-address=2C:7B:A0:69:5A:5F
mode=infrastructure
ssid=eduroam

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
ca-cert=/usr/local/eduroam/AAACertificateServices.crt
eap=peap;
identity=$EDUSER@ed.ac.uk
password=$EDPWD
phase2-auth=mschapv2

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto

[proxy]
EOF

# moving over files and configuring perms
echo "Copying wpa_supplicant file across"
ansible nodesubgroup -m copy -a "src=/tmp/eduroam_wpa.conf dest=/etc/wpa_supplicant/eduroam_wpa.conf" --become -K
echo "Copying NetworkManager file across"
ansible nodesubgroup -m copy -a "src=/tmp/eduroam.nmconnection dest=/etc/NetworkManager/system-connections/eduroam.nmconnections" --become -K
echo "Configuring NetworkManager file perms"
ansible nodesubgroup -m shell -a "chmod 600 /etc/NetworkManager/systerm-connections/eduraom.nmconnections" --become -K
echo "Configuring wpa_cupplicant file perms"
ansible nodesubgroup -m shell -a "chmod 600 /etc/wpa_supplicant/eduroam_wpa.conf" --become -K

