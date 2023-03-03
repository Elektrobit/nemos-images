#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

if [ -d /var/tmp/my_lunar ];then
    # target-dir used in README.rst
    pushd /var/tmp/my_lunar
fi

qemu-system-aarch64 \
    -m 1G \
    -machine virt \
    -cpu cortex-a57 \
    -drive file=nemos-image-embedded-lunar.aarch64-1.0.1.qcow2,if=virtio,driver=qcow2,cache=off \
    -nographic \
    -bios /usr/lib/u-boot/qemu_arm64/u-boot.bin
