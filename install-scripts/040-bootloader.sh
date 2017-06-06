#!/bin/bash

BOOT_TIMEOUT="0"
ARCHCONF="/mnt/boot/loader/entries/arch.conf"
LOADER="/mnt/boot/loader/loader.conf"

# delete old boot config files if present
if [[ -n $ARCHCONF ]]; then
	rm $ARCHCONF
fi
if [[ -n $LOADER ]]; then
	rm $LOADER
fi

arch-chroot /mnt bootctl --path=/boot install

touch $ARCHCONF
echo "title		Arch Linux" > $ARCHCONF
echo "linux		/vmlinuz-linux" >> $ARCHCONF
echo "initrd	/intel-ucode.img" >> $ARCHCONF
echo "initrd	/initramfs-linux.img" >> $ARCHCONF
echo "options	root=/dev/disk/by-partlabel/ROOT rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vga=current" >> $ARCHCONF

echo "default	arch" > $LOADER
echo "timeout	$BOOT_TIMEOUT" >> $LOADER
echo "#editor	0" >> $LOADER

arch-chroot /mnt bootctl update


#MKINITCPIOCONF="/etc/mkinitcpio.conf"
#TEMP="/tmp/mkinit.tmp

#echo "remove hooks mkinitcpioconf..."
#sed  s/^HOOKS=.*$// $MKINITCPIOCONF > $TEMP && mv $TEMP $MKINITCPIOCONF && rm -f $TEMP
#echo "add hooks"
#echo "HOOKS=\"base udev autodetect modconf block keyboard filesystems fsck\"" >> $MKINITCPIOCONF

# regenerate ramdisk
#echo "mkinitcpio..."
#mkinitcpio -p linux