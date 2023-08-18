# nemos-image-minimal-lunar

## NOTICE

These images are now deprecated! Use a newer release.

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

    sudo kiwi-ng --config PATH/TO/nemos-image-minimal-lunar/kiwi.yaml \
        system build \
        --description PATH/TO/nemos-image-minimal-lunar/qemu-amd64 \
        --target-dir /var/tmp/my_lunar

There are two ways of building the images: with debootstrap (default), or by
using a prebuilt bootstrap archive. The method used for building is determined
by the profiles feature of the Kiwi appliance definitions.

The default debootstrap method is useful for generating a clean build using
the most up-to-date packages sourced from the Ubuntu archives, while the
bootstrap method is useful for quick and reproducible builds.

To use the bootstrap method, add `--profile bootstrapped` to the Kiwi command
line call, immediately before `system build`. For example:

.. code:: bash

    sudo kiwi-ng --config PATH/TO/nemos-image-minimal-lunar/kiwi.yaml \
        --profile bootstrapped \
        system build \
        --description PATH/TO/nemos-image-minimal-lunar/qemu-amd64 \
        --target-dir /var/tmp/my_lunar

The debootstrap method can be used by either passing `--profile default` in the
same manner, or by omitting the profile parameter.

## How to run

### x86_64

Required packages:

* `qemu-system-x86_64`
* `ovmf` (UEFI firmware)

The `run_qemu.sh` script can be used to quickly execute the virtual machine with
the correct configuration.

### AArch64

Required packages:

* `qemu-system-aarch64`
* `qemu-efi-aarch64` (UEFI firmware)

The `run_qemu.sh` script can be used to quickly execute the virtual machine
with the correct configuration.
