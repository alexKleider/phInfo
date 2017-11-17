# File: create_server.sh

# File last modified Thu May 25 11:36:11 PDT 2017

# Before sourcing this file:
#  1. If you have elected to change the Access Point's IP address
#  then you should change the 10.10.10.10 IP address in line 31
#  to the same address.  Corresponding changes should have been
#  or will still need to be made in dnsmasq.conf and interfaces
#  (and possibly elsewhere as well.)
#  2. Near the end, you'll see comments pertaining to an entry
#  in the `/etc/fstab` file; specifically `LABEL=Static`. You
#  may want to change the `LABEL` to something other than
#  "Static" to suit your own purposes.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

set -x

export ap_ip="10.10.10.10"

if [ -a /etc/hosts.original ]
then
    set +x
    echo "/etc/hosts.original exists so we assume"
    echo "additions have already been made to the file."
    set -x
else
    sudo cp /etc/hosts /etc/hosts.original

    sudo sh -c "echo $ap_ip library library.lan rachel rachel.lan >> /etc/hosts"
# the following are two alternative ways of doing the same thing.
# the first has been tested, the second has not.
#   sudo -E sh -c 'echo "$ap_ip  library library.lan rachel rachel.lan" >> /etc/hosts'
#   echo "$ap_ip  library library.lan rachel rachel.lan"|sudo tee -a /etc/hosts >/dev/null
# See footnote by Aaron at end of file.

    set +x
    echo "Appended a line to /etc/hosts."
    set -x
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct wifi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.
fi

# Prepare a mount point for the Static Content
if [ -d /mnt/Static ]
then
    set +x
    echo "Warning: dirctory /mnt/Static already exists!"
    set -x
else
    sudo mkdir /mnt/Static
    sudo chown pi:pi /mnt/Static
fi

if [ -d /var/www/static ]
then
    set +x
    echo "Warning: directory /var/www/static already exists!"
    set -x
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
    set +x
    echo "Warning: /etc/apache2/sites-available/static.conf exists!"
    set -x
else
    sudo cp static.conf /etc/apache2/sites-available/static.conf
fi

# The following copies an index.html file and gets the site running
# thus providing an opportunity to test that all is well before
# copying over the static content:
if [ -f /var/www/static/index.html ]
then
    set +x
    echo "Warning: /var/www/static/index.html exists!"
    set -x
else
    cp html-index-file  /var/www/static/index.html
    set +x
    echo "html-index-file copied to /var/www/static/index.html"
    set -x
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
    set +x
    echo "Warning: /etc/fstab.original already exists!"
    set -x
else
    sudo cp /etc/fstab /etc/fstab.original
    sudo sh -c 'echo "LABEL=Static /mnt/Static ext4 nofail 0 0" >> /etc/fstab'
#   echo "LABEL=Static /mnt/Static ext4 nofail 0 0"|
#       sudo tee -a /etc/fstab >/dev/null
    set +x
    echo "Appended a line to /etc/fstab."
    set -x

fi

set +x

echo "   |vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv|"
echo "   | Might get an error:                             |"
echo "   | Warning: Unit file of apache2.service changed   |"
echo "   | on disk, 'systemctl daemon-reload' recommended. |"
echo "   |                                                 |"
echo "   | The reboot will probably fix everything.        |"
echo "   |^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|"

set -x

sudo shutdown -r now

fi

## Foot Note:

# As Michael explains, it really comes down to the quoting you're
# using and which shell the command is being evaluated in.

# sudo sh -c "echo $ap_ip  library library.lan rachel rachel.lan >> /etc/hosts"

# I would recommend this one as the "correct" solution. IMHO it's
# the simplest one and avoids `sudo -E`. The `$ap_ip` is evaluated
# in the current shell. You don't need to export the variable
# because the subshells don't need to read the variable and never
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
