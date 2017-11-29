#!/bin/bash

# File: favourites.sh

# This script brings in some utilities (which I[1] find useful)
# and copies over my vimrc file


echo "Begin script favourites.sh: $(date)"
date
echo "Run install command..."
if sudo apt-get -y install vim vim-scripts dnsutils screen
then
    echo "...installation successful:"
    echo "Just finished installing vim, vim-scripts,"
    echo "...dnsutils (to bring in dig) & screen."
else
    echo "...install command failed!"
fi
date
# The following is only for those who
# use vim and like my[1] vim defaults.
if cp ~/phInfo/vimrc /home/pi/.vimrc
then
    echo "...success:"
    echo "Copied custom .vimrc file to /root/ and to /home/pi/."
else
    echo "...failed!"
fi
echo "End script favourites.sh: $(date)"

# [1] Alex Kleider alex@kleider.ca
