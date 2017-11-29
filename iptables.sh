#!/bin/bash

# File: iptables.sh

echo "Setting up the firewall rules..."
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
    echo "...have already been manipulated."
else
    echo "About to: iptables -t nat ..."
    if sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    then
        echo "...success"
    else
        echo "...iptables -t nat ... FAILED! Teminating."
        exit 1
    fi
    echo "About to: iptables -A FORWARD -i eth0 -o wlan0 ..."
    if sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 
    then
        echo "...success"
    else
        echo "...iptables -A FORWARD -i eth0 ... FAILED! Terminating!"
        exit 1
    fi
    echo "About to: iptables -A FORWARD -i wlan -o eth0 ..."
    if sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
    then
        echo "...success"
    else
        echo "...iptables -A FORWARD -i wlan0 ... FAILED! Teminating!"
        exit 1
    fi

    echo "The firewall rules just set and about to be saved..."
    if sudo iptables -S
    then
        echo "...appear above."
    else 
        echo "... iptables -S (showing the tables) FAILED! Terminating!"
        exit 1
    fi
    if sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
    then
        echo "... and have been saved"
    else
        echo "... saving of iptables FAILED! Teminating!"
        exit 1
    fi
    echo "Saving /home/pi/iptables (to indicate iptables has been run..."
    if sudo sh -c "iptables-save > /home/pi/iptables"
    then
    echo "...success"
    echo "SYSTEM GOING DOWN FOR A REBOOT"
    sudo shutdown -r now
    else
        echo "...FAILED!"
    fi
fi

