#!/bin/bash

# File: pathagar-setup.sh
# ... assumes the env var MYSQL_PASSWORD has already been set:
# the adjust-db-pw.sh script depends on it.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

## Pathagar
cd
if [ -d /home/pi/pathagar ]
then
    echo "It seems pathagar has already been cloned."
    echo "You have probably already run this script."
    echo "Script \"pathagar-setup.sh\" ending now."
    exit 1
else
    git clone https://github.com/pathagarbooks/pathagar.git
fi

if [ -d /home/pi/phInfo ]
then
    cd /home/pi/phInfo
else
    echo "I can't imagine how it could happen, but"
    echo "the phInfo directory is missing or in the"
    echo "place- MUST ABORT!"
    exit 1
fi
# Checking that the MYSQL_PASSWORD env var is set:
if [ -z $MYSQL_PASSWORD ]
then
    echo "The MYSQL_PASSWORD environment variable hasn't been set!"
    echo "Script pathagar-setup.sh is being aborted."
    exit 1
else
    echo "Modifying files that will later use the MYSQL_PASSWORD."
    ./adjust-db-pw.sh
fi

# Move the script that will later set the db password:
cp ~/phInfo/set-db-pw.sh ~/pathagar

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/

## Set up the virtualenv for pathagar (penv).
cd ~/pathagar
if [ -d penv ]
then
    echo "The 'penv' (pathagar environment) virtual environment"
    echo "already exists!  ABORTING!"
    exit 1
else
    # We call it 'penv' for 'pathagar environment.'
    virtualenv -p python2.7 penv
fi
source penv/bin/activate
pip install -r requirements.pip

## Run the script that establishes the data base password.
./set-db-pw.sh

## Prepare apache2 for pathagar:
sudo a2enmod wsgi
sudo a2dissite 000-default
sudo a2ensite ph-site
if [ -d /var/www/pathagar_media ]
then
    echo "Something is not right:"
    echo "/var/www/pathagar_media/ already exists!!"
else
    sudo mkdir /var/www/pathagar_media
fi
sudo chown www-data:www-data /var/www/pathagar_media
sudo service apache2 restart
python manage.py syncdb --noinput
python manage.py collectstatic --noinput

echo "Set up the superuser manually using manage.py."
