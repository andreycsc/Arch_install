#!/bin/bash
################################################

BOOT_TIMEOUT="0"
USER_NAME="andrey"
USER_PASSWORD="user"
ROOT_PASSWORD="root"
ROOT_DEV="sda2"
BOOT_DEV="sda1"
#if home not defined wil not be on separate partition
HOME_DEV=""

function wait_enter {
	echo ""
	read -p "Please press enter to continue..." nothing
}

function cont_y_n {
	printf "Do you want to continue (Y/n): "
	read INPT
	if [ "$INPT" = "n" ]; then 
	echo "Ending..."
	echo ""
	exit
	fi
}

install_video_cards(){

	local VIDEO_DRIVER
	# Determine video chipset - only Intel, ATI and nvidia are supported by this script
	echo -e "\033[32mDetecting video chipset...\e[0m"
	local _vga=`lspci | grep VGA | tr "[:upper:]" "[:lower:]"`
	local _vga_length=`lspci | grep VGA | wc -l`

	if [[ -n $(echo ${_vga} | grep virtualbox) ]]; then
	echo -e "\033[32mFound virtual box...\e[0m"
		VIDEO_DRIVER="virtualbox"
	elif [[ $_vga_length -eq 2 ]] && [[ -n $(echo ${_vga} | grep "nvidia") || -f /sys/kernel/debug/dri/0/vbios.rom ]]; then
		echo -e "\033[32mFound  bumblebee...\e[0m"
		VIDEO_DRIVER="bumblebee"
	elif [[ -n $(echo ${_vga} | grep "nvidia") || -f /sys/kernel/debug/dri/0/vbios.rom ]]; then
		echo -e "\033[32mFound  nvidia...\e[0m"
		VIDEO_DRIVER="nvidia"
		#VIDEO_DRIVER="nouveau"
	elif [[ -n $(echo ${_vga} | grep "advanced micro devices") || -f /sys/kernel/debug/dri/0/radeon_pm_info || -f /sys/kernel/debug/dri/0/radeon_sa_info ]]; then
		echo -e "\033[32mFound  ati...\e[0m"
		VIDEO_DRIVER="ati"
	elif [[ -n $(echo ${_vga} | grep "intel corporation") || -f /sys/kernel/debug/dri/0/i915_capabilities ]]; then
		echo -e "\033[32mFound intel...\e[0m"
		VIDEO_DRIVER="intel"
	else
		echo -e "\033[32mFound vesa...\e[0m"
		VIDEO_DRIVER="vesa"
	fi

#Virtualbox {{{
if [[ ${VIDEO_DRIVER} == virtualbox ]]; then
	arch_chroot "pacman -S --noconfirm virtualbox-guest-modules-arch virtualbox-guest-utils mesa-libgl"
	#add_module "vboxguest vboxsf vboxvideo" "virtualbox-guest"
	arch_chroot "usermod -aG vboxsf $username"
	arch_chroot "systemctl disable ntpd"
	arch_chroot "systemctl enable vboxservice"
	if [[ `uname -m` == x86_64 ]]; then
		arch_chroot "pacman -S --noconfirm lib32-mesa-libgl"
	fi
#}}}
#NVIDIA {{{
elif [[ ${VIDEO_DRIVER} == nvidia ]]; then
	arch_chroot "pacman -S --noconfirm nvidia nvidia-libgl nvidia-settings"
	arch_chroot "nvidia-xconfig --add-argb-glx-visuals --allow-glx-with-composite --composite -no-logo --render-accel -o /etc/X11/xorg.conf.d/20-nvidia.conf"
	if [[ `uname -m` == x86_64 ]]; then
		arch_chroot "pacman -S --noconfirm lib32-nvidia-utils lib32-nvidia-libgl"
	fi
#ATI {{{
elif [[ ${VIDEO_DRIVER} == ati ]]; then
	arch_chroot "pacman -S --noconfirm xf86-video-ati mesa-libgl mesa-vdpau libvdpau-va-gl"

	if [[ `uname -m` == x86_64 ]]; then
		arch_chroot "pacman -S --noconfirm lib32-mesa-libgl lib32-mesa-vdpau"
	fi
	arch_chroot "export VDPAU_DRIVER=va_gl" "/etc/profile"
#Intel {{{
elif [[ ${VIDEO_DRIVER} == intel ]]; then
    arch_chroot "pacman -S --noconfirm xf86-video-intel mesa-libgl libvdpau-va-gl"
	
	if [[ `uname -m` == x86_64 ]]; then
		arch_chroot "pacman -S --noconfirm lib32-mesa-libgl lib32-mesa-vdpau"
	fi
	arch_chroot "export VDPAU_DRIVER=va_gl" "/etc/profile"
#}}}
fi
#}}}
}


 aur_package_install() { #{{{
    #install package from aur
    for PKG in $1; do
        su - ${USER_NAME} -c "yaourt --noconfirm -S ${PKG}"
    done
} #}}}



arch_chroot() { #{{{
arch-chroot /mnt /bin/bash -c "${1}"
}

echo "---------------------------------------"
echo -e "\033[32mFormatting drives...\e[0m"
echo "---------------------------------------"

#lsblk
#echo -e "\033[33menter device for ROOT (probably sda2)\e[0m"
#read ROOT_DEV
#lsblk
#echo -e "\033[33menter device for BOOT (probably sda1)\e[0m"
#read BOOT_DEV
#lsblk
#echo -e "\033[33menter device for HOME (probably sda3)\e[0m"
#    read HOME_DEV

# format root
mkfs.ext4 -F /dev/$ROOT_DEV
# mount root
mkdir -p /mnt
mount /dev/$ROOT_DEV /mnt

if [[ ${HOME_DEV} != '' ]]; then
	## format home
	mkfs.ext4 -F /dev/$HOME_DEV
	## Mount the home drive
	mkdir -p /mnt/home
	mount /dev/$HOME_DEV /mnt/home
fi

# format boot
mkfs.vfat -F32 /dev/$BOOT_DEV
# mount boot
mkdir -p /mnt/boot
mount /dev/$BOOT_DEV /mnt/boot



echo "---------------------------------------"
echo -e "\033[32mInstalling base system...\e[0m"
echo "---------------------------------------"
export LANG=en_US.UTF-8

url="https://www.archlinux.org/mirrorlist/?country=RO&use_mirror_status=on"
tmpfile=$(mktemp --suffix=-mirrorlist)
curl -so ${tmpfile} ${url}
sed -i 's/^#Server/Server/g' ${tmpfile}

# Backup and replace current mirrorlist file (if new file is non-zero)
if [[ -s ${tmpfile} ]]; then
{ echo " Backing up the original mirrorlist..."
	mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; } &&
{ echo " Rotating the new list into place..."
	mv -i ${tmpfile} /etc/pacman.d/mirrorlist; }
else
	echo " Unable to update, could not download list."
fi
# better repo should go first
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.tmp
rankmirrors /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.tmp
# allow global read access (required for non-root yaourt execution)
chmod +r /etc/pacman.d/mirrorlist

pacman -Syy


pacstrap /mnt base base-devel dialog iw intel-ucode dosfstools exfat-utils 	ntfs-3g networkmanager ntp htop
echo "---------------------------------------"
echo -e "\033[32mGenerating fstab...\e[0m"
echo "---------------------------------------"
genfstab -U -p /mnt > /mnt/etc/fstab
#nano /mnt/etc/fstab

echo "---------------------------------------"
echo -e "\033[32mGoing into arch chroot...\e[0m"
echo "---------------------------------------"
#arch-chroot /mnt /bin/bash
################################################
# We are loged in into the instaled sistemd root
################################################

ARCHCONF="/mnt/boot/loader/entries/arch.conf"
LOADER="/mnt/boot/loader/loader.conf"
MKINITCPIOCONF="/etc/mkinitcpio.conf"
TEMP="/tmp/mkinit.tmp"

#network time service
arch_chroot "systemctl enable ntpd"

echo "---------------------------------------"
echo -e "\033[32mGenerating language stuff...\e[0m"
echo "---------------------------------------"

sed -i '/'en_US.UTF-8'/s/^#//' /mnt/etc/locale.gen
sed -i '/'ro_RO.UTF-8'/s/^#//' /mnt/etc/locale.gen

echo LC_NUMERIC=ro_RO.UTF-8 > /mnt/etc/locale.conf
echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
echo LC_MEASUREMENT=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_NAME=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_TIME=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_TELEPHONE=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_PAPER=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_IDENTIFICATION=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_MONETARY=ro_RO.UTF-8 >> /mnt/etc/locale.conf
echo LC_ADDRESS=ro_RO.UTF-8 >> /mnt/etc/locale.conf

arch_chroot "export LANG=en_US.UTF-8"
arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime"
arch_chroot "hwclock --systohc --utc"

arch_chroot "locale-gen"

echo "AndreiC" > /mnt/etc/hostname


echo "---------------------------------------"
echo -e "\033[32mInstaling needed tools...\e[0m"
echo "---------------------------------------"
# use hosts file to block some malicious sites
wget http://someonewhocares.org/hosts/ipv6/hosts
mv hosts /mnt/etc/hosts

#network manager service
arch_chroot "systemctl enable NetworkManager"


echo "---------------------------------------"
echo -e "\033[32mInstaling bootloader...\e[0m"
echo "---------------------------------------"
#echo -e "\033[33menter device for ROOT (probably sda2)\e[0m"
#read DEV
# bootctl
arch_chroot "bootctl --path=/boot install"
# archconf
echo -e "\033[32mBoot configuration...\e[0m"
arch_chroot "touch boot/loader/entries/arch.conf"
UUID=$(blkid /dev/$ROOT_DEV | awk '{print $4}' | sed 's/"//g') 
echo "title		Arch Linux" > $ARCHCONF
echo "linux		/vmlinuz-linux" >> $ARCHCONF
echo "initrd	/intel-ucode.img" >> $ARCHCONF
echo "initrd	/initramfs-linux.img" >> $ARCHCONF
echo "options	root=$UUID rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vga=current" >> $ARCHCONF

echo "default	arch" > $LOADER
echo "timeout	$BOOT_TIMEOUT" >> $LOADER
echo "#editor	0" >> $LOADER

echo "bootctl	update..."
arch_chroot "bootctl update"

#echo "remove hooks mkinitcpioconf..."
#sed  s/^HOOKS=.*$// $MKINITCPIOCONF > $TEMP && mv $TEMP $MKINITCPIOCONF && rm -f $TEMP
#echo "add hooks"
#echo "HOOKS=\"base udev autodetect modconf block keyboard filesystems fsck\"" >> $MKINITCPIOCONF

# regenerate ramdisk
#echo "mkinitcpio..."
#mkinitcpio -p linux



echo "---------------------------------------"
echo -e "\033[32mAding optinal repositorys...\e[0m"
echo "---------------------------------------"
# add multilib
_has_multilib=`grep -n "\[multilib\]" /mnt/etc/pacman.conf | cut -f1 -d:`
if [[ -z $_has_multilib ]]; then
	echo -e "\n[multilib]\nInclude = /mnt/etc/pacman.d/mirrorlist" >> /etc/pacman.conf
	echo -e '\nMultilib repository added into pacman.conf file'
else
	sed -i "${_has_multilib}s/^#//" /mnt/etc/pacman.conf
	_has_multilib=$(( ${_has_multilib} + 1 ))
	sed -i "${_has_multilib}s/^#//" /mnt/etc/pacman.conf
fi

# repo containing yaourt
echo "" >> /mnt/etc/pacman.conf
echo "[arcanisrepo]" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf
echo "Server = http://repo.arcanis.me/repo/\$arch" >> /mnt/etc/pacman.conf

arch_chroot "pacman -Syy"

echo "---------------------------------------"
echo -e "\033[33mSet a password for root.\e[0m"
arch_chroot "chpasswd <<<"root:$ROOT_PASSWORD""
echo "---------------------------------------"
################################################

echo "---------------------------------------"
echo -e "\033[33mCreate new user.\e[0m"
USER_NAME=`echo $USER_NAME | tr '[:upper:]' '[:lower:]'`
arch_chroot "useradd -m -g users -G wheel,uucp,users -s /bin/bash ${USER_NAME}"
echo -e "\033[33mSet a password for new user.\e[0m"
arch_chroot "chpasswd <<<"$USER_NAME:$USER_PASSWORD""

#echo -e "PAUSE"
#read ROOT_DEVSD

#CONFIGURE SUDOERS {{{
if [[ ! -f  /mnt/etc/sudoers.aui ]]; then
	cp -v /mnt/etc/sudoers /mnt/etc/sudoers.aui
	## Uncomment to allow members of group wheel to execute any command
	#sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /mnt/etc/sudoers
	## Same thing without a password (not secure)
	sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /mnt/etc/sudoers

	#This config is especially helpful for those using terminal multiplexers like screen, tmux, or ratpoison, and those using sudo from scripts/cronjobs:
	echo "" >> /mnt/etc/sudoers
	echo 'Defaults !requiretty, !tty_tickets, !umask' >> /mnt/etc/sudoers
	echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /mnt/etc/sudoers
	echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /mnt/etc/sudoers
	echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /mnt/etc/sudoers
	echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /mnt/etc/sudoers
	echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /mnt/etc/sudoers
	echo 'Defaults timestamp_timeout=15' >> /mnt/etc/sudoers
	echo 'Defaults passprompt="[sudo] password for %u: "' >> /mnt/etc/sudoers
fi
#}}}

echo "---------------------------------------"
echo -e "\033[32mInstaling video card drivers...\e[0m"
echo "---------------------------------------"
install_video_cards

echo "---------------------------------------"
echo -e "\033[32mInstaling audio server...\e[0m"
echo "---------------------------------------"
arch_chroot "pacman -S --noconfirm alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-ctl pulseaudio-zeroconf pavucontrol"
	if [[ `uname -m` == x86_64 ]]; then
		arch_chroot "pacman -S --noconfirm lib32-libpulse lib32-alsa-plugins"
	fi
arch_chroot "amixer sset Master unmute"


echo "---------------------------------------"
echo -e "\033[32mInstaling Xorg server...\e[0m"
echo "---------------------------------------"
arch_chroot "pacman -S --noconfirm xorg-server"
arch_chroot "pacman -S --noconfirm xorg-server-utils xorg-xinit"

echo "---------------------------------------"
echo -e "\033[32mInstaling desktop env...\e[0m"
echo "---------------------------------------"
arch_chroot "pacman -S --noconfirm xfce4 xfce4-goodies network-manager-applet arc-gtk-theme faenza-icon-theme"


echo "---------------------------------------"
echo -e "\033[32mInstaling needed apps...\e[0m"
echo "---------------------------------------"
#--arhive
arch_chroot "pacman -S --noconfirm xarchiver zip unzip p7zip lzop cpio unrar"
#--mounted drives
arch_chroot "pacman -S --noconfirm gvfs"
#--browser
arch_chroot "pacman -S --noconfirm chromium"


echo "---------------------------------------"
echo -e "\033[32mFinishing up...\e[0m"
echo "---------------------------------------"

arch_chroot "touch /home/$USER_NAME/.xinitrc"
echo "exec startxfce4" > /mnt/home/$USER_NAME/.xinitrc

mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d
arch_chroot "touch /etc/systemd/system/getty@tty1.service.d/override.conf"
echo "[Service]" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "Type=idle" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I $TERM" >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf

arch_chroot "touch /home/$USER_NAME/.bash_profile"
echo "" >> /mnt/home/$USER_NAME/.bashrc
echo "if [ -z "\$DISPLAY" ] && [ -n "\$XDG_VTNR" ] && [ "\$XDG_VTNR" -eq 1 ]; then" >> /mnt/home/$USER_NAME/.bashrc
echo "startx" >> /mnt/home/$USER_NAME/.bashrc
echo "fi" >> /mnt/home/$USER_NAME/.bashrc




#--yaourt
arch_chroot "pacman -S --noconfirm yaourt"
arch_chroot "touch /home/$USER_NAME/.yaourtrc"
echo "BUILD_NOCONFIRM=1" >> /mnt/home/$USER_NAME/.yaourtrc
echo "EDITFILES=0" >> /mnt/home/$USER_NAME/.yaourtrc
echo "NOCONFIRM=1" >> /mnt/home/$USER_NAME/.yaourtrc
#--qt apps styles



# change permision of files in user dir to be owned by user
arch_chroot "chown -R $USER_NAME /home/$USER_NAME"



umount -R /mnt

#reboot

