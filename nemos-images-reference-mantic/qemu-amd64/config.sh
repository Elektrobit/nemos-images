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
rm -rf /usr/lib/*/gconv

#==================================
# Delete docs but retain copyright notices
#----------------------------------
find /usr/share/doc/ ! -iname copyright -delete 2> /dev/null || true

#======================================
# Activate services
#--------------------------------------
baseInsertService systemd-networkd

#======================================
# Install snaps when building with the development profile
#--------------------------------------

# The list of profiles is comma separated; change them to spaces to iterate
# over them.
for profile in ${kiwi_profiles//,/ }; do
    if [ "${profile}" = "development" ]; then
        # Use the preseeding feature of snapd to preload some snaps into the
        # system. This will download the snaps from the global Snap Store, copy
        # them to the snapd seed directory, and add each to the preseed YAML
        # file to instruct snapd to install them on first boot.
        # This requires network access to the Snap Store in Kiwi.
        mkdir -p /var/lib/snapd/seed
        echo "snaps": > /var/lib/snapd/seed/seed.yaml
        for snap in snapd checkbox22 checkbox checkbox-erlangen-classic core22; do
            snap download $snap
            # Add this new snap to the list of seeded snaps
            cat >> /var/lib/snapd/seed/seed.yaml << EOF
  - name: ${snap}
    channel: latest/stable
    file: $(ls ${snap}_*.snap)
EOF
            # Checkbox snap requires classic confinement mode
            if [ "${snap}" = "checkbox" ] || [ "${snap}" = "checkbox-erlangen-classic" ]; then
                cat >> /var/lib/snapd/seed/seed.yaml << EOF
    classic: true
EOF
            fi
        done

        # Copy the snap archives
        install -Dm0644 *.snap -t /var/lib/snapd/seed/snaps/
        # Copy the snap assertions (cryptographic signatures)
        install -Dm0644 *.assert -t /var/lib/snapd/seed/assertions/

        # Install the generic snapd model assertion so that the snaps can
        # be verified and snapd properly initialised.
        snap known --remote model series=16 brand-id=generic \
            model=generic-classic > /var/lib/snapd/seed/assertions/model
    fi
done

rm -f *.snap *.assert

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
