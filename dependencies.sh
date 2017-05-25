#!/bin/bash

# File: dependencies.sh
# It is assumed that your OS has python 2.7 as the default python.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

apt-get -y install apache2
apt-get -y install python-pip python-virtualenv
apt-get -y install python-dev libapache2-mod-wsgi
apt-get -y install libmysqlclient-dev libxml2-dev libxslt1-dev
apt-get -y install mysql-server
