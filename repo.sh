#!/bin/bash

# File: repo.sh

echo "Installing git..."
if [ sudo apt-get -y install git ]
then
    echo "Installed git"
else
    echo "Error installing git: must exit"
    exit 1
fi

echo "Changing into the users home directory."
cd ${HOME}

echo "Cloning phInfo repository..."
if [ git clone https://github.com/alexKleider/phInfo.git ]
then
    echo "Finished cloning the phInfo repository."
    echo "Now you want to \'cd phInfo\'"
    # No point in doing it here because we are in a subsidiary shell.
else
    echo "Cloning of the phInfo repo failed!"
fi
