setenv loadaddr 0x58000000
setenv bootargs "root=/dev/vda3 rootwait rw"
load virtio 0:1 ${loadaddr} bootargs.itb
bootm
