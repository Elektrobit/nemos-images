#!/bin/dash
# SPDX-License-Identifier: GPL-2.0-or-later

set -ex

#=======================================
# Create initrd link
#---------------------------------------
ln -svr /boot/initrd* /boot/initrd

#=======================================
# Copy bootloader files to /boot so they can be deleted from root later
#---------------------------------------
cp /usr/share/nemos/private.pem /boot/nemos-dev.key
cp /usr/lib/arm-trusted-firmware-s32/s32g274ardb2/fip.s32 /boot/

#=======================================
# Copy device tree and remove unused ones
#---------------------------------------
mv /lib/firmware/*/device-tree/freescale/s32g274a-rdb2.dtb /boot/dtb
rm -rf /lib/firmware/*/device-tree

#=======================================
# Force delete packages not needed/wanted
#---------------------------------------
for package in \
    $(apt list --installed | grep ^linux-headers | cut -f 1 -d/) \
    $(apt list --installed | grep ^linux-modules | cut -f 1 -d/) \
    linux-image-s32 \
    linux-s32 \
    linux-firmware \
    coreutils \
    tar \
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
    findutils \
    sed \
    grep \
    libparted2 \
    libdpkg-perl \
    libreadline8 \
    libksba8 \
    libgmp10 \
    libgnutls30 \
    apt \
    arm-trusted-firmware-s32 \
    debianutils \
    u-boot-tools \
    nemos-dev-key
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

#=======================================
# Remove all apt caches
#---------------------------------------
rm -rf /var/cache/apt
rm -rf /var/lib/apt/lists

#=======================================
# Make sure there are no source directories left behind
#---------------------------------------
rm -rf /usr/src
