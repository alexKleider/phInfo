#!/bin/bash

# File: pathagar-setup.sh
# ... assumes (and checks) that the env var MYSQL_PASSWORD
# has already been set.
# Calls mysql-setup.sh (formerly called set-db-pw.sh.)
# 'mysql-setup.sh' is derived from 'proto-mysql-setup.sh'
# and then subsequently deleted.
# Script adjust-db-pw.sh has been incorporated into this script.

# set -o nounset  # ends if an undefined variable is encountered.
# set +o nounset  # To overcome PS1 unset bug in virtualenv.
# The only environment variable we care about is MYSQL_PASSWORD
# and we test for that in the code.

if [ -z "$PARENT_DIR" ]
then
    PARENT_DIR="$HOME"
fi

if [ -z "$phInfoDIR" ]
then
    phInfoDIR="phInfo"
fi

if [ -z "$REPO" ]
then
    REPO="${PARENT_DIR}/${phInfoDIR}"
fi

echo "Beginning pathagar-setup.sh script: $(date)"
echo "Attempting to cd ..."
if ! cd "$PARENT_DIR"
then
  echo "Could not cd into \$HOME directory."
  exit 1
fi

echo "Checking that the MYSQL_PASSWORD env var is set."
if [ -z "$MYSQL_PASSWORD" ]
then
    echo "The MYSQL_PASSWORD environment variable hasn't been set!"
    echo "Script 'pathagar-setup.sh' is being aborted."
    exit 1
fi

if [ -d /home/pi/pathagar ]
then
    echo "It seems the pathagar repo has already been cloned."
    echo "You have probably already run this script."
    echo "Script \"pathagar-setup.sh\" is being aborted."
    exit 1
else
    echo "Cloning the pathagar repo."
    git clone https://github.com/pathagarbooks/pathagar.git
fi

if [ -d /home/pi/phInfo ]
then
    echo "Change into the phInfo repo's directory."
    if ! cd "$REPO"
    then
      echo "Could not cd into $REPO. TERMINATING!"
      exit 1
    fi
else
    echo "I can't imagine how it could happen, but the phInfo"
    echo "directory is missing or in the wrong place-"
    echo "Script \"pathagar-setup.sh\" is being aborted."
    exit 1
fi

echo "Checking that the MYSQL_PASSWORD env var is set."
if [ -z "$MYSQL_PASSWORD" ]
then
    echo "The MYSQL_PASSWORD environment variable hasn't been set!"
    echo "Script 'pathagar-setup.sh' is being aborted."
    exit 1
else
    echo "Checking for presence of the two target files."
    if [ -f proto-mysql-setup.sh ] && [ -f local_settings.py ]
    then
        echo "Creating mysql-setup.sh from proto-mysql-setup.sh..."
        if cp proto-mysql-setup.sh mysql-setup.sh
        then
            echo "...successfully copied proto... => mysql-setup.sh"
        else
            echo "...copy FAILED! Terminating!!"
            exit 1
        fi
        echo "All is in order:"
        echo " 1. MYSQL_PASSWORD variable has been set to $MYSQL_PASSWORD"
        echo " 2. Both target files are present:"
        echo "  a. mysql-setup.sh"
        echo "  b. local_settings.py"

        echo "Running sed to set password variable in the two target files."
        if sed -i s/MYSQL_PASSWORD/"$MYSQL_PASSWORD"/g mysql-setup.sh local_settings.py
        then
            echo "...success, but still worth checking if the"
            echo "...password is properly set in the two files."
        else
            echo "...password setting sed command failed!"
            echo "...Terminating!"
            exit 1
        fi
    else
        echo "Target files: proto-mysql-setup.sh, local_settings.py..."
        echo "One or both target files are not present-"
        echo "Script \"pathagar-setup.sh\" is being aborted."
        exit 1
    fi
# end of the 17 line content of adjust-db-password.sh

# the following two lines == how it used to be done:
#   echo "Modifying files that will later use the MYSQL_PASSWORD."
#   ./adjust-db-pw.sh
fi

echo "Several files need to be copied and one deleted:"

echo "1. the script mysql-setup.sh => ~/pathagar..."
if cp ~/phInfo/mysql-setup.sh ~/pathagar
then
    echo "... success."
else
    echo "... copy failed! Terminating!"
    exit 1
fi

echo "2. the default Django settings => ~/pathagar..."
if cp ~/phInfo/local_settings.py ~/pathagar/
then
    echo "... success."
else
    echo "... copy failed! Terminating!"
    exit 1
fi


echo "3. the pathagar config file to Apache's sites-available..."
if sudo cp ~/phInfo/ph-site.conf /etc/apache2/sites-available/
then
    echo "... success."
else
    echo "... copy failed! Terminating!"
    exit 1
fi

echo "3. delete ~/phInfo/mysql-setup.sh..."
if rm "${PARENT_DIR}/phInfo/mysql-setup.sh"
then
    echo "... success."
else
    echo "... deletion failed!"
fi

echo "Change into the ~/pathagar directory..."
if cd "${PARENT_DIR}/pathagar"
then
    echo "... successfull."
else
    echo "... failed! Terminating"
    exit 1
fi

if [ -d penv ]
then
    echo "The 'penv' (pathagar environment) virtual environment"
    echo "already exists!  ABORTING!"
    exit 1
fi

echo "Set up the virtualenv for pathagar (penv)..."
if virtualenv -p python2.7 penv
then
    echo "... success."
else
    echo "... penv creation failed! Terminating!"
    exit 1
fi
# a bug in the above forces us to NOT set -o nounset

echo "Activate the penv..."
# shellcheck disable=SC1091
if source penv/bin/activate
then
    echo "... success."
else
    echo "... penv activation failed! Terminating!"
    exit 1
fi

echo ".. run pip install -r requirements.pip (takes a long time) ..."
if pip install -r requirements.pip
then
    echo "... finished installing requirements into the penv."
else
    echo "... pip install failed! Terminating!"
    exit 1
fi

echo "Ensure that mysql-setup.sh is executable..."
if chmod 755 mysql-setup.sh
then
    echo "... chmod ran successfully"
else
    echo "... chmod failed!"
fi

echo "Running mysql-setup.sh..."
if ./mysql-setup.sh
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Prepare apache2 for pathagar..."
echo "Enable (sudo a2enmod wsgi) the apache2 wsgi module."
if sudo a2enmod wsgi
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Disable (sudo a2dissite 000-default) the"
echo "default apache2 static site..."
if sudo a2dissite 000-default
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Enable (sudo a2ensite ph-site) the pathagar site..."
if sudo a2ensite ph-site
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Check that /var/www/pathagar_media doesn't already exist."
if [ -d /var/www/pathagar_media ]
then
    echo "Something is not right:"
    echo "/var/www/pathagar_media/ already exists!!"
    echo "... Terminating!"
    exit 1
else
    echo "Create (sudo mkdir) /var/www/pathagar_media/ ..."
    if sudo mkdir /var/www/pathagar_media
    then
        echo "... success."
    else
        echo "... failed! Terminating!"
        exit 1
    fi
fi

echo "Change /var/www/pathagar_media ownership to www-data..."
if sudo chown -R www-data:www-data /var/www/pathagar_media
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Restarting apache..."
if sudo service apache2 restart
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Run manage.py syncdb --noinput..."
if python manage.py syncdb --noinput
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Run manage.py collectstatic --noinput..."
if python manage.py collectstatic --noinput
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

## If locale has not been set, creation of superuser will fail!
# The next line returns True if there is no uncommented line in the
# /etc/default/locale file indicating there is no locale.
if  ! grep --invert-match -e ^# /etc/default/locale
then
    echo "It seems locale has NOT been set!"
    echo "We'll try to correct that..."
    LANG="en_US.UTF-8"
    if sudo sh -c 'echo "LANG=\"en_US.UTF-8\"" >> /etc/default/locale'
    then
        echo "    ... successfully added a (en_US.UTF-8) locale"
    else
        echo "    ... Appending the line FAILED!"
        echo "    ... but setting the env var might work."
    fi
fi


echo "Last thing: set up the superuser:"
echo "1. cd into ~/pathagar..."

if cd "${PARENT_DIR}/pathagar"
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "2. source penv/bin/activate..."
# shellcheck disable=SC1091
if source penv/bin/activate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "3. createsuperuser..."
if python manage.py createsuperuser
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "4. deactivate the environment..."
if deactivate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "End pathagar-setup.sh script: $(date)"
