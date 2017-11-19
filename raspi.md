---
layout: default
title: Raspberry Pi Instructions
---

# File: raspi.md
# RPi instructions

We are developing this on Raspbian Stretch Lite

Here's the sequence:

Use the terminal of the staging machine to ssh onto the target.
Use the staging machine's browser to go to the repo and open this/the raspi.md file.
Copy the curl command from the browser and then past it into the terminal to be run on the target.

The pi-bootstrap.sh script must do as much as possible, we are hoping
everything, to get the target configured as we want it.

        curl 'https://raw.githubusercontent.com/alexKleider/phInfo/master/pi-bootstrap.sh' | bash -s



