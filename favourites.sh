#!/bin/bash

# File: favourites.sh

# This script brings in some utilities (which I[1] find useful)
# and copies over my vimrc file

if [ -z "$MAIN_USER" ]
then
    echo 'MAIN_USER defaults to "pi".'
    export MAIN_USER=pi
else
    echo "MAIN_USER has been set to $MAIN_USER"
fi

if [ -z "$PARENT_DIR" ]
then
    export PARENT_DIR=$HOME
fi

if [ -z "$phInfoDIR" ]
then
    export phInfoDIR="phInfo"
fi

if [ -z "$REPO" ]
then
    export REPO="${PARENT_DIR}/${phInfoDIR}"
fi

echo "Begin script favourites.sh: $(date)"
echo "Run install command..."
if sudo apt-get -y install vim vim-scripts dnsutils screen
then
    echo "...installation successful:"
    echo "Just finished installing vim, vim-scripts,..."
    echo "...dnsutils (to bring in dig) & screen."
else
    echo "...install command FAILED!  $(date)"
fi

# The following is only for those who
# use vim and like my[1] vim defaults.
echo "Copying vimrc onto pi home directory..."
if cp "${REPO}/vimrc" "${HOME}/.vimrc"
then
    echo "...success:"
    echo "Copied custom .vimrc file to /home/${MAIN_USER}/."
else
    echo "...FAILED to copy .vimrc!"
fi
echo "End script favourites.sh: $(date)"

# [1] Alex Kleider alex@kleider.ca
