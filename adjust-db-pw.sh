#!/bin/bash

# File: adjust-db-password.sh

# Run from within ~/phInfo/pathagar-setup.sh

sed -i s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g set-db-pw.sh local_settings.py
