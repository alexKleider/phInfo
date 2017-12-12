---
layout: default
title: Raspberry Pi Content Server
---
[![CircleCI](https://circleci.com/gh/alexKleider/phInfo.svg?style=svg)](https://circleci.com/gh/alexKleider/phInfo)
# The Raspberry Pi as a Content Server

You can read these instructions by pointing your browser to
https://github.com/alexKleider/phInfo (or
https://github.com/alexKleider/phInfo/tree/$branch-name
if you are testing a branch other than master.)

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

Client machines can connect to the server using
`WiFi`<sup>[11](#11clients)</sup>
and then access content using a browser.


## Terminology

In the text that follows it's important that the reader is clear
about which computer is being used and for what purpose.

The `Raspberry Pi` (or any other `Debian` based machine that you
may be trying to configure to use as a content server) will be
referred to as your `target` machine.  Your laptop or other
(preferably Linux) computer (it could even be another `Raspberry
Pi`) will be referred to as your `staging` machine. A `client`
machine is any Wifi enabled machine providing its user with a
browser. The the whole purpose of this project is to provide
content for clients.  It will be assumed that your `staging`
machine will have `Linux` as its operating system. There's a
good chance that an Apple (running OSX) will also work (not
tested) but if your OS is by `MicroSoft`, you'll have to look
for instruction elsewhere.


## The Process

The process is divided up into the following steps.
Some are specific for the `Raspberry Pi`. These include 
the first two and the 4th.
The 6th (Configuring ...,)  7th (Updating ...)( and the 9th
(Network ...) are also specific to the `Raspberry Pi` but if
you are using some other target machine, these same instructions
could probably be fairly easily adapted.  Updating and Upgrading
(the 7th item) might work as is since pretty standard `Debian`
commands are used; Network Setup (item 9) will almost certainly differ.  
Look over the code and modify to suit your use case.

1.  Raspberry Pi Acquisition
1.  SD Card Preparation (RASPBIAN-LITE)
1.  Staging Machine Preparation
4.  IP Address Discovery
1.  Log on to the Target Machine
6.  Configuring (`raspi-config`) the Pi
7.  Updating and Upgrading the Raspberry Pi
1.  Installation of Utilities (Bring in the Repository)
9.  Network Setup  (Specific to Pi's hardware)
1.  Bring in Dependencies
1.  Server Setup
1.  Pathagar Book Server
1.  Static Content
1.  Add Another Static Content Site

Sensible defaults are chosen for everything so if using a `Raspberry
Pi`, there'll be no necessity to modify anything.


#### For the Advanced User

Some (`advanced`) users may need (or just wish) to change some or
all of the defaults. This can be done by changing assignments in
the `config` file found in the/this `phInfo` repository.  Once
modified, it must be `source`d on the target machine each time you
log on and before any of the configuring commands are run.  This
complicates things considerably so beware.

The rest of this `README` contains segments to help in this regard;
each of these segments will be designated `AdvUsr` so it will be
easy to see what is only relevant to the `admanced user` and can
be ignored by those happy to accept the built in defaults.


### Raspberry Pi Acquisition

The [Vilros basic starter kit](https://www.amazon.com/Vilros-Raspberry-Basic-Starter-Kit/dp/B01D92SSX6/ref=sr_1_4?s=pc&ie=UTF8&qid=1478455788&sr=1-4&keywords=raspberry+pi)
is recommended since it includes the required power cord, and a
protective case<sup>[9](#9cooling)</sup>. WiFi is built in to this newer (v3) model
`Raspberry Pi`. The older (v2) model will work but a separate
[USB WiFi dongle](https://www.amazon.com/CanaKit-Raspberry-Wireless-Adapter-Dongle/dp/B00GFAN498/ref=sr_1_1?s=pc&ie=UTF8&qid=1486968857&sr=1-1&keywords=CanaKit+WIFI)
must be added.

### SD Card Preparation

Since the goal is to set up a content server, and since the
capacity of your SD Card will dictate the amount of content
it's possible to provide, choose an SD Card of commensurate
capacity<sup>[1](#1sdcard)</sup>. In general, 'more is better.'
The following products have been used successfully:
[64GB](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-064G-GN6MA/dp/B010Q588D4/ref=sr_1_1?ie=UTF8&qid=1488675440&sr=8-1&keywords=64+gig+micro+sd+card)
and
[128GB](https://www.amazon.com/gp/product/B06XWZWYVP/ref=oh_aui_detailpage_o02_s00?ie=UTF8&psc=1).
We've heard that the following
[128GB card](https://www.amazon.com/SanDisk-microSDXC-Standard-Packaging-SDSQUNC-128G-GN6MA/dp/B010Q57S62/)
will also function properly.

As mentioned, this guide assumes that you are using Linux on your
staging machine.  Microsoft Windows users might find this
[link](https://hackernoon.com/raspberry-pi-headless-install-462ccabd75d0)
useful.

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
good idea to make a copy of the ``SHA-256`` check-sum shown below
the ``Download ZIP`` button.

The remainder of this section involves use of the command line
on your staging machine.

Change into your `Downloads` directory: the directory into which
the zip file was downloaded.  Double check again that none of the
files in that directory end in `.zip.part` and then enter the
following commands substituting the directory name if your
download went else where:

        cd ~/Downloads
        ls -lA

... and expect to see output which includes a line that looks 
like the following:

`-rw-rw-r-- 1 user user  362914661 Dec  2 15:52 2017-11-29-raspbian-stretch-lite.zip`

The name of the zip file will reflect version updates so may not
be the same.  Substitute the name you get for the one shown above.

        
        sha256sum 2017-11-29-raspbian-stretch-lite.zip

The output should match the ``SHA-256`` check-sum you copied from the
download page.

Next, unzip the file:

        unzip 2017-11-29-raspbian-stretch-lite.zip

This results in the appearance of another file named the same but
without the trailing ".zip".

The challenge now is to unequivocally establish the `device name`
your computer assigns to the SD card so that you can first unmount
any of the possibly auto-mounted volumes associated with this device
and then copy the raspbian image to this device.  Each device might
contain one or more volumes, each designated by appending a digit to
the device name.

The safest way to discover the device name is to run the `mount`
command:

        mount

... once before inserting the SD card into your staging machine's
card reader, and then again after doing so.  The second time you
run the mount command, there will be one or more new lines that
weren't there before.  Each of these lines begin with a volume name.
Ignoring the ending digit of one of these volume names provides you
with the device name.  In my case, the beginning of such a (very
long) line (that spills over) is

        /dev/sdb1 on /media/alex/6330-3266 type vfat ....

So on my staging machine the device name is `/dev/sdb`.
Make a note of this device (what ever it is on your staging machine.)
You will need to know it latter.  Also note how many such lines there
are; that is to say, how many `volumes` are listed, each differing
by the digit appended to the device name.

For each volume name, issue the following command:

        umount /dev/sdb1
        umount /dev/sdb2
        # etc....

until all are unmounted.

So we'll assume the device is `/dev/sdb`; substitute as appropriate. 
Getting this wrong can be hazardous!!  Making the appropriate
substitutions as necessary, run the next command (which took 10
minutes to complete on my staging machine):

        sudo dd if='2017-11-29-raspbian-stretch-lite.img' of=/dev/sdb bs=4M && sudo sync

Be absolutely sure the command has completed before going on.

Unfortunately `raspbian` is not shipped with the `ssh server` active
by default.  It's possible to overcome this problem by continuing
with the following commands, again substituting your `device name`
with the digit `1` appended to it to make it a `volume name`:

        sudo mount /dev/sdb1 /media 
        sudo touch /media/ssh
        sudo sync
        sudo umount /dev/sdb1

Now the SD card is ready for your target machine and, if you wish,
the raspbian image (both the `zip` file and the `img` file) can be
deleted from the `Downloads` directory of your staging machine.

Be sure the micro SD card is securely inserted into the `Raspberry
Pi`  and that you have an Ethernet cable connecting the `Pi` to your
local network (and through it to the Internet.) If using an external
(USB connected) WiFi dongle, make sure it is also installed.
Now power up the `Pi`.
        

### Staging Machine Preparation

This is an optional section and pertains only if you fall into
one or more of the following three categories:

1. An advanced user who wants to override defaults.

2. Some one testing a branch other than `master`.

3. Some one who needs a way of discovering the target machine's
IP address. (This does NOT apply if your target machine is other
than a `Raspberry Pi`.)

Of the next set of commands, the first and last are not required
unless you are in category `2` in which case substitute the name
of the branch you wish to test for the word `master`.

From the command line of your **staging** machine, issue the
following commands:
        
        export BRANCH=master

        cd
        sudo apt-get install git arp-scan
        git clone https://github.com/alexKleider/phInfo.git
        cd phInfo 

        git checkout $BRANCH

It is now that the advanced user can edit the `config` file
found in the current directory.  It is heavily commented so
should be self explanatory.


### IP Address Discovery

Make sure the **target** machine is connected (via Ethernet cable)
to the internet and is powered up.  (If you are using an external
WiFi dongle it should be installed before power up.)

The challenge now is to discover the IP address of the target
machine.  The Unix arp-scan utility before and again after powering
up the target machine will likely work.  Look for an IP address
that appears only after the target power up, not before.

If you put yourself in category `3` (see previous section) then
the utility `find_pi.py` can be found within your current
directory on the staging machine.  Before using it, you will want
to open it in your favourite editor and possibly change the one or
two constants to suit your network.  The file is well commented to
help guide you.

        python find_pi.py

The output will look something like this:

        Probable Pi IP(s):
            192.168.0.11


### Log on to the Target Machine

To log on to the target machine you will have to know the appropriate
user's name and password as well as the target's IP address.  For the
`Pi`, the user name is `pi` and the password is `raspberry`.  Still
using the command line of your staging machine, proceed with the
following command, substituting the user name and the IP address as
appropriate<sup>[7](#7nasty)</sup>:

        ssh pi@<target-ip-adr>

Before being asked for a password, you may be warned about host
authenticity.  Simply do what is requested.  In the extreme case
you might have to delete one of the lines in your
`~/.ssh/known_hosts` file. It is quite safe to do so.
After responding to the prompt with the  correct password
('raspberry',) with any luck you will now be logged onto the
target machine (running it 'headless'.)

You will have to repeat this process each time the target machine
goes through a reboot<sup>[6](#6screenfreeze)</sup> or after you
log off.

All subsequent instructions assume that you are logged onto the
target machine using the ssh client on your staging machine.


### Configuring (`raspi-config`) and Upgrading the Pi

Use the command line of your staging machine to log onto the target
`Raspberry Pi` as described in the previous section.  You can safely
ignore any warning about changing the password.  We'll do that in a
moment. Run `raspi-config`:
        
        sudo raspi-config

As its name implies, `raspi-config` is an interactive utility
providing access to the Pi's configuration.  Make selections by
using the up and down arrow keys and once your choice is
highlighted, use the left and right arrow keys to pick `<Select>`
(or `<Finish>`).  Here is an outline of what is recommended or
appropriate for our use case:

    1. Change User Password Change password for the current user
        You will now be asked to enter a new password for the
        pi user; suggest changing to `pi::root` 
    2. Network Options      Configure network settings
        N1 Hostname                Set the visible name for this Pi on a network
            Suggest `rpi` or `pi-1` (something short)
            Once done editing the Hostname, use down arrow.
        N2 Wi-fi                   Enter SSID and passphrase
            Please enter SSID, use down arrow when done.
            (We'll be changing this later anyway.) I use 'pi security'.
        N3 Network interface names Enable/Disable predictable network interface names
            'YES' seems a reasonable option. (We'll be changing these.)
    3. Boot Options         Configure options for start-up
        B1 Desktop / CLI            Choose whether to boot into a desktop environment or the command line
            B1 Console           Text console, requiring user to login
                This is the one recommended.
            B2 Console Autologin Text console, automatically logged in as 'pi' user
            B3 Desktop           Desktop GUI, requiring user to login
            B4 Desktop Autologin Desktop GUI, automatically logged in as 'pi' user
        B2 Wait for Network at Boot Choose whether to wait for network connection during boot
            Would you like boot to wait until a network connection is established?
                Unimportant, I choose 'NO'.
        B3 Splash Screen            Choose graphical splash screen or text boot
                Only text boot is possible since we have no GUI
    4. Localisation Options Set up language and regional settings to match your location                             │
        I1 Change Locale          Set up language and regional settings to match your location
            The default is '[*] en_GB.UTF-8 UTF-8'; you may want to
            scroll down and toggle (using the space bar) the asterix
            on '[*] en_US.UTF-8 UTF-8'.  Then use the Return/Enter key
            to go to the next page to make your final selection.
        I2 Change Timezone        Set up timezone to match your location
            First pick the 'Geographic area:'
            Then select the specific zone. For us on the US West coast
            it's 'Pacific-New'
        I3 Change Keyboard Layout Set the keyboard layout to match your keyboard
            No need to bother with this since we'll be operating 'headless'.
        I4 Change Wi-fi Country   Set the legal channels used in your country
            Self explanatory
    5. Interfacing Options  Configure connections to peripherals
        Only the second (P2 SSH) option is relevant to us.
        P1 Camera      Enable/Disable connection to the Raspberry Pi Camera
        P2 SSH         Enable/Disable remote command line access to your Pi using SSH
            Be sure to enable SSH
        P3 VNC         Enable/Disable graphical remote access to your Pi using RealVNC
        P4 SPI         Enable/Disable automatic loading of SPI kernel module
        P5 I2C         Enable/Disable automatic loading of I2C kernel module
        P6 Serial      Enable/Disable shell and kernel messages on the serial connection
        P7 1-Wire      Enable/Disable one-wire interface
        P8 Remote GPIO Enable/Disable remote access to GPIO pins
    6. Overclock            Configure overclocking for your Pi                                                       │
    7. Advanced Options     Configure advanced settings                                                              │
        Only the first is of interest to us.
        A1 Expand Filesystem Ensures that all of the SD card storage is available to the OS
            It's very important to expand the file system!
        A2 Overscan          You may need to configure overscan if black bars are present on display
        A3 Memory Split      Change the amount of memory made available to the GPU
        A4 Audio             Force audio out through HDMI or 3.5mm jack
        A5 Resolution        Set a specific screen resolution
        A6 GL Driver         Enable/Disable experimental desktop GL driver
    The last two options are unimportant.
    8. Update               Update this tool to the latest version                                                   │
    9. About raspi-config   Information about this configuration tool                                                │

When done, accept the offer to reboot.


### Updating and Upgrading the Raspberry Pi

After the reboot, you'll have to again use the ssh client on your
staging machine to log onto the target machine,
this time using your newly set password (`pi::root`).

This section is specific for the `Raspberry Pi`.  If you are using
some other `Debian` based target, it would probably do no harm to
still try to run the curl command.  If an error is reported then
have a look at the `pi-upgrade.sh` script (part of the `phInfo`
repository.)  You could probably simply run the same commands
individually with only minor modification.

This (first `curl`) command upgrades `raspbian` components.
(It's best to use copy and past):

        curl https://raw.githubusercontent.com/alexKleider/phInfo/master/pi-upgrade.sh | bash -s

The above command ends with a reboot (necessary in order to
implement the new kernel) so wait for a few minutes for the boot
process to complete before logging back on.

##### Only for the Advanced User

The advanced user (wanting to change defaults) while still at the
command line of the staging maching  and in the repository
directory, should first be sure the `config` file is to her
satisfaction. Depending on which variables are to be changed
she may also need to log onto the target machine to create
another user and/or set up directories (including setting
permissions.)  Then she should run the following from the
staging machine:

        source config
        scp config ${MAIN_USER}@<ip-address>:${PARENT_DIR}

Then after logging on to the target machine:

        source config

Keep in mind that the effects of the above command are wiped
clean each time the connection is broken and then re-established:
The environmental variables it sets must be in effect each time
any of the subsequent commands are run. It does no harm to run
the command more than once.


### Installation of Utilities (Bring in the Repository)

The following (second `curl`) command ensures that current
directory is set correctly, installs `git`, and then clones
the phInfo repository.  It takes about 3 minutes to run:

        curl https://raw.githubusercontent.com/alexKleider/phInfo/master/repo.sh | bash -s

The clone operation brings in the `phInfo` file hierarchy containing
this `README` as well as required scripts and files.

There are a number of utilities and customizations that are not
essential but I find them useful to have so my practice is to
also run the following script (it takes about 3 minutes):

        cd phInfo  # AdvUsr substitute `cd $REPO`
        ./favourites.sh


### Network Setup

Network configuration is dependent on the target machine's
hardware.  These instructions assume that there is an Ethernet
(eth0) port and either a built in WiFi or a USB WiFi dongle as
is true for the Raspberry Pi. The scripts used will most
certainly have to be modified if this is not your use case.

Also note that the naming of `eth0` appears to have changed
with the move from `etch` to `stretch`; the code in the
`networking.sh` script attempts to allow for this and so far has
proven to be successful. Check the script if interested in how
this is done. https://wiki.debian.org/NetworkConfiguration

Configuration is done by commands in the networking.sh and the
iptables.sh scripts. There must be a reboot between the two
<sup>[6](#6screenfreeze)</sup>.
If you think you might want to make any customizations, have
a look through the initial comments in `networking.sh`; you
may want to edit some of the files mentioned.  
The `networking.sh` script takes about 20 minutes to complete.

        # AdvUser must `source config` again
        cd phInfo  # AdvUsr substitute `cd $REPO`
        ./networking.sh
        # You'll have to wait for some utilities to be installed and
        # then for the reboot to take place before logging on again.
        # AdvUser must `source config` again
        cd phInfo  # AdvUsr substitute `cd $REPO`
        ./iptables.sh

The last command also ends with a reboot. Remember that after each
reboot you'll have to use your staging machine to log back on to the
target machine<sup>[6](#6screenfreeze)</sup>.


### Bring in Dependencies

The next script may take a long time (~7 min with good internet
service, but up to ~30 min if service is slow!)

        # AdvUser must `source config` again
        cd phInfo  # AdvUsr substitute `cd $REPO`
        ./dependencies.sh

### Server Setup

There's no reboot after the last command so you should still be logged
on; be sure you are still in the ~/phInfo directory.
Have a look through the initial comments in `create-server.sh`.
It's unlikely there'll be anything you need to change.

        cd phInfo  # AdvUsr substitute `cd $REPO`
        ./create-server.sh

Wait for a few minutes for your target machine to reboot and then
you can check functionality by using any client machine to connect
to the server's WiFi access point.  The SSID will be 'piServer'
unless you've previously changed it by editing `hostapd.conf`.
If all has gone well, pointing your client browser to `rachel.lan`
will take you to the example static HTML home page.


### Pathagar Book Server

Choose a database password consisting of alphanumerics, dashes and
underscores but no other special characters. Make a record of it
somewhere so as to be sure not to forget it. I suggest 'db-password'.
Then log on to your target machine and run the following
command:

        # AdvUser must `source config` again
        export MYSQL_PASSWORD='db-password'

You will also later need a pathagar superuser password so now would
be a good time to pick one and record it somewhere.  I suggest
'ph-su-pw'.

The next sequence of commands brings in Pathagar, and sets up its
environment.  The `pip install -r requirements.pip` command in
`pathagar-setup.sh` script takes a very long time so be patient.
The set-su-pw.sh script prompts you for a *Django SuperUser*.
It'll want you to enter a user name (or default to the current
user,) email and the password- e.g. `ph-su-pw` (to be entered
twice.)

        # AdvUser must `source config` again
        cd ~/phInfo  # AdvUsr substitute `cd $REPO`
        ./pathagar-setup.sh

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

        rsync -av /mnt/Static/<dir-containing-content>/ /var/www/static
        # for AdvUsr: substitute the following instead:
        rsync -av ${MOUNT_POINT}/<dir-containing-content>/ $DIR4STATIC

Note that the final slash(`/`) at the end of the first parameter to
`rsync` is important (so that only the content, not the directory
itself, gets copied. Presence or absence of the final slash in 
the second parameter is immaterial.)

If your content is at the top level of the medium you've mounted
(rather than inside its own directory) then change the command to
the following:

        rsync -av /mnt/Static/* /var/www/static
        # for AdvUsr: substitute the following instead:
        rsync -av ${MOUNT_POINT}/* ${DIR4STATIC}

If your server is the `Raspberry Pi` set up as described here,
then entering "rachel.lan" (AdvUser: LIBRARY_URL) in the URL
window of a browser running on a WiFi client machine will result
in your content being displayed.


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

<a name="5oldraspian">5</a>

Older versions of raspian can be found 
[here](http://downloads.raspberrypi.org/raspbian_lite/images/).

<a name="6screenfreeze">6</a>

When using SSH, following a shutdown or a reboot, the client
teminal sometimes freezes.  This can be remedied with the
following 3 key strokes: Enter (the `Enter key`), tilde (`~`),
period (`.`).

<a name="7nasty">7</a>

When attempting to log on you might be presented with a "Host key
verification" failure.
If so, look for a line that ends with ...ssh/known_hosts:7.  Make
a note of the number (in this case it's 7) and then delete the 7th
line (or what ever number it is) in your ~/.ssh/known_hosts file.


<a name="9cooling">9</a>

Beware (Adam Holt, personal communication) "of your RPi overheating
and self-throttling etc -- be sure to test using the command to
monitor their temperature if folks will be using them in hot (or
even warm) conditions indoors.  A heatsink is not enough.  Many of
my Haitian friends just run their RPi 3s with the top off, which
indeed solves the problem as an indoor breeze is sufficient.  It
may seem unprofessional but it works.  Considering most all RPi
cases make practical ventilation impossible, and active cooling
with a fan-that-breaks is something nobody's wanted to bother with
so far". There are
[cases](https://www.amazon.com/gp/product/B01CQRROLW/ref=oh_aui_detailpage_o05_s00?ie=UTF8&psc=1)
available now that are more open and may be a satisfactory compromise.

<a name="11clients">11</a>

It has been suggested that up to about 22 WiFi clients can be
serviced by the `raspberry pi`.  
https://raspberrypi.stackexchange.com/questions/50162/maximum-wi-fi-clients-on-pi-3-hotspot#54765

