# FIXME: correct loadaddr for QEMU uboot case
setenv loadaddr 0x1F000000
fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs
ext2load mmc 0:1 ${loadaddr} bootargs.itb
bootm start
fdt move ${fdt_addr} ${fdt_addr_r}
bootm loados
ootm ramdisk
bootm fdt
bootm prep
bootm go
