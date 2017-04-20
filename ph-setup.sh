#!/bin/bash

# File ph-setup.sh

# This 'script' relies on MYSQL_PASSWORD having been set
# and must be run with root privileges.

### BEFORE RUNNING:
# Be sure you have already assigned a password of your choosing
# to the MYSQL_PASSWORD environment variable (as described in the
# README.md file.

## Set up a mysql server:

mysql <<EOF
CREATE DATABASE pathagar CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER "pathagar" IDENTIFIED BY "MYSQL_PASSWORD";
GRANT ALL PRIVILEGES ON pathagar.* TO "pathagar";
FLUSH PRIVILEGES;
EOF

## Configuring MEDIA_ROOT

# MEDIA_ROOT is a directory where book files will be uploaded.
# This must be writable by the `www-data` user.

mkdir /var/www/pathagar_media
chown www-data /var/www/pathagar_media/

## Add the pathagar config file to Apache's sites-available.
cp ~/phInfo/ph-site-config /etc/apache2/sites-available/

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/
