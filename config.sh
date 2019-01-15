#!/bin/bash

#######################################################################
##	Script: config.sh
##	Desc: Used to hold and report the variables used between the 
##			deboostrap.sh and install.sh scripts.
##	Usage: ./config.sh <variable name>
#######################################################################

# Get the script location
BASE=$(pwd)

########## DEBOOTSTRAP VALUES ################

# Target distro
DISTRO="stretch"

# Arch to use
ARCH="armel"

# Directory to place debootstrap rootfs in
DEBOOTSTRAP="${BASE}/stretch"

# Filename to use when zipping rootfs into tar
DEBOOTSTRAP_TAR="${DEBOOTSTRAP}-${ARCH}.tar.gz"

# Options to pass to debootstrap process
DEBOOTSTRAP_OPTIONS="--foreign"

# Package repository  to use
PACKAGE_REPO="http://ftp.us.debian.org/debian"

########### INSTALL VALUES ###################

# Mount point to use for boot partition
BOOT_PARTITION_MOUNT="/mnt/boot"

# Mount point to use for rootfs
ROOTFS_PARTITION_MOUNT="/mnt/fs"

# Label to use for boot partition
BOOT_DISK_LABEL="BOOT"

# Label to use for rootfs
ROOTFS_DISK_LABEL="ROOTFS"

# Temp directory to use during install
TMP="${BASE}/${DISTRO}-tmp"

############ HOST VALUES #######################

# Host's qemu binary file name
QEMU_BINARY="qemu-arm-static"

# Host's qemu binary containing path
QEMU_HOST_PARENT="/usr/bin"

# Path of script to run within chroot environment
CHROOT_SCRIPT="./chroot-script.sh"

# Path to overlay directory to apply to rootfs
OVERLAY_DIR="${BASE}/overlay"

############ KERNEL VALUES #####################

# Kernel argument for Pi 1, Zero, Zero W, and Compute
#   - specified: https://www.raspberrypi.org/documentation/linux/kernel/building.md
PI1_ARG=kernel
PI1_DEFCONFIG=bcmrpi_defconfig

# Kernel argument for Pi 2, 3, 3+, Compute 3
#   - specified: https://www.raspberrypi.org/documentation/linux/kernel/building.md
PI2=kernel7
PI2_DEFCONFIG=bcm2709_defconfig

# Kernel argument to use
KERNEL_ARG=$PI1_ARG

# Defconfig to use
DEFCONFIG=$PI1_DEFCONFIG

# Compiler 'j' option
J_OPTION=4

# Arch type
ARCH_TYPE=arm

# Subdirectory for kernel/cross compile tools
KERNEL_SOURCES="${BASE}/sources/"

# Set git values for the cross compiler tools
CROSS_COMPILER_REPO_NAME="tools"
CROSS_COMPILER_GIT="https://github.com/raspberrypi/${CROSS_COMPILER_REPO_NAME}.git"
CROSS_COMPILER_GIT_DEPTH=1
CROSS_COMPILER_DEST="${KERNEL_SOURCES}/${CROSS_COMPILER_REPO_NAME}"
CROSS_COMPILE_PREFIX="${CROSS_COMPILER_DEST}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-"

# Set the git values for the firmware
FIRMWARE_REPO_NAME="firmware"
FIRMWARE_GIT="https://github.com/raspberrypi/${FIRMWARE_REPO_NAME}.git"
FIRMWARE_GIT_DEPTH=1
FIRMWARE_DEST="${KERNEL_SOURCES}/${FIRMWARE_REPO_NAME}"

# Set the git values for the kernel source
KERNEL_REPO_NAME="linux"
KERNEL_GIT="https://github.com/raspberrypi/${KERNEL_REPO_NAME}.git"
KERNEL_GIT_DEPTH=1
KERNEL_DEST="${KERNEL_SOURCES}/${KERNEL_REPO_NAME}"

########################################################################

# Get the passed value
REQUESTED_VALUE=$1

# Exit if no value passed
if [ ${#REQUESTED_VALUE} == 0 ]; then
	exit 1
fi

# Switch on what was requested
case ${REQUESTED_VALUE} in
"BASE")
	echo "${BASE}"
	exit 0
	;;
"TMP")
	echo "${TMP}"
	exit 0
	;;
"BOOT_PARTITION_MOUNT")
	echo "${BOOT_PARTITION_MOUNT}"
	exit 0
	;;
"ROOTFS_PARTITION_MOUNT")
	echo "${ROOTFS_PARTITION_MOUNT}"
	exit 0
	;;
"BOOT_DISK_LABEL")
	echo "${BOOT_DISK_LABEL}"
	exit 0
	;;
"ROOTFS_DISK_LABEL")
	echo "${ROOTFS_DISK_LABEL}"
	exit 0
	;;
"DEBOOTSTRAP")
	echo "${DEBOOTSTRAP}"
	exit 0
	;;
"DEBOOTSTRAP_TAR")
	echo "${DEBOOTSTRAP_TAR}"
	exit 0
	;;
"DEBOOTSTRAP_OPTIONS")
	echo "${DEBOOTSTRAP_OPTIONS}"
	exit 0
	;;
"PACKAGE_REPO")
	echo "${PACKAGE_REPO}"
	exit 0
	;;
"DISTRO")
	echo "${DISTRO}"
	exit 0
	;;
"ARCH")
	echo "${ARCH}"
	exit 0
	;;
"QEMU_BINARY")
	echo "${QEMU_BINARY}"
	exit 0
	;;
"QEMU_HOST_PARENT")
	echo "${QEMU_HOST_PARENT}"
	exit 0
	;;
"CHROOT_SCRIPT")
	echo "${CHROOT_SCRIPT}"
	exit 0
	;;
"CHROOT_SCRIPT_PARENT")
	echo "${CHROOT_SCRIPT_PARENT}"
	exit 0
	;;
"OVERLAY_DIR")
	echo "${OVERLAY_DIR}"
	exit 0
	;;
"CROSS_COMPILER_DEST")
	echo "${CROSS_COMPILER_DEST}"
	exit 0
	;;
"CROSS_COMPILER_GIT")
	echo "${CROSS_COMPILER_GIT}"
	exit 0
	;;
"CROSS_COMPILER_GIT_DEPTH")
	echo "${CROSS_COMPILER_GIT_DEPTH}"
	exit 0
	;;
"FIRMWARE_DEST")
	echo "${FIRMWARE_DEST}"
	exit 0
	;;
"FIRMWARE_GIT")
	echo "${FIRMWARE_GIT}"
	exit 0
	;;
"FIRMWARE_GIT_DEPTH")
	echo "${FIRMWARE_GIT_DEPTH}"
	exit 0
	;;
"KERNEL_DEST")
	echo "${KERNEL_DEST}"
	exit 0
	;;
"KERNEL_GIT")
	echo "${KERNEL_GIT}"
	exit 0
	;;
"KERNEL_GIT_DEPTH")
	echo "${KERNEL_GIT_DEPTH}"
	exit 0
	;;
"KERNEL_ARG")
	echo "${KERNEL_ARG}"
	exit 0
	;;
"DEFCONFIG")
	echo "${DEFCONFIG}"
	exit 0
	;;
"J_OPTION")
	echo "${J_OPTION}"
	exit 0
	;;
"CROSS_COMPILE_PREFIX")
	echo "${CROSS_COMPILE_PREFIX}"
	exit 0
	;;
"ARCH_TYPE")
	echo "${ARCH_TYPE}"
	exit 0
	;;
esac

echo "Failed to find '${REQUESTED_VALUE}' - Exiting"
exit 1