# File: create_server.sh

# Before sourcing this file:
#  1. If you have elected to change the Access Point's IP address
#  then you should change the '10.10.10.10' IP address in the
#  "export ap_ip="10.10.10.10" line early in the script.
#  to the address you choose.  Corresponding changes should have
#  been or will still need to be made in dnsmasq.conf and
#  interfaces (and possibly elsewhere as well.)
#  2. Near the end, you'll see comments pertaining to an entry
#  in the `/etc/fstab` file; specifically `LABEL=Static`. You
#  may want to change the `LABEL` to something other than
#  "Static" to suit your own purposes.

export ap_ip="10.10.10.10"
echo "We assume the server's WiFi IP address is $ap_ip"

if [ -a /etc/hosts.original ]
then
    echo "/etc/hosts.original exists so we assume"
    echo "additions have already been made to the file."
else
    sudo cp /etc/hosts /etc/hosts.original

    sudo sh -c "echo $ap_ip library library.lan rachel rachel.lan >> /etc/hosts"
# the following are two alternative ways of doing the same thing.
# the first has been tested, the second has not.
#   sudo -E sh -c 'echo "$ap_ip  library library.lan rachel rachel.lan" >> /etc/hosts'
#   echo "$ap_ip  library library.lan rachel rachel.lan"|sudo tee -a /etc/hosts >/dev/null
# See footnote by Aaron at end of file.
    echo "Appended a line to /etc/hosts."
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct WiFi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.
fi

# Prepare a mount point for the Static Content
if [ -d /mnt/Static ]
then
    echo "Warning: directory /mnt/Static already exists!"
else
    sudo mkdir /mnt/Static
    sudo chown pi:pi /mnt/Static
fi

if [ -d /var/www/static ]
then
    echo "Warning: directory /var/www/static already exists!"
else
    # The following directory is created to host content
    # for the static content server.
    sudo mkdir /var/www/static
    sudo chown pi:pi /var/www/static
fi

# If get an error about resolving host name, check that the correct
# host name appears in /etc/hosts:
#       127.0.0.1 localhost localhost.localdomain <hostname>
#       127.0.1.1 <hostname>.
# and that /etc/hostname contains the correct <hostname>

# Server set up:
if [ -f /etc/apache2/sites-available/static.conf ]
then
    echo "Warning: /etc/apache2/sites-available/static.conf exists!"
else
    sudo cp static.conf /etc/apache2/sites-available/static.conf
fi

# The following copies an index.html file and gets the site running
# thus providing an opportunity to test that all is well before
# copying over the static content:
if [ -f /var/www/static/index.html ]
then
    echo "Warning: /var/www/static/index.html exists!"
else
    cp html-index-file  /var/www/static/index.html
    echo "html-index-file copied to /var/www/static/index.html"
fi

sudo a2dissite 000-default
sudo a2ensite static
sudo service apache2 reload
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

if [ -a /etc/fstab.original ]
then
    echo "Warning: /etc/fstab.original already exists!"
else
    sudo cp /etc/fstab /etc/fstab.original
    sudo sh -c 'echo "LABEL=Static /mnt/Static ext4 nofail 0 0" >> /etc/fstab'
#   echo "LABEL=Static /mnt/Static ext4 nofail 0 0"|
#       sudo tee -a /etc/fstab >/dev/null
    echo "Appended a line to /etc/fstab."

fi

echo "   |vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv|"
echo "   | Might get an error:                             |"
echo "   | Warning: Unit file of apache2.service changed   |"
echo "   | on disk, 'systemctl daemon-reload' recommended. |"
echo "   |                                                 |"
echo "   | The reboot will probably fix everything.        |"
echo "   |^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|"

sudo shutdown -r now

## Foot Note:

# As Michael explains, it really comes down to the quoting you're
# using and which shell the command is being evaluated in.

# sudo sh -c "echo $ap_ip  library library.lan rachel rachel.lan >> /etc/hosts"

# I would recommend this one as the "correct" solution. IMHO it's
# the simplest one and avoids `sudo -E`. The `$ap_ip` is evaluated
# in the current shell. You don't need to export the variable
# because the sub-shells don't need to read the variable and never
# see it. They already have the value within the command. `sh` sees
# the full command with the shell redirection. With sudo, `sh` has
# the proper permissions to follow the redirection and write to
# `/etc/hosts`.
  
# In general I would say `sudo -E` is a poor pattern and should be
# avoided. You can imagine this being problematic:

#   PATH=/tmp/evil/bin:$PATH sudo -E echo foo

# This is why even with `sudo -E`, sudo still blocks certain
#  environment variables (like PATH) based on the security policy.

# --
# Aaron D Borden <adborden@a14n.net>
# Human and Hacker
