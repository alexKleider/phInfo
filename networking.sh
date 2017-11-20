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
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

set -x

# hostapd: pkg allowing use of Wi-Fi as an access point (AP.)
# dnsmasq: pkg providing dhcp and dns services.
# iw: tool for configuring Linux wireless devices.

sudo apt-get -y install hostapd dnsmasq iw

## /etc/dhcpcd.conf
if [ -a /etc/dhcpcd.conf.original ]
then
    set +x
    echo "/etc/dhcpcd.conf.original exists so we assume the extra"
    echo "line (denyinterfaces wlan) has been added to dhcpcd.conf."
    set -x
else
    if [ -a /etc/dhcpcd.conf ]
    then
        set +x
        echo "Saving a copy of /etc/dhcpcd.conf to /etc/dhcpcd.conf.original"
        set -x
        sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.original
    else
        set +x
        echo "Creating /etc/dhcpcd.conf.original."
        set -x
        sudo touch /etc/dhcpcd.conf.original
    fi
    set +x
    echo "Adding the (denyinterfaces wlan) line to /etc/dhcpcd.conf"
    set -x
    sudo sh -c "echo denyinterfaces wlan >> /etc/dhcpcd.conf"
    # Above command covers us whether or not file existed.
fi

## /etc/network/interfaces
if [ -a /etc/network/interfaces.original ]
then
    set +x
    echo "/etc/network/interfaces.original already exists"
    echo "so we assume files belonging in /etc/network/"
    echo "have already been copied over."
    set -x
else
    set +x
    echo "Preserving the original network/interfaces file,"
    set -x
    sudo mv /etc/network/interfaces /etc/network/interfaces.original
    set +x
    echo "copying over modified network/interfaces files,"
    set -x
    sudo cp interfaces.static /etc/network/interfaces.static
    sudo cp interfaces.dhcp /etc/network/interfaces.dhcp
    # Only one of the next two line pairs should be uncommented:
    # DHCP:
    set +x
    echo "setting the dhcp version of network/interfaces."
    set -x
    sudo cp interfaces.dhcp /etc/network/interfaces
    # or STATIC:
    # sudo cp interfaces.static /etc/network/interfaces
    # echo "setting the static version of network/interfaces."
fi

## /etc/default/hostapd
if [ -a /etc/default/hostapd.original ]
then
    set +x
    echo "/etc/default/hostapd.original already exists so we"
    echo "can assume that hostapd has alreacy been modified"
    set -x
else
    set +x
    echo "Saving the original /etc/default/hostapd file."
    set -x
    sudo cp /etc/default/hostapd /etc/default/hostapd.original
    set +x
    echo "Modify /etc/default/hostapd using a sed command."
    set -x
    sudo sed -i -r "s/\#DAEMON_CONF=\"\"/DAEMON_CONF=\/etc\/hostapd\/hostapd.conf/g" /etc/default/hostapd
fi

## /etc/init.d/hostapd
if [ -a /etc/init.d/hostapd.original ]
then
    set +x
    echo "/etc/init.d/hostapd.original already exists so we"
    echo "/etc/init.d/hostapd has been modified"
    set -x
else
    set +x
    echo "Saving original /etc/init.d/hostapd file."
    set -x
    sudo cp /etc/init.d/hostapd /etc/init.d/hostapd.original
    set +x
    echo "Modify /etc/init.d/hostapd using a sed command."
    set -x
    sudo sed -i -r "s/DAEMON_CONF=/DEEAMON_CONF=\/etc\/hostapd\/hostapd.conf/g" /etc/init.d/hostapd
fi

## /etc/hostapd/hostapd.conf
if [ -a /etc/hostapd/hostapd.conf.original ]
# Note: Don't know if /etc/hostapd/hostapd.conf initially exists.
then
    set +x
    echo "/etc/hostapd/hostapd.conf.original already exists so we"
    echo "assume hostapd.conf has already been copied over."
    set -x
else
    if [ -a /etc/hostapd/hostapd.conf ]
    then
        set +x
        echo "Save the original /etc/hostapd/hostapd.conf file."
        set -x
        sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.original
    else
        set +x
        echo "Creating an empty /etc/hostapd/hostapd.conf.original file."
        set -x
        sudo touch /etc/hostapd/hostapd.conf.original
    fi
    set +x
    echo "Copy over our custom version of /etc/hostapd/hostapd.conf."
    set -x
    sudo cp hostapd.conf /etc/hostapd/hostapd.conf
fi

## /etc/dnsmasq.conf
if [ -a /etc/dnsmasq.conf.original ]
then
    set +x
    echo "/etc/dnsmasq.conf.original exists so we assume"
    echo "dnsmasq.conf has already been copied over."
    set -x
else
    set +x
    echo "Save a copy of the original /etc/dnsmasq.conf file."
    set -x
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
    set +x
    echo "Copy over our custom version of /etc/dnsmasq.conf file."
    set -x
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
  set +x
  echo "/etc/sysctl.conf.original exists so we assume"
  echo "net.ipv4.ip_forward=1 has been uncommented."
  set -x
else
    set +x
    echo "Save a copy of the original /etc/sysctl.conf file."
    set -x
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.original
    # Modify /etc/sysctl.conf: uncomment net.ipv4.ip_forward=1
    set +x
    echo "Modify /etc/sysctl.conf using a sed command."
    set -x
    sudo sed -i -r "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
    # Above command does work, it seems even though it's owned by
    # root:root
fi

set +x
echo "System going down for a reboot."
set -x
sudo shutdown -r now

