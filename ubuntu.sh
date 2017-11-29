#!/bin/bash

set -o errexit
set -o pipefail

set -x

scripts_dir=$(dirname $0)

#pathagar_version="0.8.0"
pathagar_version="master"
pathagar_home=$HOME/pathagar-$pathagar_version

# from dependencies.sh
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 \
  python-pip \
  python-virtualenv \
  python-dev \
  libapache2-mod-wsgi \
  libmysqlclient-dev \
  libxml2-dev \
  libxslt1-dev \
  mysql-server

# configure mysql
"$scripts_dir/set-db-pw.sh"

# pathagar install
if [[ ! -d "$pathagar_home" ]]; then
  (
    cd $(dirname "$pathagar_home")
    # Curl url for version strings
    #curl -s -f -L "https://github.com/PathagarBooks/pathagar/archive/v$pathagar_version.tar.gz" | tar xvz

    # Download and unpack pathagar source
    curl -s -f -L "https://github.com/PathagarBooks/pathagar/archive/$pathagar_version.tar.gz" | tar xvz
  )
fi

# Copy settings
cp "$scripts_dir/local_settings.py" "$pathagar_home/"

# This is a work-around for older versions of django
ln -sf "$pathagar_home" "$pathagar_home/pathagar"

# Setup pathagar
(
  cd "$pathagar_home"
  virtualenv -p python2.7 penv
  source penv/bin/activate
  pip install -r requirements.pip

  echo "Run manage.py syncdb --noinput"
  python manage.py syncdb --noinput
  echo "Run manage.py collectstatic --noinput"
  python manage.py collectstatic --noinput
  # Create the admin user in pathagar
  echo -n -e "pathagar\npathagar\n" | python manage.py createsuperuser --username pathagar --email pathagar@example.com
)

# Configure apache
sudo cp "$scripts_dir/ph-site.conf" /etc/apache2/sites-available/
echo "Enable the apache2 wsgi module.."
sudo a2enmod wsgi
echo "Disable the default apache2 static site."
sudo a2dissite 000-default
echo "Enable the pathagar site."
sudo a2ensite ph-site

sudo mkdir -p /var/www/pathagar_media
echo "Change /var/www/pathagar_media ownership to www-data"
sudo chown -R www-data:www-data /var/www/pathagar_media
echo "Restarting apache"
sudo service apache2 restart
