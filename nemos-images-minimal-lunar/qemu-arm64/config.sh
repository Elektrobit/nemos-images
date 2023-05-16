#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig

set -ex

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
rm -rf /usr/share/i18n

#==================================
# Delete docs but retain copyright notices
#----------------------------------
find /usr/share/doc/ ! -iname copyright -delete 2> /dev/null || true

#======================================
# Activate services
#--------------------------------------
baseInsertService systemd-networkd
