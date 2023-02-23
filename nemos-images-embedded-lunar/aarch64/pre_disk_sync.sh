#!/bin/dash

set -ex

#=======================================
# Create initrd link
#---------------------------------------
ln -s /boot/initrd-*-generic /boot/initrd

#=======================================
# Get device tree for QEMU boot
#---------------------------------------
qemu-system-aarch64 -nographic \
    -cpu cortex-a57 \
    -m 1G \
    -bios /usr/lib/u-boot/qemu_arm64/u-boot.bin \
    -machine virt \
    -machine dumpdtb=/boot/qemu.dtb

#=======================================
# Create fit image
#---------------------------------------
(
    cd /boot
    mkimage -f bootargs.its bootargs.itb
)
rm /boot/System.map*
rm /boot/initrd*
rm /boot/vmlinuz*
rm /boot/qemu.dtb

#==========================================
# create boot.scr read by u-boot
#------------------------------------------
mkimage -A arm64 -O linux -T script -C none -d /boot/boot.cmd \
    /boot/boot.scr

#=======================================
# Force delete packages not needed/wanted
#---------------------------------------
for package in \
    linux-modules-5.19.0-21-generic \
    linux-modules-extra-5.19.0-21-generic \
    linux-headers-5.19.0-21 \
    linux-firmware \
    coreutils \
    tar \
    dmsetup \
    cpio \
    dracut \
    dracut-core \
    gcc-9-base \
    gcc-10-base \
    gcc-11-base \
    kpartx \
    pkg-config \
    perl \
    readline-common \
    gpgsm \
    gnupg-utils \
    dirmngr \
    gpgconf \
    gpg \
    bash \
    findutils \
    sed \
    grep \
    libparted2 \
    libdpkg-perl \
    libreadline8 \
    libksba8 \
    libtasn1-6 \
    libgmp10 \
    libgnutls30 \
    libstdc++6 \
    apt \
    python3 \
    python3.10 \
    python3-minimal \
    python3.10-minimal \
    perl-base \
    debianutils \
    qemu-system-arm \
    ipxe-qemu
do
    rm -f /var/lib/dpkg/info/${package}*.pre*
    rm -f /var/lib/dpkg/info/${package}*.post*
    packages_to_delete="${packages_to_delete} ${package}"
done
dpkg \
    --remove --force-remove-reinstreq \
    --force-remove-essential --force-depends \
${packages_to_delete}

#=======================================
# Move coreutils to busybox
#---------------------------------------
for file in $(busybox --list);do
    if [ "${file}" = "busybox" ]; then
        continue
    fi
    if [ "${file}" = "init" ]; then
        # we don't want the init from busybox
        continue
    fi
    busybox rm -f /bin/$file
    busybox ln /usr/bin/busybox /bin/$file || true
done

#=======================================
# Create /etc/hosts
#---------------------------------------
cat >/etc/hosts <<- EOF
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

#=======================================
# Create stub resolv.conf link
#---------------------------------------
# kiwi cleanup has dropped stale resolv.conf
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

#=======================================
# Relink /var/lib/dhcp to /run (rw)
#---------------------------------------
(cd /var/lib && rm -rf dhcp && ln -s /run dhcp)