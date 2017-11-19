---
layout: default
title: Raspberry Pi Content Server
---
# The Raspberry Pi as a Content Server

## Introduction

This directory hierarchy attempts to provide all that is needed
(information and support files) to make a `Raspberry Pi` into a
content server running the `Pathagar Book Server` as well as one
or more static content sites suitable for classroom or library use.
Since `Raspbian`, the default `Raspberry Pi` `OS`, is `Debian`
based, these instructions (with modifications discussed in the
text) should be applicable to any other `Debian` based system.

The goal is to end up with a device that provides:

* the Pathagar Book Server, and 
* one or more static sites.

## Terminology

In the text that follows it's important that the reader is clear
about which computer is being used and for what purpose.

The `Raspberry Pi` (or any other `Debian` based machine that you
may be trying to configure) will be refered to as your `target`
machine.  Your laptop or other (preferably Linux) computer (it
could even be another `Raspberry Pi`) will be refered to as your
`staging` machine.  It will be assumed that your `staging` machine
will have `Linux` as its operating system. There's a good chance
that an Apple (running OSX) will work the same (not tested) but
if your OS is by `MicroSoft`, you'll have to look for instruction
elsewhere.


## The Process

The process is divided up into the following steps, the first
three of which are specific to the `Raspberry Pi`. The Network Setup
step is also very specific to the hardware of the `Raspberry Pi`.
If using a different target machine you'll have to modify
considerably.

    * Raspberry Pi Acquisition
    * SD Card Preparation
    * Configuring (`raspi-config`) and Upgrading the Pi
    * Preparation of the Staging Machine
    * Log on to the Target Machine
    * Installation of Utilities
    * Network Setup
    * Bring in Dependencies
    * Server Setup
    * Pathagar Book Server
    * Static Content
    * Add Another Static Content Site

### Raspberry Pi

The [Vilros basic starter kit](https://www.amazon.com/Vilros-Raspberry-Basic-Starter-Kit/dp/B01D92SSX6/ref=sr_1_4?s=pc&ie=UTF8&qid=1478455788&sr=1-4&keywords=raspberry+pi)
is recommended since it includes the required power cord, and a
protective case. WiFi is built in to this newer (v3) model
`Raspberry Pi`. The older (v2) model will work but a separate
[USB WiFi dongle](https://www.amazon.com/CanaKit-Raspberry-Wireless-Adapter-Dongle/dp/B00GFAN498/ref=sr_1_1?s=pc&ie=UTF8&qid=1486968857&sr=1-1&keywords=CanaKit+WIFI)
must be added.

### SD Card Preparation

Since the goal is to set up a content server, and since the
capacity of your SD Card will dictate the amount of content
it's possible to provide, choose an SD Card of comensurate
capacity<sup>[1](#1sdcard)</sup>. The following products have
been used successfully:
[64GB](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-064G-GN6MA/dp/B010Q588D4/ref=sr_1_1?ie=UTF8&qid=1488675440&sr=8-1&keywords=64+gig+micro+sd+card)
and
[128GB](https://www.amazon.com/gp/product/B06XWZWYVP/ref=oh_aui_detailpage_o02_s00?ie=UTF8&psc=1).
We've heard that the following
[128GB card](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-128G-GN6MA/dp/B010Q57S62/)
will also function properly.


Use the browser on your staging machine to find **RASPBIAN**
[here](https://www.raspberrypi.org/downloads/raspbian/)
<sup>[5](#5oldraspian)</sup>.
Pick the **LITE** (not **DESKTOP**) version.  If you know
about `Torrent`, by all means use it; otherwise just click 
on the `Download ZIP` button and your browser will download
the zip file.  Where it will end up depends on your browser's
settings.  `~/Downloads` would be the logical place for it to
end up.  The download process may take a long time. Be sure it
has completed before going on. If a listing of your `~/Download`
directory contains a file ending in `.zip.part`, then the
download is NOT yet complete.

While at the ``raspbian`` download site, it would be a
good idea to make a copy of the ``SHA-256`` checksum shown below
the ``Download ZIP`` button.

Change into your `Downloads` directory where you will find the
zip file that's been downloaded.  Enter the following commands:

        cd ~/Downloads
        ls -lA

... and expect to see output which includes a line that looks 
like the following:

-rw-rw-r-- 1 user user  362914661 Nov 12 09:49 2017-09-07-raspbian-stretch-lite.zip

The name of the zip file will reflect version updates so may not
be the same.  Substitute the name you get for the one shown above.

        
        sha1sum 2017-09-07-raspbian-stretch-lite.zip

The output should match the ``SHA-256`` checksum you copied from the
download page.

Next, unzip the file:

        unzip 2017-09-07-raspbian-stretch-lite.zip

This results in the appearance of another file named the same but
without the ending ".zip".

The challenge now is to unequivocally establish the `device name`
your computer assigns to the SD card and then unmount any of the
possibly auto-mounted volumes associated with this device. One way
of doing this is to run the following command twice, the first time
before and the second time after inserting your SD card into your 
staging machine's card reader (or an external USB attached reader.)
The line(s) (there may be more than one) that appear at the end of
the second output that weren't there at the end of the first hold
the key information.  In my case the beginning of such a (very long)
line (that spills over) is

        /dev/sdb1 on /media/alex/6330-3266 type vfat ....

The device name is the first part without the trailing number,
specifically `/dev/sdb`.  On your staging machine it could be 
something else.  Also note how many such lines there are; you
might find `/dev/sdb2`, possible `/dev/sdb3` and so on.

For each of these issue the following command

        umount /dev/sdb1
        umount /dev/sdb2
        # etc....

until all are unmounted.

So we'll assume the device is `/dev/sdb`; substitute as appropriate. 
Getting this wrong can be hazardous!!

        sudo dd if='2017-09-07-raspbian-stretch-lite.img' of=/dev/sdb bs=4M
        sudo sync

Now the SD card is ready for your target machine and, if you wish,
the raspbian image (both the `zip` file and the `img` file) can be
deleted from your staging machine.
        

### Configuring (`raspi-config`) and Upgrading the Pi

Unfortunately `raspbian` is not shipped with the `ssh server` active
by default and for this reason the target `Pi` must be run the first
time with a screen and keyboard attached.  Be sure the micro SD card
is securely inserted and that you have an ethernet cable connecting
the `Pi` to your your local network and through it to the Internet.

At the beginning of power up you'll briefly see a message that
the root file system is being resized.  Log on as user `pi` with
password `raspberry` and then run:
        
        sudo raspi-config

As its name implies, `raspi-config` is an interactive utility
providing access to the Pi's configuration.
Make selections by using the up and down arrow keys
and once your choice is highlighted, use the left and right arrow
keys to pick `<Select>` (or `<Finish>`).  Here is an outline of what
is recommended or appropriate for our use case:

    1. Change user password: I've been changing the pw to `pi::root` 
    2. Hostname: I suggest `rpi` or `pi-1` (something short)
    3. Boot options:
        We are not installing a GUI so select B1 (boot into the
        command line interface) following which you will be given
        another list of options and again select B1 (log in
        required.)
    4. Localization Options:
        11 Change Locale: The default is `en_gb.UTF-8`: suitable
            for Great Britain.  For the American locale, scroll down
            (with the down arrow) until encountering the asterix (*)
            next to `en_gb.UTF-8`, toggle with the space bar, and
            then continue scrolling down until coming to
            `en_us.UTF-8`.  Toggle with the space bar again so the
            asterix appears. Here the behaviour of the interface is
            a bit different: the `Enter` key moves you forward to
            the next panel where you again use the down arrow
            to land on `en_us.UTF-8`.  Use the right arrow and then
            `Enter` over the `<Ok>`.
        Choose option 4 again.
        12 Change Time Zone: US, New Pacific
        13 Change Keyboard Layout: 
            Since our goal is to run the `Pi` 'headless',
            I don't think changing any of this is necessary but if you
            do expect to be using a keyboard the following is
            suggested:
            generic 105-key (the default) seems to work
            I chose `Other` rather than the default
            (`English (UK)') and then select 'English (US)'
            There's no reason to change any of the remaining
            defaults.
    5. Interfacing Options:
        Only the second option is relevant to us:
        P2 SSH: Enable ssh server
        Be sure to select <Yes>, this is very important.
    6. Overclock: Left in the default state.
    7. Advanced options:
        A1 Expand file system: This is also very important.
        None of the other advance options concern us.
    8. Update this tool to latest version
        Optional: depends on internet connectivity
    9. About raspi-config
        Nothing important here.

After `raspi-config` completes, the `Pi` should be rebooted.
After a few minutes to give it time to come back up again, log
back on as user `pi` but this time you'll have to use your newly
set password (`pi::root`.)  Then do an update, upgrade, and a dist-upgrade.  These
commands take a long time!  When done, the `Pi` should be shut
down.

        sudo apt-get --fix-missing update
        sudo apt -y --fix-missing upgrade
        sudo apt -y --fix-missing dist-upgrade
        sudo shutdown -h now

Now you can disconnect the `Pi` from it's key board and monitor.

### Preparation of the Staging Machine

Make sure the **target** machine is connected (via ethernet cable)
to the internet and is powered up.  (If you are using an external
wifi dongle it should be installed before power up.)

From the command line of your **staging** machine, issue the
following commands:
        
        cd
        sudo apt-get install git arp-scan
        git clone https://github.com/alexKleider/phInfo.git
        cd phInfo 

The next challenge is to discover the IP address of the target
machine.  The utility `find_pi.py` (now within the current file
structure on the staging machine) is provided for this purpose.
Before using it, you will want to open it in your favourite editor
and possibly change the one or two constants to suit your network.
The file is well commented to help guide you.

        python find_pi.py


### Log on to the Target Machine

Still using the command line of your staging machine,
once you know the IP address of your target machine
(output of the find_pi.py script) proceed with the following:

        ssh pi@<target-ip-adr>

Respond to the prompt with pi's password ('pi::root') and with
any luck you will now be logged onto the target machine (running it
'headless'.)

You will have to repeat this process
each time the target machine goes through a
reboot<sup>[6](#6screenfreeze)</sup>
or after you log off.

All subsequent instructions assume that you are logged onto the
target machine using the ssh client on your staging machine.

### Installation of Utilities

The following sequence of commands ensures that you are in the
current user's home directory (`/home/pi`,) installs `git` and
then clones the phInfo repository<sup>[4](#4reponame)</sup>:

        cd
        sudo apt-get -y install git 
        git clone https://github.com/alexKleider/phInfo.git
        cd phInfo

This brings in the `phInfo` file hierarchy containing this
`README` as well as required scripts and files. The final
command puts you into that (`phInfo`) directory.

There are a number of utilities and customizations that are not
essential but I find them useful to have so my practice is to
also run the following script:

        ./favourites.sh


##### Network Setup

Network configuration is dependent on the target machine's
hardware.  These instructions assume that there is an ethernet
(eth0) port and either a built in wifi or a usb wifi dongle as
is true for the Raspberry Pi. The scripts used will most
certainly have to be modified if this is not your use case.

Configuration is done by commands in the networking.sh and the
iptables.sh scripts. There must be a reboot between the two
<sup>[6](#6screenfreeze)</sup>.
Before beginning have a look through the initial comments in
`networking.sh`; you may want to edit some of the files mentioned.

        # Edit networking.sh
        ./networking.sh
        # Wait a few minutes for the reboot before loging on again.
        cd phInfo
        ./iptables.sh

The last command also ends with a reboot. Remember that after each
reboot you'll have to use your staging machine to log back on to the
target machine<sup>[6](#6screenfreeze)</sup>.


##### Bring in dependencies

The next script contains two install commands, one of which is
expected to fail with a message along the lines of "E: Package
'libmysqlclient-dev' has no installation candidate".  If you are
curious, edit the file and read the comments; otherwise just procede.
Expect the script to take a long time (so be patient!)

        cd phInfo
        ./dependencies.sh

### Server Setup

Log on again, `cd` into the project directory (`phInfo`) and then
have a look through the initial comments in `create-server.sh`.
Once you've finished editing to suit your own use case,
go ahead and run the script:

        cd phInfo
        # edit create-server.sh
        ./create-server.sh

Wait for a few minutes for your server (in my case it's the `Pi`) to
reboot and then test by connecting your wifi to the server. Once your
machine is connected to the server's wifi access point, pointing
your browser to `library.lan` should take you to the pathagar home
page.  Pointing to `rachel.lan` should take you to the static content.

### Pathagar Book Server

Choose a database password consisting of alphanumerics, dashes and
underscores but no other special characters. Make a record of it
somewhere so as to be sure not to forget it. Then log on to your
`Raspberry Pi` as user `pi` and run the following command after
first substituting your chosen password inside the single quotes:

        export MYSQL_PASSWORD='db-password'

You will also later need a pathagar superuser password so now would
be a good time to pick one and record it somewhere.  I suggest
'ph-su-pw'.

The next sequence of commands brings in Pathagar, carries out
necessary configurations, activates the virtual environment so that
a superuser can be created and then deactivates the environment since
if all goes well you won't need it any longer.  Django arranges for
its activation when needed.  The `pip install -r requirements.pip`
command in `pathagar-setup.sh` takes a very long time so be patient.

        cd ~/phInfo
        ./pathagar-setup.sh
        cd ~/pathagar

There remains to set a pathagar superuser password. Pick a
password ('pi::superuser' for example, make a note of it
so as not to forget,) then proceed with the following:

        cd ~/phInfo
        source penv/bin/activate
        python manage.py createsuperuser
        deactivate

##### Adding Content

Consult the README file in the `pathagar` directory/repository for
instructions how to load books (and other library content) once
the pathagar server is running.

##### Before Final Deployment

Once everything is working as it should, before putting your
server into service, edit `/home/pi/pathagar/localsettings.py`.
Change `DEBUG = True` to `DEBUG = False`.
You will probably also want to change the value of 
`TIME_ZONE = 'America/Los_Angeles'`
Look at `/usr/share/zoneinfo` on any Linux system for guidance as
to how to specify your particular zone.


### Static Content

To add your own static content simply copy the appropriate
`index.html` file together with any other supporting files to the
`/var/www/static/` directory, thus replacing the test page.

If your content is available on an ext4 formatted USB device with
LABEL=Static, (and you haven't modified the `create-server.sh` code,)
the following will serve as a template for the copy command:

        rsync -av /mnt/Static/<dir-containing-content>/ /var/www/static/

Note that the final slash(`/`) at the end of the first parameter to
`rsync` is important (so that only the content, not the directory
itself, gets copied. Presence or absence of the final slash in 
the second parameter is immaterial.)

If your content is at the top level of the medium you've mounted
(rather than inside its own directory) then change the command to
the following:

        rsync -av /mnt/Static/* /var/www/static/

If your server is the `Raspberry Pi` set up as described here,
then entering "rachel.lan" in the URL window of a browser running
on a wifi client machine will result in your content being displayed.


### Add Another Static Content Site

Still need to document this.


<div></div>
### FOOTNOTES

<a name="1sdcard">1</a>.
    
    If using a version 2 (or earlier) Pi, you are limited to
    at most a 64GB card.
    Version 3 (or later?) `Raspberry Pi`s require a micro SD
    card.  Some 128GB cards can be used but many sold on the market do
    not work! 


<a name="2arpscan">2</a>.

    There are various methods of discovering the IP address of the
    `Raspberry Pi`.  Use of the `arp-scan` utility is one.  The
    included `find_pi.py` script uses `arp-scan` and might be useful
    to you but it will have to be customized to suit your own network
    and the devices you own.  Edit `find_pi.py` and read its docstring
    for further details.

<a name="3username">3</a>.

    The scripts assume user name `pi` and that you are cloning the
    `phInfo` repository and `pathagar` into `/home/pi`.  If you decide
    on a different user or use of a different installation directory,
    the scripts will have to be modified accordingly

<a name="4reponame">4</a>.

    The repository name may change in which case all references to
    `phInfo` will need to be changed.

<a name="5oldraspian">5</a>

Older versions of raspian can be found 
[here](http://downloads.raspberrypi.org/raspbian_lite/images/).

<a name="6screenfreeze">6</a>

When using SSH, following a shutdown or a reboot, the client
teminal sometimes freezes.  This can be remedied with the
following 3 key strokes: Enter (the `Enter key`), tilde (`~`),
period (`.`).
