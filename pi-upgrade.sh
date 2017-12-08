#!/bin/bash

# File: pi-upgrade.sh

# No defaults needed.

echo "Begin running  pi-upgrade.sh on $(date)..."

echo "...first: update..."
if sudo apt --fix-missing update
then
    echo "... update successfull."
else
    echo " ... update FAILED! TERMINATING!"
    exit 1
fi

echo "...second: upgrade..."
if  sudo apt -y --fix-missing upgrade
then
    echo "... upgrade successfull."
else
    echo " ... upgrade FAILED! TERMINATING!"
    exit 1
fi

echo "...third (& finally): dist-upgrade..."
if sudo apt -y dist-upgrade
then
    echo "... dist-upgrade successfull."
else
    echo " ... dist-upgrade FAILED! TERMINATING!"
    exit 1
fi

echo "...finished running pi-upgrade.sh on $(date)"
echo " Rebooting in order to bring in the latest kernel."
sudo shutdown -r now
# a reboot is required for the latest kernel to be implemented.


