#!/bin/bash

BOOT_DEV=$( blkid -L BOOT )
ROOT_DEV=$( blkid -L ROOT )
HOME_DEV=$( blkid -L HOME )

if [[ ${ROOT_DEV} != '' ]]; then
	# format root
	mkfs.ext4 -F $ROOT_DEV
	# mount root
	mkdir -p /mnt
	mount $ROOT_DEV /mnt
fi

#if home not defined wil not be on separate partition
if [[ ${HOME_DEV} != '' ]]; then
	## format home
	mkfs.ext4 -F $HOME_DEV
	## Mount the home drive
	mkdir -p /mnt/home
	mount $HOME_DEV /mnt/home
fi

if [[ ${BOOT_DEV} != '' ]]; then
	# format boot
	mkfs.vfat -F32 $BOOT_DEV
	# mount boot
	mkdir -p /mnt/boot
	mount $BOOT_DEV /mnt/boot
fi
