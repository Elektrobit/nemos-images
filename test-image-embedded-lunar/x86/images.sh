#!/bin/dash

set -ex

#=======================================
# Move coreutils to busybox
#---------------------------------------
# remove coreutils and others for which a busybox
# replacement exists
dpkg \
    --remove --force-remove-reinstreq \
    --force-remove-essential --force-depends \
coreutils tar

# copy tools from busybox
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
