# nemos-image-reference-lunar

## Overview

Provides disk test build of a base reference image using standard
distro components. The image offers the following features:

* Hybrid GPT/MBR partition scheme
* EFI boot
* Readonly root partition with a read/write-capable overlay
* Option to build with various profiles
  * `default`: build with the default configuration using debootstrap
  * `bootstrapped`: build with a prebuilt rootfs bootstrap archive
  * `development`: similar to `bootstrapped`, with additional tools to aid
    development, such as `snapd`

## Storage Architecture

This reference image utilises a fairly complex storage architecture in order to
demonstrate many advanced storage features of both Kiwi and NemOS, which
includes the following features:

* Readonly squashfs root partition backed by `dm-verity`
* Read/write-capable XFS overlay for the root partition using `overlayfs`,
  encrypted with `dm-crypt` and backed by `dm-integrity`
* Additional read/write-capable XFS partition for OCI containers
* Additional read-only squashfs partition for preloaded OCI containers
* Small ext4 partition for `/home` which is independent of the overlayfs setup

The combined structure of the root filesystem is quite complicated, but
provides a number of benefits. Primarily, using a read/write-capable overlay
allows the target to easily be reset back to factory defaults and/or to a known
configuration, without reflashing the device. This specific constellation of
device mappings and mounts also provides high levels of protection against
normally invisible data corruption.

While SquashFS does provide some protection against data corruption through the
use of a checksum, `dm-verity` provides additional validation and security
protection against potential attackers by using block-level hash checks and a
cryptographic key to sign the data used to verify the integrity of the device.

The overlay partition encrypted with `dm-crypt` uses the insecure passphrase
`insecure`, which is only used for demonstration purposes and must be changed
before being included in production. The key is copied to
`/etc/cryptsetup-keys.d/luks.key` in the initramfs to facilitate automatic
unlocking. In a real-world scenario, this key would be provided by some
hardware key manager, such as a TPM or OP-TEE.

The underlying `dm-integrity` device is automatically created by `cryptsetup`
and provides a read/writable block-level integrity verification layer for the
read/write root overlay. This ensures that both the original SquashFS root
filesystem and the read/write overlay are protected against bit-rot and data
corruption.

The storage architecture of the root filesystem can be represented using the
following diagram:

```
            mount: /
            filesystem: overlayfs
        /                          \
        |                          |
    dm-verity                  dm-crypt
        |                          |
        |                    dm-integrity
        |                          |
PARTLABEL=p.lxreadonly     PARTLABEL=p.lxroot
filesystem: squashfs       filesystem: xfs
```

The `dm-verity` and `dm-crypt` device mappings are both set up during the
boot process by the initrd, which then also combines them using `overlayfs`.
The `dm-integrity` mapping is automatically handled by `cryptsetup` when the
`dm-crypt` device is opened.

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
