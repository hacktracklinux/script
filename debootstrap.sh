#!/bin/bash
#    ____  _   _            _    _ _____               _    
#   / / / | | | | __ _  ___| | _| |_   _| __ __ _  ___| | __
#  / / /  | |_| |/ _` |/ __| |/ / | | || '__/ _` |/ __| |/ /
#  \ \ \  |  _  | (_| | (__|   <| | | || | | (_| | (__|   < 
#   \_\_\ |_| |_|\__,_|\___|_|\_\ | |_||_|  \__,_|\___|_|\_\
#   "my dream is a good hacker" |_|                         
# ------------------------------------------------------------
###################################################################
# Default Profile << Hack|Track                        
# version           : 2017.1
# Author            : Root HackTrack <root@hacktrack-linux.org>
# Licenced          : Copyright 2017 GNU GPLv3
# Website           : http://www.hacktrack-linux.org/
###################################################################
# Script Arsip Debootstrap Hacktrack
# make folder work
mkdir hacktrack && cd hacktrack
mkdir -p image/{live,isolinux,.disk}
sudo debootstrap --arch=i386 --variant=minbase jessie /home/dindin/hacktrack/chroot http://ftp.us.debian.org/debian
sudo mount --bind /dev/ chroot/dev/
sudo cp /etc/resolv.conf chroot/etc/
sudo chroot chroot
export HOME=/root
export LC_ALL=C
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
passwd root
echo "hacktrack" > /etc/hostname
cd /etc/skel
mkdir Desktop Documents Downloads Music Pictures Public Templates Videos
cd /
apt-get update && apt-get install nano
cd /etc/apt/

nano sources.list
# Core Debian Jessie "8"
deb http://ftp.us.debian.org/debian jessie main contrib non-free
deb-src http://ftp.us.debian.org/debian jessie main contrib non-free
# Updates Debian Jessie "8"
deb http://ftp.us.debian.org/debian jessie-updates main contrib non-free
deb-src http://ftp.us.debian.org/debian jessie-updates main contrib non-free
# Updates Security Debian Jessie "8"
deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free

apt-get update && apt-get upgrade --y

cd /home/dindin/hacktrack/
sudo cp chroot/boot/vmlinuz-3.16.0-4-586 image/live/vmlinuz
sudo cp chroot/boot/initrd.img-3.16.0-4-586 image/live/initrd.lz 
sudo cp /usr/lib/syslinux/isolinux.bin image/isolinux/

cd /home/dindin/hacktrack/
# STANDAR
sudo mksquashfs chroot image/live/filesystem.squashfs
# UNKNOW
sudo mksquashfs chroot image/live/filesystem.squashfs -e boot
# HIGH COMPRESS
sudo mksquashfs chroot image/live/filesystem.squashfs -b 1048576 -comp xz -Xdict-size 100%

sudo su
sudo chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' > image/live/filesystem.manifest
printf $(sudo du -sx --block-size=1 chroot | cut -f1) > image/live/filesystem.size
exit

cd image/
sudo rm MD5SUMS
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee MD5SUMS
cd ..
sudo mkisofs -r -V "hacktrack-2017.1-i386" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../hacktrack-2017.1CORE-i386.iso image
cd .. && sudo chmod 777 hacktrack-2017.1-i386.iso
isohybrid hacktrack-2017.1-i386.iso
md5sum hacktrack-2017.1-i386.iso > hacktrack-2017.1-i386.iso.md5sums
