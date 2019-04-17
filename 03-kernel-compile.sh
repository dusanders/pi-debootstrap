#!/bin/bash

#######################################################################
##	Script: 03-kernel-compile.sh
##	Desc: Compile the linux kernel
##	Usage: ./03-kernel-compile.sh
#######################################################################

# Configuration script
CONFIG_SCRIPT="config.sh"

#######################################################################

##
## Function to display a passed error message and exit 1
## Arguments: $1 - Message to display
##
function Exit()
{
	echo ""
	echo "##########################################"
	echo "##   ERROR    :   $1"
	echo "##   FROM: $0"
	echo "##########################################"	
	exit 1
}

##
## Function to set the variables from the configuration script
## 
function GetVars() 
{
	if [ ! -e "${CONFIG_SCRIPT}" ]; then
		Exit "Failed to find config script - Exiting..."
	fi
	CROSS_COMPILER_DEST=$(./${CONFIG_SCRIPT} CROSS_COMPILER_DEST) || Exit "Failed to get cross compiler location"
	FIRMWARE_DEST=$(./${CONFIG_SCRIPT} FIRMWARE_DEST) || Exit "Failed to get firmware location"
	KERNEL_DEST=$(./${CONFIG_SCRIPT} KERNEL_DEST) || Exit "Failed to get kernel location"
    KERNEL_ARG=$(./${CONFIG_SCRIPT} KERNEL_ARG) || Exit "Failed to get kernel argument"
    DEFCONFIG=$(./${CONFIG_SCRIPT} DEFCONFIG) || Exit "Failed to get kernel defconfig"
    J_OPTION=$(./${CONFIG_SCRIPT} J_OPTION) || Exit "Failed to get 'j' option"
    ARCH_TYPE=$(./${CONFIG_SCRIPT} ARCH_TYPE) || Exit "Failed to get ARCH type"
    COMPILE_PREFIX=$(./${CONFIG_SCRIPT} CROSS_COMPILE_PREFIX) || Exit "Failed to get cross compile prefix"
    BOOT_TMP=$(./${CONFIG_SCRIPT} BOOT_TMP) || Exit "Failed to get BOOT temp"
    MODULES_TMP=$(./${CONFIG_SCRIPT} MODULES_TMP) || Exit "Failed to get TMP directory"
	KERNEL_IMAGE=$(./${CONFIG_SCRIPT} KERNEL_IMAGE) || Exit "Failed to get kernel image type"
	KERNEL_OUTPUT=$(./${CONFIG_SCRIPT} KERNEL_OUTPUT) || Exit "Failed to get kernel output directory"
}

# Setup the variables
GetVars

# Clean previous build
if [ -d "${BOOT_TMP}" ]; then
    sudo rm -rf "${BOOT_TMP}"
fi
if [ -d "${MODULES_TMP}" ]; then
    sudo rm -rf "${MODULES_TMP}"
fi

# Move to kernel source
cd "${KERNEL_DEST}"
# Ensure fresh start
sudo make mrproper
# Set the kernel to use
#KERNEL="${KERNEL_ARG}"
# Compile the defconfig
make ARCH=${ARCH_TYPE} CROSS_COMPILE=${COMPILE_PREFIX} "${DEFCONFIG}"
# Compile evertyhing
sudo make -j${J_OPTION} ARCH=${ARCH_TYPE} CROSS_COMPILE=${COMPILE_PREFIX} "${KERNEL_IMAGE}" modules dtbs
# Install modules
mkdir -p "${MODULES_TMP}"
sudo make ARCH=${ARCH_TYPE} CROSS_COMPILE=${COMPILE_PREFIX} INSTALL_MOD_PATH="${MODULES_TMP}" modules_install

# Copy boot files
mkdir -p "${BOOT_TMP}/overlays"
if [ "$ARCH_TYPE" == "arm64" ]; then
	echo "Using $ARCH_TYPE"
	sudo cp arch/${ARCH_TYPE}/boot/${KERNEL_IMAGE} "${BOOT_TMP}/${KERNEL_ARG}.img"
	sudo cp arch/${ARCH_TYPE}/boot/dts/broadcom/*.dtb "${BOOT_TMP}"
	sudo cp arch/${ARCH_TYPE}/boot/dts/overlays/*.dtb* "${BOOT_TMP}/overlays"
	sudo cp arch/${ARCH_TYPE}/boot/dts/overlays/README "${BOOT_TMP}/overlays"
else
	sudo cp arch/${ARCH_TYPE}/boot/${KERNEL_IMAGE} "${BOOT_TMP}/${KERNEL_ARG}.img"
	sudo cp arch/${ARCH_TYPE}/boot/dts/*.dtb "${BOOT_TMP}"
	sudo cp arch/${ARCH_TYPE}/boot/dts/overlays/*.dtb* "${BOOT_TMP}/overlays"
	sudo cp arch/${ARCH_TYPE}/boot/dts/overlays/README "${BOOT_TMP}/overlays"
fi