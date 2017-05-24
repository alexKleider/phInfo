#!/bin/bash

# File: pathagar-setup.sh
# ... assumes the env var MYSQL_PASSWORD has already been set:
# the adjust-db-pw.sh script depends on it.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.


cd ~/phInfo
# the next script assumes env var MYSQL_PASSWORD is set.
./adjust-db-pw.sh  # Modifies files per $MYSQL_PASSWORD.
# Move the script that will later set the db password:
cp ~/phInfo/set-db-pw.sh ~/pathagar

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/

## Set up the virtualenv for pathagar (penv).
cd ~/pathagar
virtualenv -p python2.7 penv
source penv/bin/activate
pip install -r requirements.pip

## Run the script that establishes the data base password.
./set-db-pw.sh

## Pathagar
cd
git clone https://github.com/pathagarbooks/pathagar.git
## Prepare apache2 for pathagar:
sudo a2enmod wsgi
sudo a2dissite 000-default
sudo a2ensite ph-site
sudo mkdir /var/www/pathagar_media
sudo chown www-data:www-data /var/www/pathagar_media
sudo service apache2 restart
python manage.py syncdb --noinput
python manage.py collectstatic --noinput
# superuser is to be set up manually using manage.py.
