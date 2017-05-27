#!/usr/bin/env python3

# File: arp4pi.py

"""
Usage:
    sudo ./arp4pi.py

Tries to find the IP address of any device
with any of the known MAC addresses listed
in mac_w_id.
This script must be run with root privileges!

Development was inspired by the Raspberry Pi
related projects.

To be useful, you'll have to customize by editing:
1. the mac_w_id variable (replace with your own entries)
2. the parameters of arp-scan that appear in the
subprocess.check_output() method (to match your own network.)
"""

import subprocess

mac_w_id = (  # MacAddress, Description
    ("b8:27:eb:5a:2d:97", "Heavy Metal Case- RPi2b"),
    ("00:0f:54:02:25:08", "Heavy Metal Case- RPi2b"),

    ("b8:27:eb:42:44:1c", "Metalic sides, Black top & bottom- RPi2b"),
    ("8c:ae:4c:f8:27:c4", "Metalic sides, Black top & bottom- RPi2b"),
             
    ("b8:27:eb:8e:7a:b5", "Metalic sides, Black top & bottom- RPi2b"),
    ("00:0f:60:06:fc:8a", "Metalic sides, Black top & bottom- RPi2b"),

    ("b8:27:eb:53:a3:51", "Vilros Clear Case- RPi3b (Pi3-0)"),
    ("b8:27:eb:06:f6:04", "Vilros Clear Case- RPi3b (Pi3-0)"),

    ("b8:27:eb:da:2a:98", "Vilros Clear Case- RPi3b (Pi3-1)"),
    ("b8:27:eb:8f:7f:cd", "Vilros Clear Case- RPi3b (Pi3-1)"),

    ("00:21:6b:a1:81:44", "My Laptop"),

    ("9c:93:4e:14:18:6c", "Printer"),
)

output = subprocess.check_output(
    ("arp-scan", "-I", "wlan0", "10.0.0.0/24"))
decoded = output.decode("utf-8")
expanded = decoded.expandtabs()
lines = expanded.split("\n")
end_of_ip = 16
end_of_mac = 34

found = []

for line in lines:
    if len(line) >= end_of_mac:
        ip = line[:end_of_ip].strip()
        mac = line[end_of_ip:end_of_mac].strip()
#       print("processing- IP: {} MAC: {}".format(ip, mac))
        for recognized_mac, description in mac_w_id:
            if mac == recognized_mac:
                print("{} @ {}".format(description, ip))
#       print(line)

#print(expanded)

