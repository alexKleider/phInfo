# File: shrink.sh

# Usage:
#   sudo su
#   source shrink.sh
#   exit

# Sets up a loop device and onto it loads the image to be shrunk.
# Shrinks the file system and then reports its size.
# After this need only to shrink the partition and then
# shrink and rename the image.

export SRC="/Downloads/ph-image2shrink.img"  # image after ph setup.
export SC="/Downloads/shrink-candidate.img"  # sacrificial copy

echo "Enable loopback (if not already enabled...)"
modprobe loop

echo "Detach all associated loop devices."
losetup -D

echo "Request a new/free loopback device..."
losetup -f
echo " => /dev/loop0"

# echo "remove $SC..."
# rm $SC
# echo "...and copy $SRC to $SC..."
# cp $SRC $SC  # Start with a fresh copy
# echo " ...done with copy"

echo "Create a device for the image..."
losetup /dev/loop0 $SC

echo "Ask kernel to load the partitions that are on the image..."
partprobe /dev/loop0
echo "=> /dev/loop0p1 & /dev/loop0p2 (provides access to partitions)"

echo "resize2fs demands fsck first..."
fsck.ext4 -f /dev/loop0p2
echo "resize partition to minimum size..."
resize2fs -M /dev/loop0p2

echo "Use dumpe2fs to get block count and size of 2nd partition..."
dumpe2fs -h /dev/loop0p2 | grep -e "Block count" -e "Block size"

echo "fdisk -l to just list partitions..."
fdisk -l /dev/loop0

echo "loopback-device no longer needed..."
losetup -d /dev/loop0


# Still to do:

# `sudo fdisk $SC` to shrink partition:
# $[(94208-1) + 680712 * 4096 / 512] => 5539903
# $[(94208-1) + 682573 * 4096 / 512] => 5554791

# and shrink the image:
# `sudo truncate --size=$[(5539903+1)*512] $SC`
# `sudo truncate --size=$[(5554791+1)*512] $SC`
# `sudo truncate --size=$[(5554791+1)*512+14888] $SC`
# For Rachel image:
# will try 'sudo truncate --size=$[(117856945+1)*512+14888] $SC`

# Rename shrunken image:
# mv $SC shrunk.img
# & then `dd` it to an sd card:
# sudo su && source load-shrunk.sh && exit
# export IMAGE="shrunk.img"

