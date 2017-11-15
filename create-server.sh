#!/bin/bash
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

echo "Begin create_server.sh script: `date`"
export ap_ip="10.10.10.10"
echo "We assume the server's WiFi IP address is $ap_ip"

if [ -a /etc/hosts.original ]
then
    echo "/etc/hosts.original exists so we assume"
    echo "additions have already been made to the file."
else
    echo "Saving a copy of the original /etc/hosts file..."
    if sudo cp /etc/hosts /etc/hosts.original
    then
        echo "...successfull copy to ...original."
    else
        echo "... cp /etc/hosts => /etc/hosts failed! Terminating!"
        exit 1
    fi

    echo "Append a line to /etc/hosts..."
    if sudo sh -c "echo $ap_ip library library.lan rachel rachel.lan >> /etc/hosts"
# the following are two alternative ways of doing the same thing.
# the first has been tested, the second has not.
#   sudo -E sh -c 'echo "$ap_ip  library library.lan rachel rachel.lan" >> /etc/hosts'
#   echo "$ap_ip  library library.lan rachel rachel.lan"|sudo tee -a /etc/hosts >/dev/null
# See footnote by Aaron at end of file.
    then
        echo "... success appending a line to /etc/hosts."
    else
        echo "... appending line to /etc/hosts failed! Terminating."
        exit 1
    fi
# The entry 
# 10.10.10.10  library.lan rachel.lan
# in /etc/hosts will direct WiFi dhcp clients to server.
# The ultimate goal is to have
#               library.lan directed to pathagar book server
#           and rachel.lan directed to static content server.
fi

echo "Prepare a mount point for the Static Content..."
if [ -d /mnt/Static ]
then
    echo "...Warning: directory /mnt/Static already exists!"
else
    echo "Creating a /mnt/Static directory..."
    if sudo mkdir /mnt/Static
    then
        echo "... success."
        echo "Change its ownership to user 'pi'..."
        if sudo chown pi:pi /mnt/Static
        then
            echo "...ownership successfully changed to 'pi'"
        else
            echo "...change of ownership failed!"
        fi
    else
        echo "... creation of /mnt/Static directory failed!"
    fi
fi

if [ -d /var/www/static ]
then
    echo "Warning: directory /var/www/static already exists!"
else
    # The following directory is created to host content
    # for the static content server.
    echo "Creating /var/www/static directory..."
    if sudo mkdir /var/www/static
    then
        echo "... /var/www/static created."
        echo "Changing its ownership to user 'pi'..."
        if sudo chown pi:pi /var/www/static
        then
            echo "... ownership successfully changed."
        else
            echo "... failure of ownership change!"
        fi
    else
        echo "...failure of directory creation! Teminating!"
        exit 1
    fi
fi

# If get an error about resolving host name, check that the correct
# host name appears in /etc/hosts:
#       127.0.0.1 localhost localhost.localdomain <hostname>
#       127.0.1.1 <hostname>.
# and that /etc/hostname contains the correct <hostname>

echo "Setting up the Apache Server..."
if [ -f /etc/apache2/sites-available/static.conf ]
then
    echo "Warning: /etc/apache2/sites-available/static.conf exists!"
else
    echo "  1. Copy static.conf to sites-available..."
    if sudo cp static.conf /etc/apache2/sites-available/static.conf
    then
        echo "    ... successful copy."
    else
        echo "    ... copy failed! Teminating!"
        exit 1
    fi
fi

echo "Copy an index.html file; get a sample site running..."
# thus providing an opportunity to test that all is well before
# copying over the static content:
if [ -f /var/www/static/index.html ]
then
    echo "Warning: /var/www/static/index.html exists!"
else
    echo "  1. Copy to /var/www/static/index.html..."
    if cp html-index-file  /var/www/static/index.html
    then
        echo "    ...copy successful"
    else
        echo "    ...copy command failed! Terminating!"
        exit 1
    fi
fi

echo "Dissable Apache's default site..."
if sudo a2dissite 000-default
then
    echo "...default site disabled."
else
    echo "...Failed to disable default site!!"
fi

echo "   |vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv|"
echo "   | Expect a warning:                                   |"
echo "   | To activate the new configuration, you need to run: |"
echo "   |   systemctl reload apache2.                         |"
echo "   |                                                     |"
echo "   | The upcoming reboot will accomplish the same thing. |"
echo "   |^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|"

echo "Enable the static site..."
if sudo a2ensite static
then
    echo "...static site enabled"
else
    echo "...Failed to enable static site!"
fi

echo "Reload apache..."
if sudo service apache2 reload
then
    echo "...successful reload."
else
    echo "...reload failed!"
fi

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

echo "Customizing /etc/fstab..."
if [ -a /etc/fstab.original ]
then
    echo "...Warning: /etc/fstab.original already exists!"
else
    echo "  1. Save a copy of the original /etc/fstab file..."
    if sudo cp /etc/fstab /etc/fstab.original
    then
        echo "    .../etc/fstab.original saved."
        echo "  2. Add a 'LABEL=Static ... line to /etc/fstab..."
        if sudo sh -c 'echo "LABEL=Static /mnt/Static ext4 nofail 0 0" >> /etc/fstab'
        then
            echo "    ... successfully added the line."
        else
            echo "    ... Appending the line failed!"
        fi
    else
        echo "    ...failure to save /etc/fstab.original!"
    fi

#   echo "LABEL=Static /mnt/Static ext4 nofail 0 0"|
#       sudo tee -a /etc/fstab >/dev/null

fi

echo "End create-server.sh script: `date`"

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
