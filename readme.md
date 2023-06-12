## Grub Image

Create a disk image with grub for VPS one click dd script.

---

Most one click dd script for VPS using existing grub bootloader.

This has some limitations on executing environment:
- No grub installed.
- Has another bootloader but not grub.

This repo create a disk image with grub.

### Image

There are several size prebuild images at [releases page](https://github.com/gogogoghost/grub-img/releases). Choose a image size you need.

The image contains a vfat partion with grub installed. Grub already used about 2M space, you can use left space.

### Usage

#### With helper

There is a simple script for alpine linux installation.

```bash
#!/bin/sh

set -e

mirror="https://dl-cdn.alpinelinux.org/alpine/v3.18"
baseUrl="$mirror/releases/x86_64/netboot-3.18.0/"

setupFiles(){
    wget "$baseUrl/vmlinuz-virt" -O "$1/vmlinuz-virt"
    wget "$baseUrl/initramfs-virt" -O "$1/initramfs-virt"
}
configGrub(){
    cat >> $1 << EOF
menuentry 'Alpine Linux' {
    linux /vmlinuz-virt alpine_repo="$mirror/main" modloop="$baseUrl/modloop-virt" modules="loop,squashfs" initrd="initramfs-virt"
    initrd /initramfs-virt
}
EOF
}

wget https://raw.githubusercontent.com/gogogoghost/grub-img/master/helper.sh
chmod +x helper.sh

# source ./helper.sh [grubImgVersion] [grubImgSize] [targetDevice]
source ./helper.sh v1.2 64 /dev/sda
```

#### Use Image Directly

Download image file and do it yourself.
