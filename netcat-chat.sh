#!/bin/bash
set -e

nc -lvp 5000

while true; do
    echo "Hi and welcome to my Netcat server! I hope you enjoy it :>" | nc home.ddns.serendipitous-squirrel.com 5000
    
    sleep 600
done