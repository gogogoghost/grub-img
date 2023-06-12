#!/bin/sh

set -e

# check
tSetupFiles="$(type -t setupFiles)"
if [ $tSetupFiles != function ] && [ $tSetupFiles != "setupFiles" ]; then
    echo "Have to define setupFiles method before."
    exit;
fi
tConfigGrub="$(type -t configGrub)"
if [ tConfigGrub != function ] && [ $tConfigGrub != "configGrub" ]; then
    echo "Have to define configGrub method before."
    exit;
fi

grubImgVersion="$1"
grubImgSize="$2"
targetDev="$3"

# check
if [ ! -n "$grubImgVersion" ];then
	echo "Have to specific grubImgVersion at arg 1"
    exit;
fi
if [ ! -n "$grubImgSize" ];then
	echo "Have to specific grubImgSize at arg 2"
    exit;
fi
if [ ! -n "$targetDev" ];then
    echo "Have to specific targetDev at arg 3"
    exit;
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
grubFile="$(pwd)/boot/grub/grub.cfg"
echo "set timeout=3" > $grubFile
configGrub $grubFile

# umount
umount boot
losetup -d $loDevice

# real dd
dd if=grub${grubImgSize}m.img of=$targetDev

# reboot
sync
reboot
