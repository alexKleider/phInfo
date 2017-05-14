#!/bin/bash

# File: pathagar-setup.sh

cd
git clone https://github.com/pathagarbooks/pathagar.git

cd ~/phInfo
# the next script assumes env var MYSQL_PASSWORD is set.
./adjust-db-pw.sh
cp ~/phInfo/set-db-pw.sh ~/pathagar

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/

cd ~/pathagar
virtualenv -p python2.7 penv
source penv/bin/activate
pip install -r requirements.pip
./set-db-pw.sh
sudo mkdir /var/www/pathagar_media
sudo chown www-data:www-data /var/www/pathagar_media
python manage.py syncdb
python manage.py collectstatic

