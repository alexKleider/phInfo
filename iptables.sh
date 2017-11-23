#!/bin/bash

# File: iptables.sh

echo "Setting up the firewall rules."
# An error concerning firewall (iptables) comes up:
# The problem is solved with a reboot.
# It may have to do with one or more of the following:
#   raspi-config, (specific to the Raspberry Pi)
#   update.sh or
#   modification (uncommenting the "net.ipv4.ip_forward=1" line)
#       of the /etc/sysctl.conf file.  
# Hence the reason iptables.sh has been split off from
# networking.sh
# 
# A solution might be to do the following:
#   sudo service dhcpcd restart
#   sudo ifdown wlan0; sudo ifup wlan0
#   sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
# But: if using a Raspberry Pi unlikely according to a comment here:
# https://pimylifeup.com/raspberry-pi-wireless-access-point/#comment-3679
# Conclusion: a reboot does seem to be necessary.

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
    # Creation of /home/pi/iptables leaves an indication
    # that iptables have already been set up:
    sudo sh -c "iptables-save > /home/pi/iptables"
fi

echo "SYSTEM GOING DOWN FOR A REBOOT"
sudo shutdown -r now
