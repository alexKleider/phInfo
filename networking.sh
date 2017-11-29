#!/bin/bash

# File: networking.sh

#  Installs networking requirements 
#    Assumes one ethernet port (to be used for ethernet
#    connectivity to the Internet if available) and built
#    in wifi or a usb wifi dongle which is to be used as
#    an access point. This is the situation in the case
#    of the Raspberry Pi but would most likely be different
#    for other hardware.
          
#  Depends on the presence of the following files:
#    dnsmasq.conf
#    hostapd.conf
#    hostapd.conf.wpa  (still a work in progress)
#    interfaces.dhcp
#    interfaces.static

# BEFORE RUNNING THIS SCRIPT:
#
#  1a: Have a look at hostapd.conf and modify accordingly, ESPECIALLY
#  if you plan to have two or more servers operating within range
#  of each other.  This applies to the SSID and channel (6, 1, 11)
#  you plan to use.  You'll want to avoid conflicts.

#  1b: The file hostapd.conf.wpa is still a work in progress:
#  I've been unsuccessful getting protected wifi working on the
#  Raspberry Pi.
# https://pimylifeup.com/raspberry-pi-wireless-access-point/

#  2: interfaces.static is provided if you want the eth0
#  interface to have a static address.  If so,  you'll
#  a: probably want to edit this file to suit your own network
#  and
#  b: need to comment out the "DHCP" section and 'uncomment'
#  the "STATIC" section below.

# This script is written so as to be idempotent.

set -o errexit  # ends if an error is returned.
# set -o pipefail # pipe failure causes an error, we have no pipes.
set -o nounset  # ends if an undefined variable is encountered.
            # we use none in this script


# hostapd: pkg allowing use of Wi-Fi as an access point (AP.)
# dnsmasq: pkg providing dhcp and dns services.
# iw: tool for configuring Linux wireless devices.

echo "Begin networking.sh script: $(date)"
echo "Installing hostapd, dnsmasq, iw...."
if sudo apt-get -y install hostapd dnsmasq iw
then
    echo "...success installing hostapd, dnsmasq, iw...."
else
    echo "...failed! Terminating."
    exit 1
fi

echo
echo "Deal with /etc/dhcpcd.conf...."
if [ -a /etc/dhcpcd.conf.original ]
then
    echo "/etc/dhcpcd.conf.original exists so we assume the extra"
    echo "line (denyinterfaces wlan) has been added to dhcpcd.conf."
else
    if [ -a /etc/dhcpcd.conf ]
    then
        echo "Saving a copy of /etc/dhcpcd.conf to /etc/dhcpcd.conf.original"
        if sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.original
        then
            echo "...success."
        else
            echo "...failed! Terminating."
            exit 1
        fi
    else
        echo "Creating /etc/dhcpcd.conf.original."
        if sudo touch /etc/dhcpcd.conf.original
        then
            echo "...success."
        else
            echo "...failed! Terminating."
            exit 1
        fi
    fi

    echo "Adding the 'denyinterfaces wlan' line to /etc/dhcpcd.conf"
    if sudo sh -c "echo denyinterfaces wlan >> /etc/dhcpcd.conf"
    then
        echo "...success."
    else
        echo "...failed! Terminating."
        exit 1
    fi
    # Above command covers us whether or not file existed.
fi

## /etc/network/interfaces
echo
echo "Deal with /etc/network/interfaces...."
if [ -a /etc/network/interfaces.original ]
then
    echo "/etc/network/interfaces.original already exists"
    echo "so we assume files belonging in /etc/network/"
    echo "have already been copied over."
else
    echo "Preserving the original network/interfaces file,"
    if sudo mv /etc/network/interfaces /etc/network/interfaces.original
    then
        echo "...success."
    else
        echo "...failed! Terminating."
        exit 1
    fi

    echo "Copying over the two modified network/interfaces files,"
    echo "1. interfaces.static ..."
    if sudo cp interfaces.static /etc/network/interfaces.static
    then
        echo "...success."
    else
        echo "...failed! Terminating."
        exit 1
    fi
    echo "2. interfaces.dhcp ..."
    if sudo cp interfaces.dhcp /etc/network/interfaces.dhcp
    then
        echo "...success."
    else
        echo "...failed! Terminating."
        exit 1
    fi
    # Only one of the next two line pairs should be uncommented:
    # 1. DHCP:
    echo "Activating the dhcp version of network/interfaces."
    if sudo cp interfaces.dhcp /etc/network/interfaces
    # 2. STATIC:
    # echo "Activating the static version of network/interfaces."
    # if sudo cp interfaces.static /etc/network/interfaces
    then
        echo "...success."
    else
        echo "...failed! Terminating."
        exit 1
    fi
fi

## /etc/default/hostapd
echo 
echo "Deal with /etc/default/hostapd.original...." 
if [ -a /etc/default/hostapd.original ]
then
    echo "/etc/default/hostapd.original already exists so we"
    echo "can assume that hostapd has alreacy been modified"
else
    echo "Saving the original /etc/default/hostapd file..."
    if sudo cp /etc/default/hostapd /etc/default/hostapd.original
    then
        echo "Modify /etc/default/hostapd using a sed command."
    else
        echo "... the copy command failed! Terminating!"
        exit 1
    fi
    echo "Assigning DAEMON_CONF value in /etc/default/hostapd ..."
    if sudo sed -i -r 's/#DAEMON_CONF=""/DAEMON_CONF=\/etc\/hostapd\/hostapd.conf/g' /etc/default/hostapd
    then
        echo "... sed command ran without error- still worth checking."
    else
        echo "... sed command failed! Terminating!"
        exit 1
    fi
fi

## /etc/init.d/hostapd
echo
echo "Deal with /etc/init.d/hostapd...."
if [ -a /etc/init.d/hostapd.original ]
then
    echo "/etc/init.d/hostapd.original already exists so we"
    echo "can assume /etc/init.d/hostapd has been modified"
else
    echo "Saving original /etc/init.d/hostapd file..."
    if sudo cp /etc/init.d/hostapd /etc/init.d/hostapd.original
    then
        echo "... cp command ran successfully."
    else
        echo "... cp command failed! Terminating!"
        exit 1
    fi

    echo "Assigning DAEMON_CONF value in /etc/init.d/hostapd."
    if sudo sed -i -r 's/DEAMON_CONF=/DEAMON_CONF=\/etc\/hostapd\/hostapd.conf/g' /etc/init.d/hostapd
    then
        echo "... sed command ran without error- still worth checking."
    else
        echo "... sed command failed! Terminating!"
        exit 1
    fi
fi

## /etc/hostapd/hostapd.conf
echo
echo "Deal with /etc/hostapd/hostapd.conf...."
if [ -a /etc/hostapd/hostapd.conf.original ]
# Note: Don't know if /etc/hostapd/hostapd.conf initially exists.
then
    echo "/etc/hostapd/hostapd.conf.original already exists so we"
    echo "assume hostapd.conf has already been copied over."
else
    if [ -a /etc/hostapd/hostapd.conf ]
    then
        echo "Saving the original /etc/hostapd/hostapd.conf file..."
        if sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.original
        then
            echo "... success."
        else
            echo "... command failed! Terminating!"
            exit 1
        fi
    else
        echo "Creating an empty /etc/hostapd/hostapd.conf.original file..."
        sudo touch /etc/hostapd/hostapd.conf.original
    fi
    echo "Copy over our custom version of /etc/hostapd/hostapd.conf..."
    if sudo cp hostapd.conf /etc/hostapd/hostapd.conf
    then
        echo "...copied successfully."
    else
        echo " ...copy command failed! Teminating!"
        exit 1
    fi
fi

## /etc/dnsmasq.conf
echo
echo "Deal with /etc/dnsmasq.conf...."
if [ -a /etc/dnsmasq.conf.original ]
then
    echo "/etc/dnsmasq.conf.original exists so we assume"
    echo "dnsmasq.conf has already been copied over."
else
    echo "Saving a copy of the original /etc/dnsmasq.conf file..."
    if sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
    then 
        echo "...success."
    else
        echo "...command failed! Temrminating!"
        exit 1
    fi

    echo "Copy over our custom version of /etc/dnsmasq.conf file..."
    if sudo cp dnsmasq.conf /etc/dnsmasq.conf
    then 
        echo "...success."
    else
        echo "...command failed! Temrminating!"
        exit 1
    fi
fi
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.

## /etc/sysctl.conf
echo
echo "Deal with /etc/sysctl.conf...."
if [ -a /etc/sysctl.conf.original ]
then
    echo "/etc/sysctl.conf.original exists so we assume"
    echo "net.ipv4.ip_forward=1 has been uncommented."
else
    echo "Save a copy of the original /etc/sysctl.conf file..."
    if sudo cp /etc/sysctl.conf /etc/sysctl.conf.original
    then 
        echo "...success."
    else
        echo "...command failed! Temrminating!"
        exit 1
    fi
    echo "Modify /etc/sysctl.conf: uncomment net.ipv4.ip_forward=1 ...."
    if sudo sed -i -r "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
    then 
        echo "...sed command ran success fully but still worth checking."
    else
        echo "...sed command failed! Temrminating!"
        exit 1
    fi
fi

echo "SYSTEM GOING DOWN FOR A REBOOT"
echo "End networking.sh script: $(date)"
sudo shutdown -r now

