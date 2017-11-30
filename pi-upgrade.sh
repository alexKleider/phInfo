#!/bin/bash

# File: pi-upgrade.sh

# No defaults needed.

set -o errexit  # ends if an error is returned.
set -x          # Echo commands to stdout.

echo "Begin running  pi-upgrade.sh on `date`..."

echo "...first: update..."
if sudo apt --fix-missing update
then
else
fi

echo "...second: upgrade..."
if  sudo apt -y --fix-missing upgrade
then
else
fi

echo "...third (& finally): dist-upgrade..."
if sudo apt -y dist-upgrade
then
else
fi


echo "...finished running pi-upgrade.sh on `date`"
echo " Rebooting in order to bring in the latest kernel."
sudo shutdown -r now
# a reboot is required for the latest kernel to be implemented.


