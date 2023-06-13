#!/bin/sh

set -e

# check
tSetupFiles="$(type setupFiles|head -n 1|grep function|cat)"
if [ ! -n "$tSetupFiles" ]; then
    echo "Have to define setupFiles method first."
    exit;
fi
tConfigGrub="$(type configGrub|head -n 1|grep function|cat)"
if [ ! -n "$tConfigGrub" ]; then
    echo "Have to define configGrub method first."
    exit;
fi

# check
if [ ! -n "$grubImgVersion" ];then
    echo "Have to define grubImgVersion first"
    exit;
fi
if [ ! -n "$grubImgSize" ];then
    echo "Have to define grubImgSize first"
    exit;
fi
if [ ! -n "$targetDev" ];then
    echo "Have to define targetDev first"
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
