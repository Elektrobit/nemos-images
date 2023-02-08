#!/bin/dash

set -ex

#=======================================
# Set zstd as the default compression tool for dracut initrd images
#---------------------------------------

mkdir -p /etc/dracut.conf.d/
cat > /etc/dracut.conf.d/50-enable-zstd-compression.conf << EOF
compress="zstd"
EOF
