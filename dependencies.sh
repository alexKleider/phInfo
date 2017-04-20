#!/bin/bash

# File: dependencies.sh

# Use this script rather than update.sh when not using a Raspberry Pi.

apt-get -y install python2.7
apt-get -y install git apache2
apt-get -y install python-pip python-virtualenv
apt-get -y install mysql-server
apt-get -y install libmysqlclient-dev libxml2-dev libxslt1-dev
apt-get -y install python-dev
apt-get -y install vim vim-scripts dnsutils screen
