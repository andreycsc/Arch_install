#!/bin/bash

#--yaourt
arch-chroot /mnt pacman -S --noconfirm yaourt
touch /mnt/home/$USER_NAME/.yaourtrc
echo "BUILD_NOCONFIRM=1" >> /mnt/home/$USER_NAME/.yaourtrc
echo "EDITFILES=0" >> /mnt/home/$USER_NAME/.yaourtrc
echo "NOCONFIRM=1" >> /mnt/home/$USER_NAME/.yaourtrc
