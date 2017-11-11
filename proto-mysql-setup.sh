#!/bin/bash

# File: proto-mysql-setup.sh
# To be distinguished from mysql-setup.sh
# This file is derived from mysql-setup.sh by 
# using sed to set the password- this is done within 
# the ~/phInfo/pathagar-setup.sh script.

## Must be run from within ~/phInfo/pathagar-setup.sh
## Do not merge into the pathagar-setup.sh script!!
## This script must first be copied into the pathagar repository.

## Sets up the mysql server:
echo " Calling sudo mysql ... (from within mysql-setup.sh script.)"
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS pathagar CHARACTER SET utf8 COLLATE utf8_bin;
DROP USER IF EXISTS pathagar;
FLUSH PRIVILEGES;
CREATE USER "pathagar" IDENTIFIED BY "MYSQL_PASSWORD";
GRANT ALL PRIVILEGES ON pathagar.* TO "pathagar";
FLUSH PRIVILEGES;
EOF
########################################
# Finally deleted the drop user part and completed OK
####################################
# Now trying pi instead of pathagar:
# Still getting
# ERROR 1396 (HY000) at line 2: Operation DROP USER failed for
# 'pi'@'%'
#####################################
# after adding   drop user pathagar; flush privileges; got the
# following error:
# Establishing the data base password
# + ./set-db-pw.sh
# ERROR 1396 (HY000) at line 2: Operation DROP USER failed for
# 'pathagar'@'%'
######################################
# before adding   drop user pathagar; flush privileges; got the
# following error:
# CREATE USER ....
# fails:
# + ./set-db-pw.sh
# ERROR 1396 (HY000) at line 2: Operation CREATE USER failed for 'pathagar'@'%'


# Current failure:
# ERROR 1396 (HY000) at line 2: Operation CREATE USER failed for
# 'pathagar'@'%'

# solution:
# pi@pi2:~/pathagar $ sudo mysql
# Welcome to the MySQL monitor.  Commands end with ; or \g.
# Your MySQL connection id is 41
# Server version: 5.5.54-0+deb8u1 (Raspbian)

# Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights
# reserved.
 
# Oracle is a registered trademark of Oracle Corporation and/or its
# affiliates. Other names may be trademarks of their respective
# owners.

# Type 'help;' or '\h' for help. Type '\c' to clear the current input
# statement.

# mysql> drop user pathagar;
# Query OK, 0 rows affected (0.00 sec)

# mysql> flush privileges;
# Query OK, 0 rows affected (0.00 sec)

# mysql> Bye


