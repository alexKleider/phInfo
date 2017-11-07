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
#    hostapd
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
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

# hostapd: pkg allowing use of Wi-Fi as an access point (AP.)
# dnsmasq: pkg providing dhcp and dns services.
# iw: tool for configuring Linux wireless devices.

echo "Installing hostapd, dnsmasq and iw ..."
sudo apt-get -y install hostapd dnsmasq iw
echo "... done"

## /etc/dhcpcd.conf
if [ -a /etc/dhcpcd.conf.original ]
then
    echo "/etc/dhcpcd.conf.original exists so we assume the extra"
    echo "line (denyinterfaces wlan) has been added to dhcpcd.conf."
else
    if [ -a /etc/dhcpcd.conf ]
    then
        echo "Saving a copy of /etc/dhcpcd.conf to /etc/dhcpcd.conf.original"
        sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.original
    else
        echo "Creating /etc/dhcpcd.conf.original."
        sudo touch /etc/dhcpcd.conf.original
    fi
    echo "Adding the (denyinterfaces wlan) line to /etc/dhcpcd.conf"
    sudo echo "denyinterfaces wlan" >> /etc/dhcpcd.conf
    # Above command covers us whether or not file existed.
fi

## /etc/network/interfaces
if [ -a /etc/network/interfaces.original ]
then
    echo "/etc/network/interfaces.original already exists"
    echo "so we assume files belonging in /etc/network/"
    echo "have already been copied over."
else
    echo "Preserving the original network/interfaces file,"
    sudo mv /etc/network/interfaces /etc/network/interfaces.original
    echo "copying over modified network/interfaces files,"
    sudo cp interfaces.static /etc/network/interfaces.static
    sudo cp interfaces.dhcp /etc/network/interfaces.dhcp
    # Only one of the next two line pairs should be uncommented:
    # DHCP:
    echo "setting the dhcp version of network/interfaces."
    sudo cp interfaces.dhcp /etc/network/interfaces
    # or STATIC:
    # sudo cp interfaces.static /etc/network/interfaces
    # echo "setting the static version of network/interfaces."
fi

## /etc/default/hostapd
if [ -a /etc/default/hostapd.original ]
then
    echo "/etc/default/hostapd.original already exists so we"
    echo "can assume that hostapd has alreacy been modified"
else
    echo "Saving the original /etc/default/hostapd file."
    sudo cp /etc/default/hostapd /etc/default/hostapd.original
    echo "Modify /etc/default/hostapd using a sed command."
    sudo sed -i -r "s/\#DEAMON_CONF=\"\"/DEAMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd
fi

## /etc/init.d/hostapd
if [ -a /etc/init.d/hostapd.original ]
then
    echo "/etc/init.d/hostapd.original already exists so we"
    echo "/etc/init.d/hostapd has been modified"
else
    echo "Saving original /etc/init.d/hostapd file."
    sudo cp /etc/init.d/hostapd /etc/init.d/hostapd.original
    echo "Modify /etc/init.d/hostapd using a sed command."
    sudo sed -i -r "s/DEAMON_CONF=/DEAMON_CONF=\/etc\/hostapd\/hostapd.conf/g" /etc/init.d/hostapd
fi

## /etc/hostapd/hostapd.conf
if [ -a /etc/hostapd/hostapd.conf.original ]
# Note: Don't know if /etc/hostapd/hostapd.conf initially exists.
then
    echo "/etc/hostapd/hostapd.conf.original already exists so we"
    echo "assume hostapd.conf has already been copied over."
else
    if [ -a /etc/hostapd/hostapd.conf ]
    then
        echo "Save the original /etc/hostapd/hostapd.conf file."
        sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.original
    else
        echo "Creating an empty /etc/hostapd/hostapd.conf.original file."
        sudo touch /etc/hostapd/hostapd.conf.original
    fi
    echo "Copy over our custom version of /etc/hostapd/hostapd.conf."
    sudo cp hostapd.conf /etc/hostapd/hostapd.conf
fi

## /etc/dnsmasq.conf
if [ -a /etc/dnsmasq.conf.original ]
then
    echo "/etc/dnsmasq.conf.original exists so we assume"
    echo "dnsmasq.conf has already been copied over."
else
    echo "Save a copy of the original /etc/dnsmasq.conf file."
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
    echo "Copy over our custom version of /etc/dnsmasq.conf file."
    sudo cp dnsmasq.conf /etc/dnsmasq.conf
fi
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.

## /etc/sysctl.conf
if [ -a /etc/sysctl.conf.original ]
then
  echo "/etc/sysctl.conf.original exists so we assume"
  echo "net.ipv4.ip_forward=1 has been uncommented."
else
    echo "Save a copy of the original /etc/sysctl.conf file."
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.original
    # Modify /etc/sysctl.conf: uncomment net.ipv4.ip_forward=1
    echo "Modify /etc/sysctl.conf using a sed command."
    sudo sed -i -r "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
fi

echo "System going down for a reboot."
sudo shutdown -r now

