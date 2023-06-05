#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

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

#=======================================
# Update OS information
#---------------------------------------
echo "VARIANT=\"NemOS\"" >> /usr/lib/os-release
echo "VARIANT_ID=\"nemos\"" >> /usr/lib/os-release
echo "IMAGE_ID=\"${kiwi_iname}\"" >> /usr/lib/os-release
echo "IMAGE_VERSION=\"${kiwi_iversion}\"" >> /usr/lib/os-release
echo "BUILD_ID=\"$(date -I -u)\"" >> /usr/lib/os-release
echo "NEMOS_HOME_URL=\"https://launchpad.net/nemos\"" >> /usr/lib/os-release
echo "NEMOS_BUG_REPORT_URL=\"https://bugs.launchpad.net/nemos\"" >> /usr/lib/os-release

#=======================================
# Correct netplan yaml permissions
#---------------------------------------
chmod go-rwx /etc/netplan/00-netplan.yaml
