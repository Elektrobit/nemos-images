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
