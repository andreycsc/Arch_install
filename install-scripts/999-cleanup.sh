#!/bin/bash

USER_NAME="andrey"

# change permision of files in user dir to be owned by user
arch-chroot /mnt chown -R $USER_NAME /home/$USER_NAME

umount -R /mnt
