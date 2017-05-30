#!/bin/bash

#BOOT_DEV=$( blkid -L BOOT )
#ROOT_DEV=$( blkid -L ROOT )
#HOME_DEV=$( blkid -L HOME )

if [[ -e /dev/disk/by-label/ROOT ]]; then
	# format root
	mkfs.ext4 -F /dev/disk/by-label/ROOT
	# mount root
	mkdir -p /mnt
	mount /dev/disk/by-label/ROOT /mnt
fi

#if home not defined wil not be on separate partition
if [[ -e /dev/disk/by-label/HOME ]]; then
	## format home
	mkfs.ext4 -F /dev/disk/by-label/HOME
	## Mount the home drive
	mkdir -p /mnt/home
	mount /dev/disk/by-label/HOME /mnt/home
fi

if [[ -e /dev/disk/by-label/BOOT ]]; then
	# format boot
	mkfs.vfat -F32 /dev/disk/by-label/BOOT
	# mount boot
	mkdir -p /mnt/boot
	mount /dev/disk/by-label/BOOT /mnt/boot
fi
