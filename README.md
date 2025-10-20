# Lenovo ThinkCentre Cluster Repo
## Overview
This is a repo for my lenovo thinkcentre cluster. It includes shell scripts and other config files for my mini cluster.
## Structure
The cluster consists of 10 lenvovo thinkcentre m625q tiny pcs, the specs of which are:
#### LTC Specifications
* CPU: AMD E2-9000E, 4 core
* RAM: 4GB DDR4 1866MHz SODIMM
* STORAGE: 32GB Sata
* NETWORKING: Gigabit Ethernet
* OS: Debian Trixie

These 10 computers are currently all set up at my home and are connected to a network switch that feeds into the wider network. I also have a raspberry pi NAS and a desktop that acts as my main server which runs heavier tasks. This desktop will act as the central point for the other computers when they are eventually moved to external locations. My desktop specifications are:
#### Central Node Specifications
* CPU: Ryzen 5 5600X
* RAM: 32GB DDR4 3200Mhz DIMM
* Storage: 1TB NVME M.2 Gen 4
* GPU: Nvidia 3060Ti
* Networking: Gigabit Ethernet
* OS: Debian Trixie

The 10 ltc nodes are configured with the help of ansible to mass run commands and shell scripts on all of the devices and are LUKS encrypted. I used dropbear ssh to install a lightweight ssh server into the initramfs, so that I can unlock the LUKS drives remotely.
## Aims
* Practice good security practices
* Learn about distributed computing
* Learn about mesh networking across various private networks
* Practice hands on encryption
* Learn other programming languages and improve coding skills
## Tasks
* Set up computers at my university
* Spread the computers around families and friends houses
* Practice writing and hosting small websites and chatrooms
* Set up a DDNS server on main node
* Use k3s to distribute tasks
* Wireguard into my node setup from my laptop for external network access
## Current Hosted Programs
* Obligitory Minecraft server
