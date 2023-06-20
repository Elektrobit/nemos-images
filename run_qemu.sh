#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -eo pipefail

RAM="1G"
SMP="2"
HOST_ARCH="$(uname -m)"
ARCH=""
VM_IMAGE=""
TELNET_PORT=""
SSH_PORT="10022"
DAEMONISE=""
PID_FILE=""

function print_usage {
	echo "$(basename "${0}"): run an EFI-based NemOS image using QEMU"
	echo "Made by the NemOS Team <nemos-team@lists.launchpad.net>"
	echo ""
	echo "Usage: $(basename "${0}") [-h][-?] -f <path> [-a arch] [-m memory] [-c cpus] [-s port] [-t port] [-p pid] [-d]"
	echo ""
	echo "  -h/-?: Print this help message"
	echo "  -f:    Path to VM image (required)"
	echo "  -a:    Guest architecture (defaults to ${HOST_ARCH})"
	echo "  -m:    Memory size (defaults to ${RAM})"
	echo "  -c:    Number of virtual CPUs (defaults to ${SMP})"
	echo "  -s:    Enable SSH access on the given port number (defaults to ${SSH_PORT})"
	echo "  -t:    Enable telnet console access on the given port number"
	echo "  -p:    Write the process PID to the given file"
	echo "  -d:    Daemonise the VM process"
}

while getopts "h?a:f:c:m:s:t:p:d" opt; do
	case "${opt}" in
	h | \?)
		print_usage
		exit 0
		;;
	a)
		ARCH="${OPTARG}"
		;;
	f)
		VM_IMAGE="${OPTARG}"
		;;
	m)
		RAM="${OPTARG}"
		;;
	c)
		SMP="${OPTARG}"
		;;
	t)
		TELNET_PORT="${OPTARG}"
		;;
	s)
		SSH_PORT="${OPTARG}"
		;;
	p)
		PID_FILE="${OPTARG}"
		;;
	d)
		DAEMONISE="1"
		;;
	esac
done

if [ -z "${VM_IMAGE}" ]; then
	print_usage
	exit 1
fi

# Use the host architecture if another wasn't specified
if [ -z "${ARCH}" ]; then
	ARCH="${HOST_ARCH}"
fi

case "${ARCH}" in
arm64)
	# Correct for mismatched arch naming scheme
	ARCH="aarch64"
	;&
aarch64)
	NVRAM_PATH="/usr/share/AAVMF/AAVMF_VARS.fd"
	EFI_PATH="/usr/share/AAVMF/AAVMF_CODE.fd"
	MACHINE="virt"
	QEMU_CPU="cortex-a53"
	TPM_DEVICE="tpm-tis-device"
	;;
amd64)
	# Correct for mismatched arch naming scheme
	ARCH="x86_64"
	;&
x86_64)
	NVRAM_PATH="/usr/share/OVMF/OVMF_VARS.fd"
	EFI_PATH="/usr/share/OVMF/OVMF_CODE.fd"
	MACHINE="q35"
	QEMU_CPU="qemu64"
	TPM_DEVICE="tpm-tis"
	;;
*)
	echo "Invalid architecture: ${ARCH}"
	echo "Please pick one of:"
	echo " - x86_64"
	echo " - aarch64"
	exit 1
	;;
esac

QEMU_CMD="qemu-system-${ARCH}"

# Enable acceleration if the host architecture matches and KVM is available
if [ "${HOST_ARCH}" = "${ARCH}" ] && kvm-ok > /dev/null; then
	echo "Enabling KVM acceleration"
	QEMU_ARGS="--enable-kvm --cpu host"
else
	echo "KVM acceleration not available"
	QEMU_ARGS="--cpu ${QEMU_CPU}"
fi

NVRAM=$(mktemp)
cp "${NVRAM_PATH}" "${NVRAM}"

if [ -z "${TELNET_PORT}" ]; then
	QEMU_ARGS="${QEMU_ARGS}
	-serial mon:stdio"
else
	echo "Telnet console access will be available on localhost port ${TELNET_PORT}"
	QEMU_ARGS="${QEMU_ARGS}
	-serial telnet:127.0.0.1:${TELNET_PORT},server,nowait"
fi

if [ -n "${PID_FILE}" ]; then
	QEMU_ARGS="${QEMU_ARGS}
	-pidfile ${PID_FILE}"
fi

if [ -n "${DAEMONISE}" ]; then
	QEMU_ARGS="${QEMU_ARGS}
	-daemonize"
fi

if command -v swtpm > /dev/null; then
	SWTPM_DIR=$(mktemp -d)
	SWTPM_PID=$(mktemp)
	QEMU_ARGS="${QEMU_ARGS}
	-chardev socket,id=chrtpm,path=${SWTPM_DIR}/swtpm-sock
	-tpmdev emulator,id=tpm0,chardev=chrtpm
	-device ${TPM_DEVICE},tpmdev=tpm0"
	swtpm socket --tpm2 -d -t \
		--tpmstate dir="${SWTPM_DIR}" \
		--ctrl type=unixio,path="${SWTPM_DIR}/swtpm-sock"
else
	echo "swtpm was not found; not adding a TPM device"
fi

echo "SSH access will be available on localhost port ${SSH_PORT}"
echo "Press ctrl-a then x to exit"

${QEMU_CMD} \
	${QEMU_ARGS} \
	-m "${RAM}" \
	--smp "${SMP}" \
	-M "${MACHINE}" \
	-parallel null -monitor none -display none -vga none \
	-drive file="${EFI_PATH}",readonly=on,if=pflash,format=raw,unit=0 \
	-drive file="${NVRAM}",if=pflash,format=raw,unit=1 \
	-netdev user,id=user0,hostfwd=tcp:127.0.0.1:"${SSH_PORT}"-:22 \
	-device virtio-net-pci,netdev=user0 \
	-object rng-random,filename=/dev/urandom,id=rng0 \
	-device virtio-rng-pci,rng=rng0 \
	-drive file="${VM_IMAGE}",if=virtio

rm "${NVRAM}"
if [ -n "${SWTPM_DIR}" ]; then
	rm -rf "${SWTPM_DIR}"
fi
