#!/usr/bin/env python3

# File: find_pi.py

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

© Alex Kleider 2017
"""

import re
import subprocess

INTERFACE = "wls1"  # Might be "wlan0" (or something else?)
# Something like "eth0" or "enp0s25" if you're using ethernet.
IP_RANGE = "10.0.0.0/24"  # Change to "192.168.0.0/24"?
# The output of the ifconfig command will help determine
# the values to enter for both of the above.

MAC_FIRST_HALF = "b8:27:eb:"

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
#   ("sudo", "-E", "sh", "-c", "arp-scan", "-I", INTERFACE, IP_RANGE)
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
