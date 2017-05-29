#!/bin/bash

arch-chroot /mnt chpasswd <<<"root:$ROOT_PASSWORD"

arch-chroot /mnt useradd -m -g users -G wheel,uucp,users -s /bin/bash ${USER_NAME}
arch-chroot /mnt chpasswd <<<"$USER_NAME:$USER_PASSWORD"


## Uncomment to allow members of group wheel to execute any command
#sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /mnt/etc/sudoers
# Same thing without a password (not secure)
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

