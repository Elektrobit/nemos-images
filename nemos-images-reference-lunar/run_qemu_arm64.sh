#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

NVRAM=$(mktemp)
cp /usr/share/AAVMF/AAVMF_VARS.fd ${NVRAM}

qemu-system-aarch64 \
    -m 1G \
    --smp 2 \
    --cpu cortex-a53 \
    -nographic \
    -M virt \
    -drive file="/usr/share/AAVMF/AAVMF_CODE.fd",readonly=on,if=pflash,format=raw,unit=0 \
    -drive file="${NVRAM}",if=pflash,format=raw,unit=1 \
    -netdev user,id=user0,hostfwd=tcp::10022-:22 \
    -device virtio-net-pci,netdev=user0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -drive file=nemos-image-reference-lunar.aarch64-1.0.1.qcow2,if=virtio

rm ${NVRAM}
