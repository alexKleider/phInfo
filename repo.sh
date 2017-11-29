#!/bin/bash

# File: repo.sh

echo "Begin repo.sh script: $(date)"
export BRANCH=master

echo "Installing git..."
if  sudo apt-get -y install git 
then
    echo "... git successfully installed."
else
    echo "Error installing git! Terminating!"
    exit 1
fi

echo "Changing into the users home directory."
if ! cd "${HOME}"
then
  echo "Could not cd into HOME." >&2
  exit 1
fi

echo "Cloning phInfo repository..."
if  git clone https://github.com/alexKleider/phInfo.git 
then
    echo "... phInfo repository successfully cloned."
    echo "Change directory into the repo..."
    if cd ~/phInfo
    then
        echo "...successful 'cd ~/phInfo'"
    else
        echo "... Failed 'cd ~/phInfo'! Teminating!"
        exit 1
    fi
    echo "Changing into $BRANCH branch..."
    if git checkout $BRANCH
    then
        echo "... changed into $BRANCH branch."
    else
        echo "... branch change failed.! Teminating!"
        exit 1
    fi
    echo "You'll have to 'cd phInfo', script can't do it."
    # We are in a subsidiary shell.
else
    echo "Cloning of the phInfo repo failed! Terminating!"
    exit 1
fi
echo "Successfully ending repo.sh script: $(date)"
