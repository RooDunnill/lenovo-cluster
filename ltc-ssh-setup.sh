#!/usr/bin/env bash
set -e

#THIS SCRIPT IS TO BE RAN ON THE CLIENT SIDE BEFORE SSH, NOT ON THE LTC CLUSTER
#THIS SCRIPT IS DESIGNED WITH THE ASSUMPTION OF A FRESH MINIMAL DEBIAN INSTALL ie no sudo

AUTHKEYSPATH="/home/user/Documents/authorized_keys"
SSHDCONFIGPATH="/home/user/Documents/sshd_config"
read -p "What is the IP of the cluster: " IPCLSTR   #finds the IP for the system

ssh cluster@"$IPCLSTR" 'mkdir -p ~/.ssh'                 #makes the folder if not already there
ssh cluster@"$IPCLSTR" 'chmod 700 ~/.ssh'                #makes the folder only writeable by the cluster user
scp "$AUTHKEYSPATH" cluster@"$IPCLSTR":/home/cluster/.ssh/authorized_keys           #copies the authorized_keys file over
ssh cluster@"$IPCLSTR" 'chmod 600 ~/.ssh/authorized_keys'                           #makes the file only readable by the cluster user
scp "$SSHDCONFIGPATH" cluster@"$IPCLSTR":/tmp/sshd_config                           #copies the sshd_config file over
ssh cluster@"$IPCLSTR" 'su -c "mv /tmp/sshd_config /etc/ssh/sshd_config"'           #internally moves the file over
ssh cluster@"$IPCLSTR" 'echo "export TERM=xterm" >> ~/.bashrc'                      #changes the terminal for nano use