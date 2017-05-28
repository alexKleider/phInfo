#!/bin/bash

# File: adjust-db-password.sh

# Run from within ~/phInfo/pathagar-setup.sh
# Checks that the env var MYSQL_PASSWORD has already been set
# and that the target files are present.

if [ -z $MYSQL_PASSWORD ]
then
    echo "MYSQL_PASSWORD variable has not been set- ABORTING!"
    exit 1
fi

if [ -f set-db-pw.sh ] && [ -f local_settings.py ]
then
    echo "All is in order:"
    echo " 1. MYSQL_PASSWORD variable has been set to $MYSQL_PASSWORD"
    echo " 2. Both target files are present:"
    echo "  a. set-db-pw.sh"
    echo "  b. local_settings.py"

    sed -i s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g set-db-pw.sh local_settings.py

    echo "Password has been moved to the appropriate two files."
else
    echo "One or both target files are not present- ABORTING!"
    exit 1
fi

