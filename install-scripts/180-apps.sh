#!/bin/bash

#--arhive
arch-chroot /mnt pacman -S --noconfirm xarchiver zip unzip p7zip lzop cpio unrar
#--mounted drives
arch-chroot /mnt pacman -S --noconfirm gvfs
#--browser
arch-chroot /mnt pacman -S --noconfirm chromium