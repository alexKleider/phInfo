#!/bin/bash

# File pip-error.sh

# During a test run, the pathagar-setup.sh script failed during the 
# 'pip intall -r requirements.pip' command.  Running this script
# after the failure solved the poblem: it sets up for, and then
# reruns the command again along with all the other commands that
# follow it in the `pathagar-setup.sh' script.


echo "Change into the ~/pathagar directory..."
if cd ~/pathagar
then
    echo "... successfull."
else
    echo "... failed! Terminating"
fi

echo "Activate the penv..."
if source penv/bin/activate
then
    echo "... success."
else
    echo "... penv activation failed! Terminating!"
    exit 1
fi

echo "Running mysql-setup.sh"
if ./mysql-setup.sh
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Prepare apache2 for pathagar"
echo "Enable (sudo a2enmod wsgi) the apache2 wsgi module."
if sudo a2enmod wsgi
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Disable (sudo a2dissite 000-default) the"
echo "default apache2 static site."
if sudo a2dissite 000-default
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Enable (sudo a2ensite ph-site) the pathagar site."
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

echo "Change /var/www/pathagar_media ownership to www-data"
if sudo chown -R www-data:www-data /var/www/pathagar_media
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Restarting apache"
if sudo service apache2 restart
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Run manage.py syncdb --noinput"
if python manage.py syncdb --noinput
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Run manage.py collectstatic --noinput"
if python manage.py collectstatic --noinput
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "Last thing: set up the superuser:"
echo "1. cd into ~/pathagar:"
if cd ~/pathagar
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "2. source penv/bin/activate:"
if source penv/bin/activate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "3. createsuperuser:"
if python manage.py createsuperuser
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "4. deactivate the environment:"
if deactivate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

