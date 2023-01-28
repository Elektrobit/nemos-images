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

Create a custom `/etc/kiwi.yml`:

.. code:: yaml

    runtime_checks:
      - disable:
          - check_dracut_module_for_disk_overlay_in_package_list

    mapper:
      - part_mapper: kpartx

Call kiwi as follows:

.. code:: bash

    sudo kiwi-ng system build \
        --description PATH/TO/test-image-embedded-lunar/x86 \
        --target-dir /var/tmp/my_lunar

See the `test-image-embedded-lunar.run.sh` script from your git
checkout for details how to run the image in QEMU
