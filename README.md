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
* STORAGE: 1TB NVME M.2 Gen 4
* GPU: Nvidia 3060Ti
* NETWORKING: Gigabit Ethernet
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
## Useful Commands
### Ansible Commands
As my setup has ansible.cfg pointing to my inventory file, which i only need one of, I don't need to specify the path
* ansible [group] -m ping

Pings every server in that given group, allowing for an easy way to check the connections
* ansible [group] -m shell -a "command"

Allows you to run a shell command on all servers
* ansible [group] -m copy -a "src=/path/to/src dest=/path/to/dest"

Copies files over, great for batch moving config files
### Lightweight Kubernetes (k3s) Commands
#### Main server commands
* $ curl -sfL https://get.k3s.io | sh –

This runs on the main master computer and installs all necessary packages
* $ sudo k3s kubectl get nodes

Shows all of the connected servers in a really neat and succinct fashion.
#### Node Commands
* curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -

Installs the necessary software, pairs nicely with ansible

