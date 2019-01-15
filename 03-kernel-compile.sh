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
	if [ -! -e "${CONFIG_SCRIPT}" ]; then
		Exit "Failed to find config script - Exiting..."
	fi
	CROSS_COMPILER_DEST=$(./${CONFIG_SCRIPT} CROSS_COMPILER_GIT) || Exit "Failed to get cross compiler location"
	FIRMWARE_DEST=$(./${CONFIG_SCRIPT} FIRMWARE_GIT) || Exit "Failed to get firmware location"
	KERNEL_DEST=$(./${CONFIG_SCRIPT} KERNEL_GIT) || Exit "Failed to get kernel location"
    KERNEL_ARG=$(./${CONFIG_SCRIPT} KERNEL_ARG) || Exit "Failed to get kernel argument"
    DEFCONFIG=$(./${CONFIG_SCRIPT} DEFCONFIG) || Exit "Failed to get kernel defconfig"
    J_OPTION=$(./${CONFIG_SCRIPT} J_OPTION) || Exit "Failed to get 'j' option"
    ARCH_TYPE=$(./${CONFIG_SCRIPT} ARCH_TYPE) || Exit "Failed to get ARCH type"
    COMPILE_PREFIX=$(./${CONFIG_SCRIPT} CROSS_COMPILE_PREFIX) || Exit "Failed to get cross compile prefix"
}

# Move to kernel source
cd "${KERNEL_DEST}"
# Ensure fresh start
sudo make mrproper
# Set the kernel to use
KERNEL="${KERNEL_ARG}"
# Compile the defconfig
make ARCH=${ARCH_TYPE} CROSS_COMPILE=${COMPILE_PREFIX} "${DEFCONFIG}"
# Compile evertyhing
make -j${J_OPTION} ARCH=${ARCH_TYPE} CROSS_COMPILE=${COMPILE_PREFIX} zImage modules dtbs