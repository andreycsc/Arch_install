#!/bin/bash

#BOOT_DEV=$( blkid -L BOOT )
#ROOT_DEV=$( blkid -L ROOT )
#HOME_DEV=$( blkid -L HOME )

if [[ -e /dev/disk/by-partlabel/ROOT ]]; then
	# format root
	mkfs.ext4 -F /dev/disk/by-partlabel/ROOT
	# mount root
	mkdir -p /mnt
	mount /dev/disk/by-partlabel/ROOT /mnt
fi

#if home not defined wil not be on separate partition
if [[ -e /dev/disk/by-partlabel/HOME ]]; then
	## format home
	mkfs.ext4 -F /dev/disk/by-partlabel/HOME
	## Mount the home drive
	mkdir -p /mnt/home
	mount /dev/disk/by-partlabel/HOME /mnt/home
fi

if [[ -e /dev/disk/by-partlabel/BOOT ]]; then
	# format boot
	#mkfs.vfat -F32 /dev/disk/by-partlabel/BOOT
	# mount boot
	mkdir -p /mnt/boot
	mount /dev/disk/by-partlabel/BOOT /mnt/boot
fi
