#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

qemu-system-aarch64 \
    -m 1G \
    --smp 2 \
    --cpu cortex-a53 \
    -nographic \
    -M virt \
    -pflash /usr/share/AAVMF/AAVMF_CODE.fd \
    -netdev user,id=user0,hostfwd=tcp::10022-:22 \
    -device virtio-net-pci,netdev=user0 \
    -drive file=nemos-image-reference-lunar.aarch64-1.0.1.qcow2,if=virtio

