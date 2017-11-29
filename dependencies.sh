#!/bin/bash

# File: dependencies.sh

# Purpose is to install the various dependencies.
# It is assumed that your OS has python 2.7 as the default python.

# With the change from jesse to stretch, the libmysqlclient-dev
# package was chanaged to default-libmysqlclient-dev.

# default-libmysqlclient-dev    #stretch
# libmysqlclient-dev      # jesse

# RE DEBIAN_FRONTEND: see
# https://serverfault.com/questions/227190/how-do-i-ask-apt-get-to-skip-any-interactive-post-install-configuration-steps
# May need to add the -q option. (see man apt-get)


echo "Begin dependencies.sh script: $(date)"
echo "First attempt installation of dependencies with names"
echo "that haven't changed between 'jessie' and 'stretch'..."
if sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 \
  python-pip \
  python-virtualenv \
  python-dev \
  libapache2-mod-wsgi \
  libxml2-dev \
  libxslt1-dev \
  mysql-server 
then
    echo "...'Easy ones' installed; now try [default-]libmysqlclient-dev:"
else
    echo "...Installation of 'easy' dependencies failed!"
    exit 1
fi

echo "There remains to install [default-]libmysqlclient..."
echo " Try first Stretch version; if fail run Jessie version:"
if sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
    default-libmysqlclient-dev \
|| \
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  libmysqlclient-dev
then
  echo "... all is well.[default-]libmysqlclient successfully installed."
else
  echo "... Unsuccessfull- problems loading [default-]libmysqlclient!"
fi

echo "End dependencies.sh script: $(date)"

# No need for a reboot at the end of this script.

