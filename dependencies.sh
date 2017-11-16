#!/bin/bash

# File: dependencies.sh

# Purpose is to install the pathagar dependencies.

# It is assumed that your OS has python 2.7 as the default python.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.
set -x          # all commands are echoed to the terminal

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 \
  python-pip \
  python-virtualenv \
  python-dev \
  libapache2-mod-wsgi \
  libmysqlclient-dev \
  libxml2-dev \
  libxslt1-dev \
  mysql-server

# May need to reboot here??
# shutdown -r now



