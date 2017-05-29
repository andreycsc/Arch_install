#!/bin/bash

# change permision of files in user dir to be owned by user

cp -r ~/logs /mnt/home/$USER_NAME/install_logs

arch-chroot /mnt chown -R $USER_NAME /home/$USER_NAME

umount -R /mnt

