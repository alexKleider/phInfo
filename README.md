---
layout: default
title: Raspberry Pi Content Server
---
# The Raspberry Pi as a Content Server

## Introduction

This directory hierarchy attempts to provide all that is needed
(information and support files) to make a `Rasbperry Pi` into a
content server running a static content site as well as a
`Pathagar Book Server` suitable for classroom or library use.
Since `Raspbian`, the default `Raspberry Pi` `OS`, is `Debian`
based, these instructions (with modifications discussed in the
text) should be applicable to any other `Debian` based system.

The goal is to end up with a device that provides:

* the Pathagar Book Server, and 
* a static site.

It would not be difficult to add other static sites as well.

## The Process

The process is divided up into the following steps, the first
three of which are specific to the `Raspberry Pi`:

    * Raspberry Pi Acquisition
    * SD Card Preparation
    * Initial RPi Configuration (`raspi-config`)
    * OS Update and Installation of Utilities
    * Server Software Installation
    * Static Content
    * Pathagar Book Server
    * Add Another Static Content Site

### Raspberry Pi

The [Vilros basic starter kit](https://www.amazon.com/Vilros-Raspberry-Basic-Starter-Kit/dp/B01D92SSX6/ref=sr_1_4?s=pc&ie=UTF8&qid=1478455788&sr=1-4&keywords=raspberry+pi)
is recommended since it includes the required power cord, and a
protective case. WiFi is built in to this newer (v3) model
`Raspberry Pi`. The older (v2) model will work but a separate
[USB WiFi dongle](https://www.amazon.com/CanaKit-Raspberry-Wireless-Adapter-Dongle/dp/B00GFAN498/ref=sr_1_1?s=pc&ie=UTF8&qid=1486968857&sr=1-1&keywords=CanaKit+WIFI)
must be added.

### SD Card Preparation

A high capacity Micro SD [Card](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-064G-GN6MA/dp/B010Q588D4/ref=sr_1_1?ie=UTF8&qid=1488675440&sr=8-1&keywords=64+gig+micro+sd+card)
is recommended<sup>[1](#1sdcard)</sup> and **RASPBIAN JESSIE LITE** 
is the recommended 
[image](https://www.raspberrypi.org/downloads/raspbian/)
to use.  While at the
``raspbian`` download site, it would be a good idea to make
a copy of the ``sha1sum`` shown below the ``Download ZIP`` button.
If you don't know the concept of a ``checksum`` or ``hash`` then
you could forget all about this without much risk of endangering
your project. 

The following assumes you have a micro SD card as well as a card
reader which will work with your GNU/Linux computer. An Apple will
probably work the same but if your OS is by MicroSoft, you'll have
to look for instructions on the internet.

Unequivocally establish the `device name` your computer assigns
to the SD card and then unmount any of the possibly automounted
volumes associated with this device. (A google search will
provide further information on how to do this.) We'll assume the
device is `/dev/sdb`; substitute as appropriate.  Getting this wrong
can be hazardous!!

Change into a directory where the image can be downloaded and then
unzipped.  It can eventually be deleted from your personal machine
so which directory you use doesn't much matter.

        cd <directory_of_choice>
        wget https://downloads.raspberrypi.org/raspbian_lite_latest
        mv raspbian_lite_latest raspbian_lite_latest.zip

If you know about ``sha1sum`` this would be the time to check that the
one you copied from the ``raspbian`` download page matches the output
of the following command:

        sha1sum raspbian_lite_latest.zip

Assuming the ``checksum`` checks out (or you aren't bothering with
it) and after you are positive that your SD card is mounted at
`/dev/sdb` or what ever device name you specify in its place,
continue with the following commands:

        unzip raspbian_lite_latest.zip
        sudo dd if=raspbian_lite_latest.img of=/dev/sdb bs=4M
        sudo sync

Note that the file's suffix is `.zip` in the first and `.img`
in the second of the above two commands.

Now your SD card is ready for your Raspberry Pi. You can safely 
delete the raspbian image from your personal machine if you wish:

        rm raspbian_lite_latest.img

### Initial RPi Configuration (`raspi-config`)

Be sure the micro SD card is securely inserted and the Raspberry Pi
is connected via ethernet cable to the Internet before powering up.
Log on as user `pi` with password `raspberry` and then run:
        
        raspi-config

As its name implies, this allows you to configure the Pi to suit your
needs.  Here is an outline of what is recommended:

    1. File system expansion (already done.)
    2. Default user is `pi`, I've been changing the pw to `pi::root`
    3. Boot into the command line (My preferred default.)
    4. Internationalization:
        * Default language: en_us.UTF-8  (change from en_gb.UTF-8)
        * Time zone: America, Los_Angeles. (New Pacific)
        * Keyboard: generic 105-key seems to work
            English US
            default
            no compose key
            Control-Alt-Backspace to exit Xwindow
    5. Left in the default state.
    6. Left in the default state.
    7. Left in the default state.
    8. Advanced options:
        * Host name: set to rpi (you choose.)
        * SSH enabled (I believe this is the default.)
        * other options can be ignored.

Once done go ahead and reboot as suggested.

        sudo shutdown -r now


### OS Update and Installation of Utilities

Be sure your platform is connected to the internet and if using a
`Raspberry Pi` be sure it has gone through a reboot after
`raspi-config` was been executed.

After logging on as user `pi`<sup>[2](#2username)</sup>
using your newly set password, clone the relevant
repository<sup>[3](#4reponame)</sup>:

        cd
        git clone https://github.com/alexKleider/phInfo.git

This brings in the `phInfo` file hierarchy containing this
`README` as well as required scripts and files.

        cd phInfo

If using a `Raspberry Pi`:

        sudo ./update.sh

This will take a long time (so be patient!) The script ends
with a reboot.

For other platforms (with no need for network setup):

        sudo ./dependencies.sh

### Server Software Installation

Log on again, `cd` into the project directory (`phInfo`) and then
have a look through the initial comments in `create_server.sh`.
If not using a `Raspberry Pi`, substitute `create_nonPi_server.sh`
for `create_server.sh`.
Once you've finished editing files to suit your own use case,
go ahead and run the `create_server.sh` script (or
`create_nonPi_server.sh` as the case may be.)

        cd phInfo
        # Examine `create_server.sh` and
        # modify the code to suit.
        sudo ./create_server.sh  # or: create_nonPi_server.sh

### Static Content

To add your own static content simply copy the appropriate
`index.html` file together with any other supporting files to the
`/var/www/static/` directory.

If your content is available on an
ext4 formatted USB device with LABEL=Static, (and you haven't 
modified the `create_server.sh` code,) the following will serve 
as a template for the copy command:

        rsync -av /mnt/Static/<dir-containing-content>/ /var/www/static/

Note that the final slash(`/`) at the end of the first parameter to
`rsync` is important (so that only the content, not the directory
itself, gets copied. Presence or absence of the final slash in 
the second paramter is immaterial.)


### Pathagar Book Server

If your system does not have Python 2.7 installed by default (recent
versions of Ubuntu- such as 16.4) you must install it as follows:

        sudo apt-get install python2.7

Once again, log on to your `Raspberry Pi` as user `pi` and issue
the following commands:

        cd
        git clone https://github/pathagarbooks/pathagar.git
        cd pathagar
        virtualenv -p python2.7 penv
        source penv/bin/activate  # `deactivate` when done.
        pip install -r requirements.pip

Choose a database password consisting of alphanumerics, dashes and
underscores but no other special characters. Make a record of it
somewhere so as to be sure not to forget it, and then run the
following commands first substituting your chosen password inside
the single quotes at the end of the first of these commands:

        export MYSQL_PASSWORD='your-chosen-db-password'
        ./set_db_password.sh

A number of commands must be run with root privileges so they
are all bundled into a single script which can be run as
follows:

        sudo ./ph-setup.sh

### Add Another Static Content Site


<div></div>
### FOOTNOTES

<a name="1sdcard">1</a>.
    
    128GB cards are available and are said to work
    in the most recent (v3) models of the `Raspberry
    Pi` but we've not tested this.

<a name="2username">3</a>.

    The scripts assume user name `pi` and that you are cloning the
    `phInfo` repository and `pathagar` into `/home/pi`.  If you decide
    on a different user or use of a different installation directory,
    the scripts will have to be modified accordingly

<a name="3reponame">4</a>.

    The repository name may change in which case all references to
    `phInfo` will need to be changed to `olpcSF` (or what ever it
    becomes.)

