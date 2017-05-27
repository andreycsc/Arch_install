#!/bin/bash


arch-chroot /mnt pacman -S --noconfirm alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-ctl pulseaudio-zeroconf pavucontrol
	if [[ `uname -m` == x86_64 ]]; then
		arch-chroot /mnt pacman -S --noconfirm lib32-libpulse lib32-alsa-plugins
	fi
arch-chroot /mnt amixer sset Master unmute