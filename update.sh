# Source this file after installing raspbian and running raspi-config. 

# Last updated Sun Mar  5 16:44:26 PST 2017

echo "updating, upgrading and installing more software....."
# The echo 'q' | part of command below is to overcome the problem
# described in file 'dealwith'.
date && apt-get -y update && echo 'q' | apt-get -y upgrade && date
echo "Just finished updating and upgrading."
apt-get -y install git iw hostapd dnsmasq apache2
date
echo "Just finished installing git, iw, hostapd, dnsmasq, apache2"

# If planning to install Pathagar-  (estimate 3 minites)
apt-get -y install python-pip python-virtualenv
#     if planning to use mysql rather than sqlite3, must
#     circumnavigate missing mysql_config errors and missing
#     libxml/xmlversion.h errors by installing:
apt-get -y install libmysqlclient-dev libxml2-dev libxslt1-dev
apt-get -y install python-dev
date
echo "Just finished installing python-pip,"
echo "..libmysqlclient-dev, libxml2-dev, libxslt1-dev"
echo "..python-virtualenv and python-dev"

# The following are not essential for proper functioning
# of the server but they make my life better.
apt-get -y install vim vim-scripts git dnsutils screen
date
echo "Just finished installing vim, vim-scripts,"
echo "...dnsutils (to bring in dig) & screen."
# The following are only for those who use vim and like my vim defaults.
cp .vimrc /root/
cp .vimrc /home/pi/
echo "Copied my custom .vimrc file to /root/ and to /home/pi/."

echo "  |=========================================|"
echo "  | Update completed- will now do a reboot. |"
echo"   |=========================================|"
shutdown -r now

