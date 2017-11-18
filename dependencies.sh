#!/bin/bash

# File: dependencies.sh

# Purpose is to install the various dependencies.
# It is assumed that your OS has python 2.7 as the default python.

# set -o errexit  # We don't want command failure to end the script:
# If using Jesse the first 'apt-get install' command will fail-
# If it does, we want the script to then go on and execute the
# jesse version.

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

# Do we really need to reboot here??
shutdown -r now

