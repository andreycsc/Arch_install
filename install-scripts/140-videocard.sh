#!/bin/bash

USER_NAME="andrey"



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
	arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-modules-arch virtualbox-guest-utils mesa-libgl
	#add_module "vboxguest vboxsf vboxvideo" "virtualbox-guest"
	arch-chroot /mnt usermod -a -G vboxsf $USER_NAME
	arch-chroot /mnt systemctl disable ntpd
	arch-chroot /mnt systemctl enable vboxservice
	if [[ `uname -m` == x86_64 ]]; then
		arch-chroot /mnt pacman -S --noconfirm lib32-mesa-libgl
	fi
#}}}
#NVIDIA {{{
elif [[ ${VIDEO_DRIVER} == nvidia ]]; then
	arch-chroot /mnt pacman -S --noconfirm nvidia nvidia-libgl nvidia-settings
	arch-chroot /mnt nvidia-xconfig --add-argb-glx-visuals --allow-glx-with-composite --composite -no-logo --render-accel -o /etc/X11/xorg.conf.d/20-nvidia.conf
	if [[ `uname -m` == x86_64 ]]; then
		arch-chroot /mnt pacman -S --noconfirm lib32-nvidia-utils lib32-nvidia-libgl
	fi
#ATI {{{
elif [[ ${VIDEO_DRIVER} == ati ]]; then
	arch-chroot /mnt pacman -S --noconfirm xf86-video-ati mesa-libgl mesa-vdpau libvdpau-va-gl

	if [[ `uname -m` == x86_64 ]]; then
		arch-chroot /mnt pacman -S --noconfirm lib32-mesa-libgl lib32-mesa-vdpau
	fi
	echo 'export VDPAU_DRIVER=va_gl' >> /mnt/etc/profile
#Intel {{{
elif [[ ${VIDEO_DRIVER} == intel ]]; then
    arch-chroot /mnt pacman -S --noconfirm xf86-video-intel mesa-libgl libvdpau-va-gl
	
	if [[ `uname -m` == x86_64 ]]; then
		arch-chroot /mnt pacman -S --noconfirm lib32-mesa-libgl lib32-mesa-vdpau
	fi
	echo 'export VDPAU_DRIVER=va_gl' >> /mnt/etc/profile
#}}}
fi
#}}}