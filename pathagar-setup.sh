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
    echo "wrong place- MUST ABORT!"
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

echo "Several files need to be copied over:"

# Move the script that will later set the db password:
cp ~/phInfo/set-db-pw.sh ~/pathagar
echo "  1. set-db-pw.sh"

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/
echo "  2. ph-site.conf => sites-available"

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/
echo "  3. local_settings.py"

## Set up the virtualenv for pathagar (penv).
cd ~/pathagar
if [ -d penv ]
then
    echo "The 'penv' (pathagar environment) virtual environment"
    echo "already exists!  ABORTING!"
    exit 1
else
    # We call it 'penv' for 'pathagar environment.'
    echo "The 'penv' (pathager environment) virtual environment"
    echo "is being created..."
    virtualenv -p python2.7 penv
fi
echo "... and activated."
source penv/bin/activate
echo "Now installing (takes a long time) requirements..."
pip install -r requirements.pip
echo "Requirements installed into the penv."

## Run the script that establishes the data base password.
echo "Establishing the data base password"
./set-db-pw.sh

## Prepare apache2 for pathagar:
echo "Enable the apache2 wsgi module.."
sudo a2enmod wsgi
echo "Disable the default apache2 static site."
sudo a2dissite 000-default
echo "Enable the pathagar site."
sudo a2ensite ph-site
if [ -d /var/www/pathagar_media ]
then
    echo "Something is not right:"
    echo "/var/www/pathagar_media/ already exists!!"
else
    echo "Create /var/www/pathagar_media/ ..."
    sudo mkdir /var/www/pathagar_media
fi
echo "Change /var/www/pathagar_media ownership to www-data"
sudo chown www-data:www-data /var/www/pathagar_media
echo "Restarting apache"
sudo service apache2 restart
echo "Run manage.py syncdb --noinput"
python manage.py syncdb --noinput
echo "Run manage.py collectstatic --noinput"
python manage.py collectstatic --noinput

echo "You have yet to set up the superuser manually using"
echo "the python manage.py createsuperuser command."
