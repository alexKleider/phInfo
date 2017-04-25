#!/bin/bash

# File: pathagar-setup.sh

cd
git clone https://github.com/pathagarbooks/pathagar.git
cd pathagar
virtualenv -p python2.7 penv
source penv/bin/activate  # `deactivate` when done.

cd ~/phInfo
./adjust-db-pw.sh
cp ~/phInfo/set-db-pw.sh ~/pathagar

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site-config /etc/apache2/sites-available/

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/

pip install -r requirements.pip

cd ~/pathagar
./set-db-pw.sh
