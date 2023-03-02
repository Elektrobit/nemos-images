#!/bin/bash
# update the root reference to use PARTUUID. For root on
# squashfs there is no other identifier. Usually this is
# done through grub mkconfig as part of the kiwi build process
# but by the time of its call the filesystem is already
# readonly and grub's os-prober also doesn't like root on
# a squashfs. Thus the setup is injected in an earlier stage
# as part of this sripting
#
set -ex

root_device=$2

loop_name=$(basename $root_device | cut -f 1-2 -d'p')

disk_device=/dev/${loop_name}

# mount boot part
boot=$(mktemp -d /tmp/bootmount-XXX)
mount /dev/mapper/${loop_name}p1 $boot || exit 1

# get root PARTUUID
root_partuuid=$(blkid -s PARTUUID -o value /dev/mapper/${loop_name}p3)

# write grub setup
mkdir -p $boot/grub
cat << EOF > $boot/grub/grub.cfg
set default=1
set timeout=2
set timeout_style=menu
set gfxmode=auto

menuentry "Boot System" --class os --unrestricted {
    set gfxpayload=keep

    echo 'Loading kernel...'
    linux (hd0,1)/boot/vmlinuz root=overlay:PARTUUID=$root_partuuid console=ttyS0 rd.root.overlay.readonly init=/usr/lib/systemd/systemd
    echo  'Loading initial ramdisk...'
    initrd (hd0,1)/boot/initrd
}
EOF

# umount boot part
umount $boot && rmdir $boot
