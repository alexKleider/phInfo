#!/bin/bash

# File: setup2shrink.sh

# Store an image after completion of pathagar installation:
# Usage:  sudo ./setup2shrink.sh
# Be sure variables are correct for your system.

export DLDir="/Downloads"
export DeviceName="sdc"
export IMAGE="ph-image2shrink.img"
umount /dev/${DeviceName}1
umount /dev/${DeviceName}2
date
dd of="${DLDir}/${IMAGE}" if=/dev/$DeviceName bs=4M  # (6min)
date
cp "${DLDir}/${IMAGE}" "${DLDir}/shrink-candidate.img"  # (~5min)
date
sync
sudo chown alex:alex ${DLDir}/${IMAGE}
sudo chown alex:alex "${DLDir}/shrink-candidate.img"
