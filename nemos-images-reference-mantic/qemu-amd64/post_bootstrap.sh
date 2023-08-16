#!/bin/dash
# SPDX-License-Identifier: GPL-2.0-or-later

set -ex

mkdir -p /etc/dracut.conf.d/

#=======================================
# Set zstd as the default compression tool for dracut initrd images
# Do it early here rather than in the rootfs overlay so that dracut uses
# zstd during the build and doesn't waste time rebuilding gzip'd images
# several times.
#---------------------------------------

cat > /etc/dracut.conf.d/50-enable-zstd-compression.conf << EOF
compress="zstd"
EOF
