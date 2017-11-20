#!/bin/bash

# File: dependencies.sh

# Purpose is to install the various dependencies.
# It is assumed that your OS has python 2.7 as the default python.

# set -o errexit  # We don't want command failure to end the script:

# With the change from jesse to stretch, the libmysqlclient-dev
# package was chanaged to default-libmysqlclient-dev. As a result:
# If using Jesse the first 'apt-get install' command will fail-
# If it does, we want the script to then go on and execute the
# jesse version.
# The point is that one of the two install commands WILL/ARE EXPECTED
# to fail.

# RE DEBIAN_FRONTEND: see
# https://serverfault.com/questions/227190/how-do-i-ask-apt-get-to-skip-any-interactive-post-install-configuration-steps
# May need to add the -q option. (see man apt-get)

set -x          # all commands are echoed to the terminal

# if using Stretch (vs Jessie) use the following:
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 \
  python-pip \
  python-virtualenv \
  python-dev \
  libapache2-mod-wsgi \
  libxml2-dev \
  libxslt1-dev \
  mysql-server \
  default-libmysqlclient-dev    #stretch

# if using Jessie (vs Stretch) use the following:
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 \
  python-pip \
  python-virtualenv \
  python-dev \
  libapache2-mod-wsgi \
  libxml2-dev \
  libxslt1-dev \
  mysql-server \
  libmysqlclient-dev      # jesse

# Do we need to reboot here?? No, we don't.

