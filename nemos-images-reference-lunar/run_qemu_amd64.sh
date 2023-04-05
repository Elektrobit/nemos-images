#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

if [ -d /var/tmp/my_lunar ];then
    # target-dir used in README.rst
    pushd /var/tmp/my_lunar
fi

NVRAM=$(mktemp)
cp /usr/share/OVMF/OVMF_VARS.fd ${NVRAM}

qemu-system-x86_64 \
    -m 1G \
    --enable-kvm \
    --smp 2 \
    --cpu host \
    -nographic \
    -M q35 \
    -drive file="/usr/share/OVMF/OVMF_CODE.fd",readonly=on,if=pflash,format=raw,unit=0 \
    -drive file="${NVRAM}",if=pflash,format=raw,unit=1 \
    -netdev user,id=user0,hostfwd=tcp::10022-:22 \
    -device virtio-net-pci,netdev=user0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -drive file=nemos-image-reference-lunar.x86_64-1.0.1.qcow2,if=virtio

rm ${NVRAM}