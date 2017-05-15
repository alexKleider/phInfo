# File: create_server.sh

# File last modified Sun May 14 08:45:10 PDT 2017

# Before sourcing this file:

#  1: be sure it and it's dependencies are in the cwd.
#      Dependencies are:
#          dnsmasq.conf
#          hostapd
#          hostapd.conf
#          html-index-file
#          interfaces.dhcp
#          interfaces.static
#          static.conf

#  2: have a look at hostapd.conf and modify accordingly, ESPECIALLY
#  if you plan to have two or more servers operating within range
#  of each other.  This applies to the SSID and channel (6, 1, 11)
#  you plan to use.  You'll want to avoid conflicts.
#  The file hostapd.conf.wpa is still a work in progress: I've been
#  unsuccessful getting protected wifi working.

#  3: interfaces.static is provided in case you want the eth0
#  interface to have a static address.  If you do, you'll probably
#  also want to edit interfaces.static to suit your own network.

#  4: Near the end of this file, you'll see comments pertaining to
#  an entry in the `/etc/fstab` file; specifically `LABEL=...`. You
#  may want to change the `LABEL` designation to suit your own
#  purposes.

# Check that this file hasn't already been sourced:
fname='/etc/network/interfaces.original';
afirmative='yes'
if [[ -e $fname ]]; then
    echo "File with the name $fname exists."
    echo "This indicates that this script has already been run."
    echo "Are you sure you want to go ahead? Best not to!!"

    read answer 
    if [[ $answer = $afirmative ]]; then
        echo Answer provided is $answer
        echo "OK, if you say so we will go ahead!"
    else
        echo "You have wisely decided to abort."
    fi
else
    echo "File called $fname not present so safe to proceed."

# The rest of the script is with in this 'else' segment.

# Rename originals and then copy over the following:
mv /etc/default/hostapd /etc/default/hostapd.original
cp hostapd /etc/default/hostapd
# mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.original
cp hostapd.conf /etc/hostapd/hostapd.conf
mv /etc/network/interfaces /etc/network/interfaces.original
cp interfaces.static /etc/network/interfaces.static
cp interfaces.dhcp /etc/network/interfaces.dhcp
# Only one of the next two lines should be uncommented:
cp interfaces.dhcp /etc/network/interfaces
# cp interfaces.tatic /etc/network/interfaces
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original
cp dnsmasq.conf /etc/dnsmasq.conf
echo "10.10.10.10  library library.lan rachel rachel.lan" >> /etc/hosts
# Modify /etc/sysctl.conf: uncomment net.ipv4.ip_forward=1
sed -i -r "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
# echo "Setting up the firewall rules."
# If an error concerning firewall (iptables) comes up, it's probably
# because there was no reboot after raspi-config or update.sh.

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

echo "The firewall rules just set and about to be saved are:"
iptables -t nat -S
iptables -S
sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Prepare a mount point for the Static Content
mkdir /mnt/Static
chown pi:pi /mnt/Static
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.

# The following directory is created to host content
# for the static content server.
mkdir /var/www/static
chown pi:pi /var/www/static

# If get an error about resolving host name, check that the correct
# host name appears in /etc/hosts:
#       127.0.0.1 localhost localhost.localdomain <hostname>
#       127.0.1.1 <hostname>.
# and that /etc/hostname contains the correct <hostname>

# Server set up:
cp static.conf /etc/apache2/sites-available/static.conf

# The following copies an index.html file and gets the site running
# thus providing an opportunity to test that all is well before
# copying over the static content:
cp html-index-file  /var/www/static/index.html
a2ensite static
service apache2 reload
# Not sure why but may get the following error:
# Warning: Unit file of apache2.service changed on disk, 'systemctl
# daemon-reload' recommended.
#  A reboot will likely solve the problem.

# At this point, expect that the test site will be visible at
# rachel.lan.  Will still need to replace test site index.html
# with the full Static Content.

# If the Static Content is provided on an ext4 formatted
# USB device with LABEL=Static, the following will cause
# it to be automatically mounted:
cp /etc/fstab /etc/fstab.original
echo "LABEL=Static /mnt/Static ext4 nofail 0 0" >> /etc/fstab

echo "   |vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv|"
echo "   | Might get an error:                       |"
echo "   | Warning: Unit file of apache2.service ... |"
echo "   |                                           |"
echo "   | The reboot will probably fix everything.  |"
echo "   |^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|"

shutdown -r now

fi
