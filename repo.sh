#!/bin/bash

# File: repo.sh

echo "Begin repo.sh script: $(date)"
export BRANCH="add-config"

echo "Installing git..."
if  sudo apt-get -y install git 
then
    echo "... git successfully installed at `date`."
else
    echo "Error installing git! Terminating!"
    exit 1
fi

if [ -z "$PARENT_DIR" ]
then
    export PARENT_DIR="$HOME"
fi

if [ -z $phInfoDIR ]
then
    export phInfoDIR="phInfo"
fi

echo "Changing into the PARENT_DIRectory."
cd "${PARENT_DIR}"

echo "Cloning phInfo repository..."
if  git clone https://github.com/alexKleider/phInfo.git ${phInfoDIR}
then
    echo "... phInfo repository successfully cloned."
    echo "Change directory into the repo..."
    if cd ${PARENT_DIR}/${phInfoDIR}
    then
        echo "...successful cd into `pwd`"
    else
        echo "... Failed cd into repository's directory! Teminating!"
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
else
    echo "Cloning of the phInfo repo failed! Terminating!"
    exit 1
fi
echo "Successfully ending repo.sh script: $(date)"
echo "Script ended- you'll need to again change"
echo "into the repository directory to continue."
# We are in a subsidiary shell.
