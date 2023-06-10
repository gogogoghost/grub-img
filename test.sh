#!/bin/sh

set -e

mirror="https://dl-cdn.alpinelinux.org/alpine/v3.18"
baseUrl="$mirror/releases/x86_64/netboot-3.18.0/"

setupFiles(){
    wget "$baseUrl/vmlinuz-virt" -O "$1/vmlinuz-virt"
    wget "$baseUrl/initramfs-virt" -O "$1/initramfs-virt"
}
configGrub(){
    cat > $1 << EOF
menuentry 'Alpine Linux' {
    linux /vmlinuz-virt alpine_repo="$mirror/main" modloop="$baseUrl/modloop-virt" modules="loop,squashfs" initrd="initramfs-virt"
    initrd /initramfs-virt
}
EOF
}

source ./helper.sh v1.2 64 $1