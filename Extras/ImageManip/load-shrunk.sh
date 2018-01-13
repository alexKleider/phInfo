# File: load-shrunk.sh

# Restore a shrunken image

# Usage
#	sudo su
#	source load-shrunk.sh
#	exit

export DLDir="/Downloads"
export DeviceName="sdc"
export IMAGE="shrunk.img"
umount /dev/${DeviceName}1
# umount /dev/${DeviceName}2
date
sudo dd if="${DLDir}/${IMAGE}" of=/dev/$DeviceName bs=4M && sudo sync
date 
