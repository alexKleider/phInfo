#!/bin/bash

# File ph-setup.sh

## Run from within ~/phInfo/pathagar-setup.sh
### BEFORE RUNNING:
# Be sure you have already assigned a password of your choosing
# to the MYSQL_PASSWORD environment variable (as described in the
# README.md file.)

## Set up a mysql server:

sudo mysql <<EOF
CREATE DATABASE pathagar CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER "pathagar" IDENTIFIED BY "MYSQL_PASSWORD";
GRANT ALL PRIVILEGES ON pathagar.* TO "pathagar";
FLUSH PRIVILEGES;
EOF

