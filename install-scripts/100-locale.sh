#!/bin/bash

sed -i '/'en_US.UTF-8'/s/^#//' /mnt/etc/locale.gen
sed -i '/'ro_RO.UTF-8'/s/^#//' /mnt/etc/locale.gen

echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
echo LC_NUMERIC=ro_RO.UTF-8 > /mnt/etc/locale.conf
echo LC_MEASUREMENT=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_NAME=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_TIME=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_TELEPHONE=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_PAPER=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_IDENTIFICATION=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_MONETARY=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_ADDRESS=ro_RO.UTF-8 >> /mnt/etc/locale.conf

arch-chroot /mnt locale-gen

echo "AndreiC" > /mnt/etc/hostname