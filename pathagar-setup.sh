#!/bin/bash

# File: pathagar-setup.sh
# ... assumes the env var MYSQL_PASSWORD has already been set:
# the adjust-db-pw.sh script depends on it.

set -o errexit  # ends if an error is returned.
set -o pipefail # pipe failure causes an error.
set -o nounset  # ends if an undefined variable is encountered.

set -x

## Pathagar
cd
if [ -d /home/pi/pathagar ]
then
    set +x
    echo "It seems pathagar has already been cloned."
    echo "You have probably already run this script."
    echo "Script \"pathagar-setup.sh\" ending now."
    set -x
    exit 1
else
    git clone https://github.com/pathagarbooks/pathagar.git
fi

if [ -d /home/pi/phInfo ]
then
    cd /home/pi/phInfo
else
    set +x
    echo "I can't imagine how it could happen, but"
    echo "the phInfo directory is missing or in the"
    echo "wrong place- MUST ABORT!"
    set -x
    exit 1
fi
# Checking that the MYSQL_PASSWORD env var is set:
if [ -z $MYSQL_PASSWORD ]
then
    set +x
    echo "The MYSQL_PASSWORD environment variable hasn't been set!"
    echo "Script pathagar-setup.sh is being aborted."
    set -x
    exit 1
else
    set +x
    echo "Modifying files that will later use the MYSQL_PASSWORD."
    set -x
    ./adjust-db-pw.sh
fi

set +x
echo "Several files need to be copied over:"
set -x

# Move the script that will later set the db password:
cp ~/phInfo/set-db-pw.sh ~/pathagar
set +x
echo "  1. set-db-pw.sh"
set -x

## Add the pathagar config file to Apache's sites-available.
sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/
set +x
echo "  2. ph-site.conf => sites-available"
set -x

## Modify the default Django settings to suit our purposes:
cp ~/phInfo/local_settings.py ~/pathagar/
set +x
echo "  3. local_settings.py"
set -x

## Set up the virtualenv for pathagar (penv).
cd ~/pathagar
if [ -d penv ]
then
    set +x
    echo "The 'penv' (pathagar environment) virtual environment"
    echo "already exists!  ABORTING!"
    set -x
    exit 1
fi
# We call it 'penv' for 'pathagar environment.'
set +x
echo "The 'penv' (pathager environment) virtual environment"
echo "is being created..."
set -x
virtualenv -p python2.7 penv

set +o nounset  # To overcome PS1 unset bug in virtualenv.
source penv/bin/activate
set -o nounset  # ends if an undefined variable is encountered.
set +x
echo "... and activated."
echo "Now installing (takes a long time) requirements..."
set -x
pip install -r requirements.pip
set +x
echo "Requirements installed into the penv."
set -x

## Run the script that establishes the data base password.
set +x
echo "Establishing the data base password"
set -x
./set-db-pw.sh

## Prepare apache2 for pathagar:
set +x
echo "Enable the apache2 wsgi module.."
set -x
sudo a2enmod wsgi
set +x
echo "Disable the default apache2 static site."
set -x
sudo a2dissite 000-default
set +x
echo "Enable the pathagar site."
set -x
sudo a2ensite ph-site
if [ -d /var/www/pathagar_media ]
then
    set +x
    echo "Something is not right:"
    echo "/var/www/pathagar_media/ already exists!!"
    set -x
else
    set +x
    echo "Create /var/www/pathagar_media/ ..."
    set -x
    sudo mkdir /var/www/pathagar_media
fi
set +x
echo "Change /var/www/pathagar_media ownership to www-data"
set -x
sudo chown www-data:www-data /var/www/pathagar_media
set +x
echo "Restarting apache"
set -x
sudo service apache2 restart
set +x
echo "Run manage.py syncdb --noinput"
set -x
python manage.py syncdb --noinput
set +x
echo "Run manage.py collectstatic --noinput"
set -x
python manage.py collectstatic --noinput

set +x
echo "You have yet to set up the superuser manually using"
echo "the python manage.py createsuperuser command."
set -x
