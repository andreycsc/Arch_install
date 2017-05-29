#!/bin/bash

url="https://www.archlinux.org/mirrorlist/?country=RO&use_mirror_status=on"
tmpfile=$(mktemp --suffix=-mirrorlist)
curl -so ${tmpfile} ${url}
sed -i 's/^#Server/Server/g' ${tmpfile}

# Backup and replace current mirrorlist file (if new file is non-zero)
if [[ -s ${tmpfile} ]]; then
{ 
	echo " Backing up the original mirrorlist..."
	mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; } &&
{ 
	echo " Rotating the new list into place..."
	mv -i ${tmpfile} /etc/pacman.d/mirrorlist; }
else
	echo " Unable to update, could not download list."
fi
# better repo should go first
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.tmp
rankmirrors /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.tmp
# allow global read access (required for non-root yaourt execution)
chmod +r /etc/pacman.d/mirrorlist

pacman -Syy

pacstrap /mnt base base-devel dialog iw intel-ucode dosfstools exfat-utils 	ntfs-3g ntp htop