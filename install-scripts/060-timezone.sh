#!/bin/bash

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
arch-chroot /mnt hwclock --systohc --utc

#network time service
arch-chroot /mnt systemctl enable ntpd
