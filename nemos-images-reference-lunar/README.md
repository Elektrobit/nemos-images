# nemos-image-reference-lunar

## Motivation

Provides disk test build of a base reference image using standard
distro components. The image offers the following layout:

* TODO

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
* `xfsprogs`
* `cryptsetup-bin`
* `ssl-cert`
* `dosfstools`
* `jing` (optional, for schema validation)

The `kiwi.yaml` file included in this directory should be used as the config
file for building these images using Kiwi.

Call kiwi as follows:

.. code:: bash

    sudo kiwi-ng --config PATH/TO/test-image-embedded-lunar/kiwi.yaml \
        system build \
        --description PATH/TO/test-image-embedded-lunar/x86 \
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

    sudo kiwi-ng --config PATH/TO/test-image-embedded-lunar/kiwi.yaml \
        --profile bootstrapped \
        system build \
        --description PATH/TO/test-image-embedded-lunar/x86 \
        --target-dir /var/tmp/my_lunar

The debootstrap method can be used by either passing `--profile default` in the
same manner, or by omitting the profile parameter.

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
