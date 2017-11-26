#!/bin/bash

# File: repo.sh

export BRANCH=master

echo "Installing git..."
if  sudo apt-get -y install git 
then
    echo "... git successfully installed."
else
    echo "Error installing git: must exit"
    exit 1
fi

echo "Changing into the users home directory."
cd ${HOME}

echo "Cloning phInfo repository..."
if  git clone https://github.com/alexKleider/phInfo.git 
then
    echo "... phInfo repository successfully cloned."
    echo "Change directory into the repo..."
    if cd ~/phInfo
    then
        echo "...successful 'cd ~/phInfo'"
    else
        echo "... Failed 'cd ~/phInfo'"
    fi
    echo "Changing into $BRANCH branch..."
    if git checkout $BRANCH
    then
        echo "... changed into $BRANCH branch."
    else
        echo "... branch change failed."
    fi
    echo "You'll have to 'cd phInfo', script can't do it."
    # We are in a subsidiary shell.
else
    echo "Cloning of the phInfo repo failed!"
fi
