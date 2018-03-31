#!/bin/bash

#######################################################################
##	Script: config.sh
##	Desc: Used to hold and report the variables used between the 
##			deboostrap.sh and install.sh scripts.
##	Usage: ./config.sh <variable name>
#######################################################################

# Get the script location
BASE=$(pwd)

########### INSTALL VALUES ###################

# Temp directory to use during install
TMP="${BASE}/stretch-rootfs"

# Mount point to use for boot partition
BOOT_PARTITION_MOUNT="/mnt/boot"

# Mount point to use for rootfs
ROOTFS_PARTITION_MOUNT="/mnt/fs"

# Label to use for boot partition
BOOT_DISK_LABEL="BOOT"

# Label to use for rootfs
ROOTFS_DISK_LABEL="ROOTFS"


########## DEBOOTSTRAP VALUES ################

# Directory to place debootstrap rootfs in
DEBOOTSTRAP="${BASE}/stretch"

# Filename to use when zipping rootfs into tar
DEBOOTSTRAP_TAR="${DEBOOTSTRAP}-armel.tar.gz"

# Options to pass to debootstrap process
DEBOOTSTRAP_OPTIONS="--foreign"

# Package repository  to use
PACKAGE_REPO="http://ftp.us.debian.org/debian"

# Target distro
DISTRO="stretch"

# Arch to use
ARCH="armel"


############ HOST VALUES #######################

# Host's qemu binary file name
QEMU_BINARY="qemu-arm-static"

# Host's qemu binary containing path
QEMU_HOST_PARENT="/usr/bin"

# Filename of script to run within chroot environment
CHROOT_SCRIPT="additional-packages.sh"

# Parent path to chroot script
CHROOT_SCRIPT_PARENT="${BASE}/chroot-scripts"

# Path to overlay directory to apply to rootfs
OVERLAY_DIR=""

# Path to overlay applied before running chroot script
PRESECONDARY_OVERLAY=""



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
	;;
"TMP")
	echo "${TMP}"
	;;
"BOOT_PARTITION_MOUNT")
	echo "${BOOT_PARTITION_MOUNT}"
	;;
"ROOTFS_PARTITION_MOUNT")
	echo "${ROOTFS_PARTITION_MOUNT}"
	;;
"BOOT_DISK_LABEL")
	echo "${BOOT_DISK_LABEL}"
	;;
"ROOTFS_DISK_LABEL")
	echo "${ROOTFS_DISK_LABEL}"
	;;
"DEBOOTSTRAP")
	echo "${DEBOOTSTRAP}"
	;;
"DEBOOTSTRAP_TAR")
	echo "${DEBOOTSTRAP_TAR}"
	;;
"DEBOOTSTRAP_OPTIONS")
	echo "${DEBOOTSTRAP_OPTIONS}"
	;;
"PACKAGE_REPO")
	echo "${PACKAGE_REPO}"
	;;
"DISTRO")
	echo "${DISTRO}"
	;;
"ARCH")
	echo "${ARCH}"
	;;
"QEMU_BINARY")
	echo "${QEMU_BINARY}"
	;;
"QEMU_HOST_PARENT")
	echo "${QEMU_HOST_PARENT}"
	;;
"OVERLAY_DIR")
	echo "${OVERLAY_DIR}"
	;;
"PRESECONDARY_OVERLAY")
	echo "${PRESECONDARY_OVERLAY}"
	;;
esac
