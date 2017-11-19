#!/usr/bin/env python3

# File: find_pi.py

# -*- coding: UTF-8 -*-
# coding=utf-8
# vim: set fileencoding=UTF-8 :

"""
Usage:
    ./find_pi.py

Tries to find the IP address of any Raspberry Pi
that is on the network served by the <INTERFACE>
and with in the <IP_RANGE> specified (see below.)

This script uses `sudo` to run `arp-scan` and so
in most environments you will be asked to enter
your sudoer's password.

It is known/assumed that the first half of the
MAC addresses of the the eth0 interface of
all RPis are the same (<MAC_FIRST_HALF>.)

To be useful, you'll have to customize by editing
the 'INTERFACE' and 'IP_RANGE' variables/constants
to conform to your particular use case. (See comments
below for some guidance. The result of the 
$ ifconfig
command will help.)

The output consists of a header and then (if found)
the IP address(es) of any Raspberry Pi that might be
on the network.

(c) Alex Kleider 2017
"""

import re
import subprocess

# The next two assignment statements (those NOT preceded by a '#')
# may have to be edited to suit your staging machine's network
# configuration.  Output of the ifconfig command will help.
INTERFACE = "wlan0"
# Might be "wls1" (or something else?)
# Something like "eth0" or "enp0s25" if you're using ethernet.
IP_RANGE = "192.168.0.0/24"
# On my network it's "10.0.0.0/24".

MAC_FIRST_HALF = "b8:27:eb:"  # This is based on the observation that
# every Raspberry Pi that I've come accross has its ethernet port
# made by the same manufacturer and hence the first half of the MAC
# address is always the same.  There's no guarantee that this might
# not change in the future in which case the code will have to be
# modified to take this into account.

output_re = r"""
^  # IP address comes at the beginning of the line.
(?P<ip_address>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
# capture the IP address
\s+  # one or more spaces between IP and MAC addresses
(?P<first_half>[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:)
# capture first half of MAC address.
[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}
\s  # some white space follows the MAC address
"""
output_pattern = re.compile(output_re, re.VERBOSE)

output = subprocess.check_output(
    ("sudo", "arp-scan", "-I", INTERFACE, IP_RANGE)
#   ("arp-scan", "-I", INTERFACE, IP_RANGE)
# The difference is that with the second option, one has to run the
# script with root privileges while using the first hides this from
# the user. The Pi is configured to not ask for the sudo password.
    )

temp ="""
sudo -E sh -c 'echo "$ap_ip  library library.lan rachel rachel.lan"
("sudo ", "-E", "sh", "-c", "arp-scan", "-I", INTERFACE, IP_RANGE)
"""
decoded = output.decode("utf-8")
expanded = decoded.expandtabs()
lines = expanded.split("\n")

found = []
for line in lines:
    match = output_pattern.match(line)
    if match and (match.group("first_half") == MAC_FIRST_HALF):
        report = "matches"
        found.append(match.group("ip_address"))
    else:
        report = "doesn't match"
#   print("'{}' {}.".format(line, report))

if found:
    print("Probable Pi IP(s):")
    for ip in found:
        print("\t{}".format(ip))
else:
    print("No Raspberry Pi found on network.")
