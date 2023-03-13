# nemos-image-reference-lunar

## Overview

Provides disk test build of a base reference image using standard
distro components. The image offers the following features:

* Hybrid GPT/MBR partition scheme
* EFI boot
* Readonly squashfs root partition backed by `dm-verity`
* Read/write-capable XFS overlay for the root partition backed by `dm-verity`
* Additional read/write-capable XFS partition for OCI containers
* Additional read-only squashfs partition for preloaded OCI containers
* Option to build with various profiles
  * `default`: build with the default configuration using debootstrap
  * `bootstrapped`: build with a prebuilt rootfs bootstrap archive
  * `development`: similar to `bootstrapped`, with additional tools to aid
    development, such as `snapd`

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
* `jing` (optional, for Kiwi XML schema validation during development)

The `kiwi.yaml` file included in this directory should be used as the config
file for building these images using Kiwi.

Call kiwi as follows:

```
sudo kiwi-ng --config PATH/TO/test-image-reference-lunar/kiwi.yaml \
    system build \
    --description PATH/TO/test-image-reference-lunar/x86 \
    --target-dir /var/tmp/my_lunar
```

There are two ways of building the images: with debootstrap (default), or by
using a prebuilt bootstrap archive. The method used for building is determined
by the profiles feature of the Kiwi appliance definitions.

The default debootstrap method is useful for generating a clean build using
the most up-to-date packages sourced from the Ubuntu archives, while the
bootstrap method is useful for quick and reproducible builds.

To use the bootstrap method, add `--profile bootstrapped` to the Kiwi command
line call, immediately before `system build`. For example:

```
sudo kiwi-ng --config PATH/TO/test-image-reference-lunar/kiwi.yaml \
    --profile bootstrapped \
    system build \
    --description PATH/TO/test-image-reference-lunar/x86 \
    --target-dir /var/tmp/my_lunar
```

The debootstrap method can be used by either passing `--profile default` in the
same manner, or by omitting the profile parameter.

The `development` profile can be used to add additional packages which aid
development and testing, such as `snapd`. This profile uses the same
bootstrap archive as the `bootstrapped` profile in order to provide quicker
build times.

## How to run

### x86_64

Required packages:

* `qemu-system-x86_64`
* `ovmf` (UEFI firmware)

The `run_x86.sh` script can be used to quickly execute the virtual machine with
the correct configuration.
