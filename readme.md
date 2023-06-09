## Grub Image

Create a disk image with grub for VPS one click dd script.

---

Most one click dd script for VPS using existing grub bootloader.

This has some limitations on executing environment:
- No grub installed.
- Has another bootloader but not grub.

This repo create a disk image with grub.

### How to use
```bash
version=v1.2
# 32/64/128/256 support now
size=64

# enter RAM
mkdir tmp
mount -t tmpfs tmpfs -o size=100% tmp
cd tmp

# download image
wget https://github.com/gogogoghost/grub-img/releases/download/${version}/grub${size}m.img.gz

# decompress
gunzip grub${size}m.img.gz

# mount it
mkdir boot
losetup -P /dev/loop0 grub${size}m.img
mount -t vfat /dev/loop0p1 boot

# setup files
wget ${kernelUrl} -o boot/vmlinuz
wget ${initramfsUrl} -o boot/initramfs

# generate grub.cfg
echo "${grubContent}" > boot/grub/grub.cfg

# umount
umount boot
losetup -d /dev/loop0

# real dd
dd if=grub${size}m.img of=/dev/sda

# reboot
sync
reboot
```
