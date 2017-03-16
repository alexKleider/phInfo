---
layout: default
title: Raspberry Pi Content Server
---
# The Raspberry Pi as a Content Server

## Introduction

This directory hierarchy attempts to provide all that is needed
(information and support files) to make a `Rasbperry Pi` into a
content server running a static content site as well as a Pathagar
book server suitable for classroom or library use.
Since raspbian, the default Raspberry Pi OS, is Debian based,
these instructions (other than the first three sections)
should be applicable to any Debian based system.

The goal is to end up with a device that provides:

* the Pathagar Book server, and 
* a static site.

It would not be difficult to add other static sites as well.

## The Process

The process is divided up into the following steps:

    * Raspberry Pi
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
protective case. WiFi is built in to this newer (v3) model. The
older (v2) model will work but a separate [USB WiFi
dongle](https://www.amazon.com/CanaKit-Raspberry-Wireless-Adapter-Dongle/dp/B00GFAN498/ref=sr_1_1?s=pc&ie=UTF8&qid=1486968857&sr=1-1&keywords=CanaKit+WIFI) will be needed.

### SD Card Preparation

A high capacity Micro SD [Card](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-064G-GN6MA/dp/B010Q588D4/ref=sr_1_1?ie=UTF8&qid=1488675440&sr=8-1&keywords=64+gig+micro+sd+card)<sup>[1](#1sdcard)</sup> with the **RASPBIAN JESSIE LITE** 
[image](https://www.raspberrypi.org/downloads/raspbian/)
are recommended. While at the ``raspbian`` download site, it would be
a good idea to make a copy of the ``sha1sum`` shown below the
``Download ZIP`` button.  If you don't know the concept of a
``checksum`` or ``hash`` then you could forget all about this without
much risk of endangering your project. 

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

Decide on 
    
    * where you want your project to reside, and
    * a name for your project directory.
    
The following instructions will assume you've
chosen your home directory and `phInfo` respectively.

        cd
        mkdir phInfo
        wget https://downloads.raspberrypi.org/raspbian_lite_latest
        mv raspbian_lite_latest raspbian_lite_latest.zip

Current release notes (as of spring 2017) is provided in the foot
notes<sup>[2](#2releasenotes)</sup>.
If you know about ``sha1sum`` this would be the time to check that the
one you copied from the ``raspbian`` download page matches the output
of the following command:

        sha1sum raspbian_lite_latest.zip

Assuming the ``checksum`` checks out (or you aren't bothering with it)
continue with the following commands:

        unzip raspbian_lite_latest.zip
        sudo dd if=raspbian_lite_latest.zip of=/dev/sdb bs=4M
        sudo sync

Note that the file's suffix is `.zip` in the first and `.img`
in the second of the above two commands.

Now your SD card is ready for your Raspberry Pi.

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

Be sure your `Raspberry Pi` remains connected to the internet and
has gone through a reboot since `raspi-config` has been executed.

After logging on as user `pi` using your newly set password,
clone the relevant repository<sup>[3](#3reponame)</sup>:

        cd
        git clone https://github.com/alexKleider/phInfo.git

This brings in the `phInfo` file hierarchy containing this
`README` as well as required scripts and files.

        cd phInfo
        sudo su
        source update.sh

This will take a long time (so be patient!) after which the 
`Raspberry Pi` will go through a reboot.

### Server Software Installation

Log on again, `cd` into the project directory (`phInfo`) and then
have a look through the initial comments in `create_server.sh`.
Once you've finished editing files to suit your own use case,
go ahead and `source create_server.sh`.

        cd phInfo
        # Examine `create_server.sh` and
        # modify the code to suit.
        sudo su
        source create_server.sh

### Static Content

To add your own static content simply copy the appropriate
`index.html` file together with any other supporting files to the
`/var/www/static/` directory.

If your content is available on an
ext4 formatted USB device with LABEL=Static, (and you haven't 
modified the `create-server.sh` code,) the following will serve 
as a template for the copy command:

        rsync -av /mnt/Static/<dir-containing-content>/ /var/www/static/

Note that the final slash(`/`) at the end of the first parameter to
`rsync` is important (so that only the content, not the directory
itself, gets copied. Presence or absence of the final slash in 
the second paramter is immaterial.)


### Pathagar Book Server

Once again log on to you `Raspberry Pi` as user `pi` and issue the
following commands:

        cd
        git clone https://github/pathagarbooks/pathagar.git
        cd pathagar
        virtualenv -p python2.7 penv
        source penv/bin/activate  # `deactivate` when done.
        pip install -r requirements.pip
        cp ~/phInfo/local_settings.py ~/pathagar/

The last of the above commands serves to customize
settings.<sup>[4](#4settings)</sup>

### Add Another Static Content Site


<div></div>
### FOOTNOTES

<a name="1sdcard">1</a>.
    
    >128GB cards are available and are said
    to work in the most recent models of the Raspberry Pi but
    we've not tested this.

<a name="2releasenotes">2</a>.

    >Raspbian Release Notes:

    2017-03-02:

      * Updated kernel and firmware (final Pi Zero W support)
      * Wolfram Mathematica updated to version 11
      * NOOBS installs now checks for presence of 'ssh' file on the NOOBS
        partition

    2017-02-16:

      * Chromium browser updated to version 56
      * Adobe Flash Player updated to version 24.0.0.221
      * RealVNC Server and Viewer updated to version 6.0.2 (RealVNC
        Connect)
      * Sonic Pi updated to version 2.11
      * Node-RED updated to version 0.15.3
      * Scratch updated to version 120117  * Detection of SSH enabled with
    default password moved into PAM
      * Updated desktop GL driver to support use of fake KMS option
      * Raspberry Pi Configuration and raspi-config allow setting of fixed

    HDMI resolution

      * raspi-config allows enabling of serial hardware independent of

    serial terminal

      * Updates to kernel and firmware
      * Various minor bug fixes and usability and appearance tweaks

    2017-01-11:

      * Re-release of the 2016-11-25 image with a FAT32-formatted boot
        partition

    2016-11-25:

      * SSH disabled by default; can be enabled by creating a file with
    name "ssh" in boot partition
      * Prompt for password change at boot when SSH enabled with default
    password unchanged
      * ...

<a name="3reponame">3</a>.

    The repository name may change in which case all references to
    `phInfo` will need to be changed to `olpcSF` (or what ever it
    becomes.)

<a name="4settings">4</a>.

    > Bringing in the `local_settings.py` file saves us from having to
    > perform the following edits of the `settings.py` file:

            Preface the static directory
            with '/library':
            STATIC_URL = '/library/static/'
            and add two lines:
            FORCE_SCRIPT_NAME = '/library'
            LOGIN_REDIRECT_URL = FORCE_SCRIPT_NAME

