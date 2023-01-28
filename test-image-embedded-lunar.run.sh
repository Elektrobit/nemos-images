#!/bin/bash

if [ -d /var/tmp/my_lunar ];then
    # target-dir used in README.rst
    pushd /var/tmp/my_lunar
fi

qemu-kvm \
    -m 4096 \
    -display none \
    -netdev user,id=user0,hostfwd=tcp::10022-:22 \
    -device virtio-net-pci,netdev=user0 \
    -serial stdio \
    -drive file=test-image-embedded-lunar.x86_64-1.0.1.qcow2,if=virtio
