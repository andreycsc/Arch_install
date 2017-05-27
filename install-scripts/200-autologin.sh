#!/bin/bash

USER_NAME="andrey"

arch-chroot /mnt touch /home/$USER_NAME/.xinitrc
echo "exec startxfce4" > /mnt/home/$USER_NAME/.xinitrc

mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d
arch-chroot /mnt touch /etc/systemd/system/getty@tty1.service.d/override.conf
echo "[Service]" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "Type=idle" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I $TERM" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf

arch-chroot /mnt touch /home/$USER_NAME/.bash_profile
echo "" >> /mnt/home/$USER_NAME/.bashrc
echo "if [ -z "\$DISPLAY" ] && [ -n "\$XDG_VTNR" ] && [ "\$XDG_VTNR" -eq 1 ]; then" >> /mnt/home/$USER_NAME/.bashrc
echo "startx" >> /mnt/home/$USER_NAME/.bashrc
echo "fi" >> /mnt/home/$USER_NAME/.bashrc

