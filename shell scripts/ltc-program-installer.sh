#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then                  #checks the user has run the file as root
    echo "Must have root access to run"
    exit 1
fi

if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "Internet connected"
else
    echo "No internet"
    exit 1
fi
echo "Updating the package list"
apt update                #updates the system
echo "Upgrading the package list"
apt full-upgrade -y     

PACKAGES=(                #the list of packages to install
    sudo                         #allows users to run as root
    openssh-server               #ssh
    sshfs                        #filesharing over ssh
    vim                          #an overcomplicated text editor
    nano                         #a much easier to use texteditor
    curl                         #grabs a website link and downloads it
    wget                         #basically the same as curl
    htop                         #shows system info and running processes
    ca-certificates              #specific certs needed for the system
    ufw                          #firewall
    network-manager              #runs all necessary networking
    rsync                        #allows for easy copying      
    tar                          #unzips tar files
    man-db                       #info on every package
    unzip                        #unzips .zip files
    zip                          #zips files
    wireguard                    #modern VPN setup
    git                          #file hosting and sharing service
    python3                      #python programming language
    python3-pip                  #python repo library
    python3-venv                 #python virtual environments
    nmap                         #network scanner
    dropbear                     #used for sshing in before drive passphrase
    dropbear-initramfs
    lshw                         #system specs
)

for pkg in "${PACKAGES[@]}"; do                   #goes through each package in PACKAGES
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then     #checks if the package is already installed
        echo "Installing $pkg..."
        apt install -y $pkg                       #installs the package
    else
        echo "$pkg is already installed, skipping"
    fi

                                                  
done
