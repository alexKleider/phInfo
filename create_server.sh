# File: create_server.sh

# File last modified Thu May 25 11:36:11 PDT 2017

# Before sourcing this file:
#  Near the end, you'll see comments pertaining to an entry
#  in the `/etc/fstab` file; specifically `LABEL=Static`. You
#  may want to change the `LABEL` to something other than
#  "Static" to suit your own purposes.

if [ -a /etc/hosts.original ]
then
    echo "/etc/hosts.original exists so we assume"
    echo "additions have already been made to the file."
else
    sudo cp /etc/hosts /etc/hosts.original
    sudo echo "10.10.10.10  library library.lan rachel rachel.lan" >> /etc/hosts
fi

# Prepare a mount point for the Static Content
sudo mkdir /mnt/Static
sudo chown pi:pi /mnt/Static
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.

# The following directory is created to host content
# for the static content server.
sudo mkdir /var/www/static
sudo chown pi:pi /var/www/static

# If get an error about resolving host name, check that the correct
# host name appears in /etc/hosts:
#       127.0.0.1 localhost localhost.localdomain <hostname>
#       127.0.1.1 <hostname>.
# and that /etc/hostname contains the correct <hostname>

# Server set up:
sudo cp static.conf /etc/apache2/sites-available/static.conf

# The following copies an index.html file and gets the site running
# thus providing an opportunity to test that all is well before
# copying over the static content:
cp html-index-file  /var/www/static/index.html
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

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

if [ -a /etc/fstab.original ]
then
    sudo cp /etc/fstab /etc/fstab.original
else
    sudo echo "LABEL=Static /mnt/Static ext4 nofail 0 0" >> /etc/fstab
fi

echo "   |vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv|"
echo "   | Might get an error:                       |"
echo "   | Warning: Unit file of apache2.service ... |"
echo "   |                                           |"
echo "   | The reboot will probably fix everything.  |"
echo "   |^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|"

sudo shutdown -r now

fi
