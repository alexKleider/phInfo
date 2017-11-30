#!/bin/bash
# File: create_server.sh

# Before sourcing this file:
#  1. If you have elected to change the Access Point's IP address
#  then you should change the '10.10.10.10' IP address in the
#  "export AP_IP="10.10.10.10" line early in the script.
#  to the address you choose.  Corresponding changes should have
#  been or will still need to be made in dnsmasq.conf and
#  interfaces (and possibly elsewhere as well.)
#  2. Near the end, you'll see comments pertaining to an entry
#  in the `/etc/fstab` file; specifically `LABEL=Static`. You
#  may want to change the `LABEL` to something other than
#  "Static" to suit your own purposes.

echo "Begin create_server.sh script: $(date)"

echo "Assign AP_IP - Access Point IP address..."
if [ -z $AP_IP ]
then
    export AP_IP="10.10.10.10"  
    echo "...defaults to $AP_IP" 
else
    echo "...set to $AP_IP (by config file)"
fi

if [ -a /etc/hosts.original ]
then
    echo "/etc/hosts.original exists so we assume"
    echo "additions have already been made to the file."
    echo "We therefore conclude that:"
    echo "THIS SCRIPT HAS ALREADY BEEN RUN!! TERMINATING!"
    exit 1
fi

echo "Saving a copy of the original /etc/hosts file..."
if sudo cp /etc/hosts /etc/hosts.original
then
    echo "...successfull copy to /etc/hosts.original."
else
    echo "... cp /etc/hosts => /etc/hosts.original FAILED! TERMINATING!"
    exit 1
fi

echo "Assigning URLs..."

echo "...for pathagar..."
if [ -z $LIBRARY_URL ]
then
    export LIBRARY_URL='library.lan'
    echo "...using default: $LIBRARY_URL"
else
    echo "...from config: $LIBRARY_URL"
fi

if [ -z $RACHEL_URL ]
then
    export RACHEL_URL="rachel.lan"
    echo "...using default: $RACHEL_URL"
else
    echo "...from config: $RACHEL_URL"
fi

echo "Append a (IP > URLs) line to /etc/hosts..."
if sudo sh -c "echo $AP_IP $LIBRARY_URL $RACHEL_URL >> /etc/hosts"
# the following are two alternative ways of doing the same thing.
# the first has been tested, the second has not.
#   sudo -E sh -c 'echo "$AP_IP $LIBRARY_URL $RACHEL_URL" >> /etc/hosts'
#   echo "$AP_IP $LIBRARY_URL $RACHEL_URL"|sudo tee -a /etc/hosts >/dev/null
# See footnote by Aaron at end of file.
then
    echo "... success appending line to /etc/hosts."
else
    echo "... appending line to /etc/hosts FAILED! TERMINATING!"
    exit 1
fi
# The entry 
# $AP_IP  $LIBRARY_URL $RACHEL_URL
# in /etc/hosts will direct WiFi dhcp clients to server.
# The ultimate goal is to have
#              $LIBRARY_URL  directed to pathagar book server
#           and $RACHEL_URL  directed to static content server.


echo "Prepare a mount point for the Static Content..."
if [ -z $MOUNT_POINT ]
then
    export MOUNT_POINT="/mnt/Static"
    echo "...defaults to /mnt/Static..."
else
    echo "...set to $MOUNT_POINT (by config file)"
fi
if [ -d $MOUNT_POINT ]
then
    echo "...Warning: directory $MOUNT_POINT already exists!"
else
    echo "Creating a $MOUNT_POINT directory..."
    if sudo mkdir $MOUNT_POINT
    then
        echo "... success."

        echo "Assign ownership..."
        if [ -z $MAIN_USER ]
        then
            export MAIN_USER="var_name" 
            echo "...defaults to $USER..."
        else
            echo "...set to $MAIN_USER (by config file)"
        fi

        echo "Change its ownership to user $MAIN_USER..."
        if sudo chown $MAIN_USER:$MAIN_USER $MOUNT_POINT
        then
            echo "...ownership successfully changed to '$MAIN_USER'"
        else
            echo "...change of ownership FAILED! TERMINATING!"
            exit 1
        fi
    else
        echo "... creation of /mnt/Static directory FAILED! TERMINATING!"
        exit 1
    fi
fi

echo "Prepeare a directory for static content..."
echo "Assign DIR4STATIC variable..."
if [ -z $DIR4STATIC ]
then
    export DIR4STATIC="/var/www/static" 
    echo "...defaults to '/var/www/static'..."
else
    echo "...set to '$DIR4STATIC' (by config file)"
fi

if [ -d $DIR4STATIC ]
then
    echo "Warning: directory '$DIR4STATIC' already exists!"
else
    # The following directory is created to host content
    # for the static content server.
    echo "Creating $DIR4STATIC directory..."
    if sudo mkdir $DIR4STATIC
    then
        echo "... $DIR$STATIC created."

        echo "Changing its ownership to user '$MAIN_USER'..."
        if sudo chown ${MAIN_USER}:${MAIN_USER} $DIR4STATIC
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
        echo "    ... copy FAILED! Teminating!"
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
        echo "    ...copy command FAILED! TERMINATING!"
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
    echo "...reload FAILED!"
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
        if sudo sh -c 'echo "LABEL=Static $MOUNT_POINT ext4 nofail 0 0" >> /etc/fstab'
        then
            echo "    ... successfully added the line."
        else
            echo "    ... Appending the line FAILED!"
        fi
    else
        echo "    ...failure to save /etc/fstab.original!"
    fi

#   echo "LABEL=Static $MOUNT_POINT ext4 nofail 0 0"|
#       sudo tee -a /etc/fstab >/dev/null

fi

echo "End create-server.sh script: $(date)"

sudo shutdown -r now

## Foot Note:

# As Michael explains, it really comes down to the quoting you're
# using and which shell the command is being evaluated in.

# sudo sh -c "echo $AP_IP  library library.lan rachel rachel.lan >> /etc/hosts"

# I would recommend this one as the "correct" solution. IMHO it's
# the simplest one and avoids `sudo -E`. The `$AP_IP` is evaluated
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
