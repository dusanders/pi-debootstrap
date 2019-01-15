#!/bin/bash

#######################################################################
##	Script: 02-pull-pi-linux.sh
##	Desc: Used to pull the Raspbian firmware and cross-compile tools.
##			This script only pulls the sources, the reader still has
##			to compile the kernel and adjust the values in the 
##			'config.sh' script to point to the proper firmwares, tools,
##			and compiled kernel.
##	Usage: ./02-pull-pi-linux.sh
#######################################################################

# Configuration script
CONFIG_SCRIPT="config.sh"

#######################################################################

##
## Function to set the variables from the configuration script
## 
function GetVars(){
	if [ -! -e "${CONFIG_SCRIPT}" ]; then
		Exit "Failed to find config script - Exiting..."
	fi
	KERNEL_SOURCES=$(./${CONFIG_SCRIPT} KERNEL_SOURCES) || Exit "Failed to get kernel source directory"
	CROSS_COMPILER_GIT=$(./${CONFIG_SCRIPT} CROSS_COMPILER_GIT) || Exit "Failed to get cross compiler git"
	CROSS_COMPILER_GIT_DEPTH=$(./${CONFIG_SCRIPT} CROSS_COMPILER_GIT_DEPTH) || Exit "Failed to get cross compiler git depth"
	FIRMWARE_GIT=$(./${CONFIG_SCRIPT} FIRMWARE_GIT) || Exit "Failed to get firmware git"
	FIRMWARE_GIT_DEPTH=$(./${CONFIG_SCRIPT} FIRMWARE_GIT_DEPTH) || Exit "Failed to get firmware git depth"
	KERNEL_GIT=$(./${CONFIG_SCRIPT} KERNEL_GIT) || Exit "Failed to get kernel git"
	KERNEL_GIT_DEPTH=$(./${CONFIG_SCRIPT} KERNEL_GIT_DEPTH) || Exit "Failed to get kernel git depth"
}

##
## Function to display a 'tag' and message to user
## Arguments : $1 - Tag value to display
##			   $2 - Message to display
##
function Print()
{
	echo ""
	echo "##########################################"
	echo "##   $1    :   $2"
	echo "##   FROM: $0"
	echo "##########################################"
}

##
## Function to display an error message and exit with error code
## Arguments : $1 - Message to display
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



# Ensure our directories
if [ ! -d "${KERNEL_SOURCE}" ]; then
	mkdir -p "${KERNEL_SOURCE}"
fi
cd "${KERNEL_SOURCE}"

git clone "${CROSS_COMPILER_GIT}" --depth=${CROSS_COMPILER_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone cross compiler tools"
fi

git clone "${FIRMWARE_GIT}" --depth=${FIRMWARE_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone firmware"
fi

git clone "${KERNEL_GIT}" --depth=${KERNEL_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone kernel"
fi

Print "Info" "Done"
