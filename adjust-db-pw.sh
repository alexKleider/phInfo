#!/bin/bash

# File: adjust-db-password.sh

# Run from within ~/phInfo/pathagar-setup.sh which will have already
# checked that the env var MYSQL_PASSWORD has already been set.
# Checks that the target files are present.

echo "Checking for presence of the two target files."
if [ -f mysql-setup.sh ] && [ -f local_settings.py ]
then
    echo "All is in order:"
    echo " 1. MYSQL_PASSWORD variable has been set to $MYSQL_PASSWORD"
    echo " 2. Both target files are present:"
    echo "  a. mysql-setup.sh"
    echo "  b. local_settings.py"

    echo "Running sed to set password variable in the two target files."
    sed -i s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g mysql-setup.sh local_settings.py
else
    echo "Target files: mysql-setup.sh, local_settings.py"
    echo "One or both target files are not present- ABORTING!"
    exit 1
fi

