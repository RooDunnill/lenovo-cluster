#!/usr/bin/env bash
set -e


if [[ $EUID -ne 0 ]]; then                  #checks that the user has run the file as root
    echo "Must have root access to run"
    false
fi


HOSTNAME=$(hostname)

HOSTNAMESUFFIX=$(echo "$HOSTNAME" | grep -o -E  '[0-9]+$')

IP_STATIC="192.168.0.$((100 + $HOSTNAMESUFFIX))"

IP_GATEWAY="192.168.0.1"

INTERFACE="enp1s0"

INITRAMFS_CMDLINE="IP=$IP_STATIC::$IP_GATEWAY:255.255.255.0:$HOSTNAME:$INTERFACE:none"

GRUB_CMDLINE="ip=$IP_STATIC::$IP_GATEWAY:255.255.255.0:$HOSTNAME:$INTERFACE:none"

if grep -q "GRUB_CMDLINE_LINUX" /etc/default/grub; then                #if this line in the file exists, update it
    sudo sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE\"|" /etc/default/grub
else
    echo "GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE\"" | sudo tee -a /etc/default/grub         #adds the entire line to the file
fi

sudo update-grub

if grep -q "IP" /etc/initramfs-tools/initramfs.conf; then
    sudo sed '/^IP/ c\"$INITRAMFS_CMDLINE"' /etc/initramfs-tools/initramfs.conf
else
    echo "$INITRAMFS_CMDLINE" | sudo tee -a /etc/initramfs-tools/initramfs.conf
fi

echo "Static IP $IP_STATIC has been set for $HOSTNAME"
cat /etc/initramfs-tools.initramfs.conf
cat /etc/default/grub