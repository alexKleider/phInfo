#!/bin/bash

# File: pi-upgrade.sh

# must be run as super user (sudo)

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -x     # Echo commands to stdout.

raspi-config

apt-get DEBIAN_FRONTEND=noninteractive --fix-missing update
apt DEBIAN_FRONTEND=noninteractive -y --fix-missing upgrade
apt-get DEBIAN_FRONTEND=noninteractive -y dist-upgrade

shutdown -h now
# a reboot is required for the latest kernel to be implemented.


