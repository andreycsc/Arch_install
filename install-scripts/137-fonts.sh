#!/bin/bash

arch-chroot /mnt pacman -S --noconfirm  ttf-dejavu ttf-liberation noto-fonts ttf-symbola ttf-ms-fonts ttf-droid

arch-chroot /mnt ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

FREETYPE=`grep -n "export FREETYPE_PROPERTIES" /mnt/etc/profile.d/freetype2.sh | cut -f1 -d:`

if [[ -n $FREETYPE ]]; then
	sed -i "${FREETYPE}s/^#//" /mnt/etc/profile.d/freetype2.sh
fi

FILE="/mnt/etc/fonts/local.conf"

/bin/cat <<EOM >$FILE
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match>
        <edit mode="prepend" name="family"><string>Noto Sans</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Serif</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>sans-serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Sans</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>monospace</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Mono</string></edit>
    </match>
</fontconfig>
EOM