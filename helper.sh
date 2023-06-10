#!/bin/sh

set -e

# check
tSetupFiles="$(type -t setupFiles)"
if [ $tSetupFiles != function ] && [ $tSetupFiles != "setupFiles" ]; then
    echo "You have to define setupFiles method before."
    exit -1;
fi
tConfigGrub="$(type -t configGrub)"
if [ tConfigGrub != function ] && [ $tConfigGrub != "configGrub" ]; then
    echo "You have to define configGrub method before."
    exit -1;
fi

grubImgVersion="$1"
grubImgSize="$2"
targetDev="$3"

# check
if [ ! -n "$grubImgVersion" ];then
	echo "You have to specific grubImgVersion at args 1"
    exit -1;
fi
if [ ! -n "$grubImgSize" ];then
	echo "You have to specific grubImgSize at args 2"
    exit -1;
fi
if [ ! -n "$targetDev" ];then
    targetDev=$(mount | grep "on / " | cut -d ' ' -f 1 | cut -d p -f 1)
fi

# enter RAM
mkdir -p tmp
mount -t tmpfs tmpfs -o size=100% tmp
cd tmp

# download image
wget https://github.com/gogogoghost/grub-img/releases/download/${grubImgVersion}/grub${grubImgSize}m.img.gz

# decompress
gunzip grub${grubImgSize}m.img.gz

# find a valid lo device
loDevice=$(losetup -f)

# mount it
mkdir boot
losetup -P $loDevice grub${grubImgSize}m.img
mount -t vfat ${loDevice}p1 boot

# setup files
setupFiles "$(pwd)/boot"

# generate grub.cfg
configGrub "$(pwd)/boot/grub/grub.cfg"

# umount
umount boot
losetup -d $loDevice

# real dd
dd if=grub${grubImgSize}m.img of=$targetDev

# reboot
sync
reboot