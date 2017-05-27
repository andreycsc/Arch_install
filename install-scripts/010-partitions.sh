#!/bin/bash

ROOT_DEV="sda2"
BOOT_DEV="sda1"
#if home not defined wil not be on separate partition
HOME_DEV=""

# format root
mkfs.ext4 -F /dev/$ROOT_DEV
# mount root
mkdir -p /mnt
mount /dev/$ROOT_DEV /mnt

if [[ ${HOME_DEV} != '' ]]; then
	## format home
	mkfs.ext4 -F /dev/$HOME_DEV
	## Mount the home drive
	mkdir -p /mnt/home
	mount /dev/$HOME_DEV /mnt/home
fi

# format boot
mkfs.vfat -F32 /dev/$BOOT_DEV
# mount boot
mkdir -p /mnt/boot
mount /dev/$BOOT_DEV /mnt/boot
