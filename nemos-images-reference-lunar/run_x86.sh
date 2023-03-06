#!/bin/bash

if [ -d /var/tmp/my_lunar ];then
    # target-dir used in README.rst
    pushd /var/tmp/my_lunar
fi

qemu-system-x86_64 \
    -m 1G \
    -nographic \
    -M q35 \
    -bios /usr/share/qemu/OVMF.fd \
    -netdev user,id=user0,hostfwd=tcp::10022-:22 \
    -device virtio-net-pci,netdev=user0 \
    -drive file=nemos-image-reference-lunar.x86_64-1.0.1.qcow2,if=virtio
