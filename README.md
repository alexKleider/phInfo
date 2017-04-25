---
layout: default
title: Raspberry Pi Content Server
---
# The Raspberry Pi as a Content Server

## Introduction

This directory hierarchy attempts to provide all that is needed
(information and support files) to make a `Raspberry Pi` into a
content server running a static content site as well as a
`Pathagar Book Server` suitable for classroom or library use.
Since `Raspbian`, the default `Raspberry Pi` `OS`, is `Debian`
based, these instructions (with modifications discussed in the
text) should be applicable to any other `Debian` based system.

The goal is to end up with a device that provides:

* the Pathagar Book Server, and 
* one or more static sites.

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
to use.  While at the ``raspbian`` download site, it would be a
good idea to make a copy of the ``sha1sum`` shown below the
``Download ZIP`` button.  If you don't know the concept of a
``checksum`` or ``hash`` then you could forget all about this
without much risk of endangering your project. 

The following assumes you have a micro SD card as well as a card
reader which will work with your GNU/Linux computer. An Apple will
probably work the same but if your OS is by MicroSoft, you'll have
to look for instructions on the internet.

Unequivocally establish the `device name` your computer assigns
to the SD card and then unmount any of the possibly auto-mounted
volumes associated with this device. (A google search will
provide further information on how to do this.) We'll assume the
device is `/dev/sdb`; substitute as appropriate.  Getting this wrong
can be hazardous!!

Change into a directory where the image can be downloaded and then
unzipped.  It can eventually be deleted from your personal machine
so which directory you use doesn't much matter. Creating a new
empty directory for this purpose might make things less confusing.

        mkdir <newly_created_dirctory>
        cd <newly_created_dirctory>
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
        sudo dd if='-raspbian-jessie-lite.img' of=/dev/sdb bs=4M
        sudo sync

Now your SD card is ready for your Raspberry Pi. You can safely 
delete the raspbian image from your personal machine if you wish.

        rm -rf <newly_created_dirctory>

### Initial RPi Configuration (`raspi-config`)

Unfortunately `raspbian` is not shipped with the `ssh server` active
by default and for this reason the `Pi` must be run the first time
with a screen and keyboard attached.
Be sure the micro SD card is securely inserted and the Raspberry Pi
is connected via Ethernet cable to the Internet before powering up.
Log on as user `pi` with password `raspberry` and then run:
        
        raspi-config

As its name implies, this allows you to configure the Pi to suit your
needs.  Here is an outline of what is recommended or appropriate for
my use case:

    1. Change user password: I've been changing the pw to `pi::root` 
    2. Hostname: I suggest `rpi` (something short)
    3. Boot options:
        I suggest B1 (or B2)- -> Console
    4. Localization Options:
        11 Change Local: en_us.UTF-8  (change from en_gb.UTF-8)
            (The space bar toggles the selection asterix.)
        12 Time zone: US, New Pacific
        13 Keyboard: generic 105-key seems to work
            English US
            default
            no compose key
    5. Interfacing:
        P2 SSH: Enable ssh server
    6. Overclock: Left in the default state.
    7. Advanced options:
        * SSH: Enable ssh server (unfortunately NOT the default)
        * Expand file system
        * other options can be ignored.
    8. Update this tool to latest version
        Optional: depends on internet connectivity
    9. About raspi-config

Once done go ahead and shutdown:

        sudo shutdown -r now

Since its `SSH Server` has been activated, the `Raspberry Pi` can
now be run `headless'.  Be sure it is connected to the internet
and powered up.  Determine its IP address (`arp-scan` is a 
convenient tool for this) and then use your personal computer to
log on remotely:

        ssh pi@<IPAddress>

When using SSH, following a shutdown or a reboot, the client
teminal sometimes freezes up.  This can be remedied with the
following 3 key strokes: Enter (the `Enter key`), tilde (`~`),
period (`.`).


### OS Update and Installation of Utilities

Be sure your platform is connected to the internet and if using a
`Raspberry Pi` be sure it has gone through a reboot after
`raspi-config` was executed.

After logging on as user `pi`<sup>[2](#2username)</sup>
using your newly set password, install `git` and clone the
relevant repository<sup>[3](#4reponame)</sup>:

        cd
        sudo apt-get -y install git 
        git clone https://github.com/alexKleider/phInfo.git

This brings in the `phInfo` file hierarchy containing this
`README` as well as required scripts and files.

        cd phInfo

If using a `Raspberry Pi`:

        sudo ./update.sh

This will take a long time (so be patient!) In the midst of this
update, a screen will appear asking you to set a `MySQL` "root"
password. Leave it blank (I think! Not sure about this yet.) ****
The script ends with a reboot.

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
        vim create_server.sh
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
the second parameter is immaterial.)


### Pathagar Book Server

#### For Non-RPi users:
The `Pathagar Book Server` runs on `Python 2.7`.  Some
platforms are now shipping with `Python 3` as the default
Python so if this is the case, you will need to install
`Python 2.7`. The following command will provide the answer:

        python --version

If the response is not "Python 2.7.?", then you'll need to do some
research as to how to install Python 2.7.  The following might do
it:

        sudo apt-get install python2.7

Again, note that the above does not pertain if you are using
`raspbian` on the `Raspberry Pi`.

#### Setting Up Pathagar:

Choose a database password consisting of alphanumerics, dashes and
underscores but no other special characters. Make a record of it
somewhere so as to be sure not to forget it. Then log on to your
`Raspberry Pi` as user `pi` and run the following command after
first substituting your chosen password inside the single quotes:

        export MYSQL_PASSWORD='your-chosen-db-password'

Next source the following script which brings in Pathagar and
carries out the necessary configurations.  The second last
command in this script takes a very long time to complete.

        ./pathagar-setup.sh

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

