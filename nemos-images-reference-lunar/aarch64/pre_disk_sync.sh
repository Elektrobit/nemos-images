#!/bin/dash
# SPDX-License-Identifier: GPL-2.0-or-later

set -ex

#=======================================
# Create initrd link
#---------------------------------------
ln -s /boot/initrd-*-generic /boot/initrd

#=======================================
# Force delete packages not needed/wanted
#---------------------------------------
for package in \
    $(apt list --installed | grep ^linux-headers | cut -f 1 -d/) \
    $(apt list --installed | grep ^linux-modules-extra | cut -f 1 -d/) \
    linux-image-generic \
    linux-generic \
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
    libgmp10 \
    libgnutls30 \
    libstdc++6 \
    apt \
    python3 \
    python3.10 \
    python3-minimal \
    python3.10-minimal \
    perl-base \
    debianutils
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
