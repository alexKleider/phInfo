#!/bin/bash

# File: pi-iptables.sh

echo "Setting up the firewall rules."
# If an error concerning firewall (iptables) comes up, it's probably
# because there was no reboot after raspi-config or update.sh or
# modification (uncommenting the "net.ipv4.ip_forward=1" line) of 
# the /etc/sysctl.conf file.

if [ -a /home/pi/iptables ]
then
    echo "/home/pi/iptables exists so we assume the iptables "
    echo "have already been manipulated."
else
    echo "About to: iptables -t nat ..."
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    echo "About to: iptables -A FORWARD -i eth0 -o wlan0 ..."
    sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 
    echo "About to: iptables -A FORWARD -i wlan -o eth0 ..."
    sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

    echo "The firewall rules just set and about to be saved are:"
    sudo iptables -S
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
    sudo sh -c "iptables-save > /home/pi/iptables"
fi
