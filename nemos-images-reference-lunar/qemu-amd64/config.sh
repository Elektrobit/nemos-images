#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig

set -ex

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

#==================================
# Allow suid tools with busybox
#----------------------------------
chmod u+s /usr/bin/busybox

#==================================
# Delete initrd from kernel
#----------------------------------
# The kernel package provides some arbitrary initrd
rm -f /boot/initrd*
rm -f /boot/vmlinuz.old

#==================================
# Delete data not needed or wanted
#----------------------------------
rm -rf /var/backups
rm -rf /usr/share/man
rm -rf /usr/lib/x86_64-linux-gnu/gconv

#==================================
# Delete docs but retain copyright notices
#----------------------------------
find /usr/share/doc/ ! -iname copyright -delete 2> /dev/null || true

#==================================
# Create init symlink
#----------------------------------
rm -f /sbin/init
ln -rs /lib/systemd/systemd /sbin/init

#==================================
# Mask/Disable services
#----------------------------------
for service in \
    apt-daily.service \
    apt-daily.timer \
    apt-daily-upgrade.service \
    apt-daily-upgrade.timer \
    grub-common.service \
    grub-initrd-fallback.service \
    e2scrub_reap.service
do
    systemctl mask "${service}"
done

#======================================
# Activate services
#--------------------------------------
baseInsertService ssh
baseInsertService systemd-networkd
