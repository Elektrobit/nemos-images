# test-image-embedded-lunar

## Motivation

Provides disk test build of a minimal base image using standard
distro components and no initrd to boot. The image offers the
following layout:

* 128M size constraint
* read-only, compressed rootfs (squashfs) no write partition
* admin user
* network setup and ssh access
* standard linux components (e.g systemd)

## How To Build

Building these Ubuntu 23.04 based images requires running Kiwi inside of an
Ubuntu 23.04 based system. Kiwi to be able to mount and manipulate loop devices
while building the image, and many steps require root permissions. Some
container runtimes (such as LXD) do not allow access to loop devices for
security reasons, so Kiwi should generally be built inside a virtual machine or
natively. Alternatively, a privileged `docker` or `podman` container instance
can be used for building.

Required packages:

* `kiwi`
* `rsync`
* `xz-utils`
* `qemu-utils`
* `gdisk`
* `fdisk`
* `kpartx`
* `squashfs-tools`

The `kiwi.yaml` file included in this directory should be used as the config
file for building these images using Kiwi.

Call kiwi as follows:

.. code:: bash

    sudo kiwi-ng --config PATH/TO/test-image-embedded-lunar/kiwi.yaml \
        system build \
        --description PATH/TO/test-image-embedded-lunar/x86 \
        --target-dir /var/tmp/my_lunar

## How to run

### x86_64

Required packages:

* `qemu-system-x86_64` (plus KVM for better performance)

Use the following command line to boot the VM:

.. code:: bash

    qemu-system-x86_64 \
        -m 1G \
        -drive file=<path-to-file-here>.qcow2,if=virtio,driver=qcow2 \
        -nographic \
        -serial stdio

### aarch64

Required packages:

* `qemu-system-arm`
* `u-boot-qemu`

Use the following command line to boot the VM:

.. code:: bash

    qemu-system-aarch64 \
        -m 1G \
        -machine virt \
        -cpu cortex-a57 \
        -drive file=<path-to-file-here>.qcow2,if=virtio,driver=qcow2,cache=off \
        -nographic \
        -bios /usr/lib/u-boot/qemu_arm64/u-boot.bin
