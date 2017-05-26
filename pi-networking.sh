#!/bin/bash

# File: pi-networking.sh
# installs pi specific requirements:

# BEFORE RUNNING THIS SCRIPT:
#
#  1: be sure it and it's dependencies are in the cwd.
#      Dependencies are:
#          dnsmasq.conf
#          hostapd
#          hostapd.conf
#          interfaces.dhcp
#          interfaces.static

#  2a: Have a look at hostapd.conf and modify accordingly, ESPECIALLY
#  if you plan to have two or more servers operating within range
#  of each other.  This applies to the SSID and channel (6, 1, 11)
#  you plan to use.  You'll want to avoid conflicts.
#  2b: The file hostapd.conf.wpa is still a work in progress:
#  I've been unsuccessful getting protected wifi working.
# https://pimylifeup.com/raspberry-pi-wireless-access-point/

#  3: interfaces.static is provided in case you want the eth0
#  interface to have a static address.  If you do, you'll probably
#  also want to edit interfaces.static to suit your own network.

# It's hoped that this script is idempotent.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

sudo apt-get -y install iw hostapd dnsmasq

if [ -a /etc/default/hostapd.original ]
then
    echo "/etc/default/hostapd.original already exists so we"
    echo "can assume that hostapd has alreacy been copied over."
else
    sudo mv /etc/default/hostapd /etc/default/hostapd.original
    sudo cp hostapd /etc/default/hostapd
fi

if [ -a /etc/hostapd/hostapd.conf ]
# Note: /etc/hostapd/hostapd.conf doesn't initially exist.
then
    echo "/etc/hostapd/hostapd.conf already exists so we"
    echo "assume hostapd.conf has already been copied over."
else
    sudo cp hostapd.conf /etc/hostapd/hostapd.conf
fi

if [ -a /etc/network/interfaces.original ]
then
    echo "/etc/network/interfaces.original already exists"
    echo "so we assume files belonging in /etc/network/"
    echo "have already been copied over."
else
    sudo mv /etc/network/interfaces /etc/network/interfaces.original
    sudo cp interfaces.static /etc/network/interfaces.static
    sudo cp interfaces.dhcp /etc/network/interfaces.dhcp
    # Only one of the next two lines should be uncommented:
    sudo cp interfaces.dhcp /etc/network/interfaces
    # sudo cp interfaces.tatic /etc/network/interfaces
fi

if [ -a /etc/dnsmasq.conf.original ]
then
    echo "/etc/dnsmasq.conf.original exists so we assume"
    echo "dnsmasq.conf has already been copied over."
else
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
    sudo cp dnsmasq.conf /etc/dnsmasq.conf
fi
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.

if [ -a /etc/sysctl.conf.original ]
then
  echo "/etc/sysctl.conf.original exists so we assume"
  echo "net.ipv4.ip_forward=1 has been uncommented."
else
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.original
    # Modify /etc/sysctl.conf: uncomment net.ipv4.ip_forward=1
    sudo sed -i -r "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
fi

