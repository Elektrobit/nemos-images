#!/bin/bash -ex

# Kiwi is incompatible with Grub 2.12 (as of Kiwi version 9.25.17)
# We need to install and configure it manually.

# Construct the EFI partition according to the standard Ubuntu layout using
# signed images.
install -vD usr/lib/shim/shimaa64.efi.signed.latest \
        boot/efi/EFI/BOOT/BOOTAA64.EFI
install -vD usr/lib/shim/shimaa64.efi.signed.latest \
        boot/efi/EFI/UBUNTU/SHIMAA64.EFI
install -vD usr/lib/shim/fbaa64.efi \
        boot/efi/EFI/BOOT/FBAA64.EFI
install -vD usr/lib/shim/mmaa64.efi \
        boot/efi/EFI/BOOT/MMAA64.EFI
install -vD usr/lib/shim/BOOTAA64.CSV \
        boot/efi/EFI/UBUNTU/BOOTAA64.CSV
install -vD usr/lib/grub/arm64-efi-signed/grubaa64.efi.signed \
        boot/efi/EFI/UBUNTU/GRUBAA64.EFI

# Tell Grub to load its config from the BOOT partition
cat > boot/efi/EFI/UBUNTU/grub.cfg << EOF
search.fs_label BOOT root
set prefix=(\$root)'/grub'
configfile \$prefix/grub.cfg
EOF

# Install Grub modules
mkdir -p /boot/grub
cp -rv usr/lib/grub/arm64-efi/*.mod boot/grub/

# Basic Grub configuration to load the kernel and initrd
KERNEL="$(basename boot/vmlinuz-*)"
INITRD="$(basename boot/initrd.img-*)"
cat > boot/grub/grub.cfg << EOF
linux /${KERNEL} console=ttyS0 rd.systemd.verity=1 root=overlay:MAPPER=verityRoot verityroot=/dev/disk/by-partlabel/p.lxreadonly rd.root.overlay.write=/dev/mapper/luks rd.luks=yes pstore.backend=efi selinux=0
initrd /${INITRD}
boot
EOF
