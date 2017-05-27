#!/bin/bash

# add multilib
_has_multilib=`grep -n "\[multilib\]" /mnt/etc/pacman.conf | cut -f1 -d:`
if [[ -z $_has_multilib ]]; then
	echo -e "\n[multilib]\nInclude = /mnt/etc/pacman.d/mirrorlist" >> /etc/pacman.conf
	echo -e '\nMultilib repository added into pacman.conf file'
else
	sed -i "${_has_multilib}s/^#//" /mnt/etc/pacman.conf
	_has_multilib=$(( ${_has_multilib} + 1 ))
	sed -i "${_has_multilib}s/^#//" /mnt/etc/pacman.conf
fi

# repo containing yaourt
echo "" >> /mnt/etc/pacman.conf
echo "[arcanisrepo]" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf

arch-chroot /mnt pacman -Syy