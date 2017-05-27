#!/bin/bash

# use hosts file to block some malicious sites
wget http://someonewhocares.org/hosts/ipv6/hosts
mv hosts /mnt/etc/hosts

#network manager service
arch-chroot /mnt systemctl enable NetworkManager