#!/usr/bin/env bash
set -e #exits if an error is encountered

if ! command -v sudo >/dev/null 2>&1; then                             #checks sudo is installed
    echo "sudo is not installed, attempting to install"
    su -c "apt install -y sudo"
    if ! command -v sudo >/dev/null 2>&1; then 
        echo "Still can't install it, ending program"
        exit 1
    fi
fi


read -p "Enter the username of the user being configured: " USERNAME   #collects the username as an input prompt

if [ -z "$USERNAME" ]; then
    echo "No username provided. Exiting..."
    exit 1
fi

echo "Configuring $USERNAME"                                           #prints username for logging

if id "$USERNAME" >/dev/null 2>&1; then                                #checks if the user exists
    echo "User account found"
else
    echo "User account not found"
    false                                                              #stops the program if the user doesn't exist
fi

usermod -aG sudo "$USERNAME"                                           #adds the user to the sudoers group
echo "Added $USERNAME to the sudoers group!"
