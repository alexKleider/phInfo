#!/bin/bash

# File: pi-upgrade.sh

set -o errexit  # ends if an error is returned.
set -x          # Echo commands to stdout.

echo "Running edit-scripts version of pi-upgrade.sh"

sudo apt --fix-missing update
sudo apt -y --fix-missing upgrade
sudo apt -y dist-upgrade

echo "Finished running edit-scripts version of pi-upgrade.sh"
sudo shutdown -r now
# a reboot is required for the latest kernel to be implemented.


