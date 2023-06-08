#!/bin/sh

set -e;

# image size
size=64;
if [ -n "$1" ];then
	size=$1
fi
imgName="grub${size}m.img"

# create empty image
dd if=/dev/zero of=$imgName bs=1M count=$size;

# parted
parted -s $imgName mklabel msdos
parted -s $imgName mkpart primary 1 100%

# find a loop device
loDev=$(losetup -f)

# format
losetup -P $loDev $imgName
mkfs.vfat ${loDev}p1

# mount
mkdir -p boot
mount ${loDev}p1 boot

# install grub
grub-install --target=i386-pc --boot-directory=boot $loDev

# umount
umount boot
losetup -d $loDev

# pack
gzip $imgName
