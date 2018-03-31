#!/bin/bash

#######################################################################
##	Script: pull-raspbian.sh
##	Desc: Used to pull the Raspbian firmware and cross-compile tools.
##			This script only pulls the sources, the reader still has
##			to compile the kernel and adjust the values in the 
##			'config.sh' script to point to the proper firmwares, tools,
##			and compiled kernel.
##	Usage: ./pull-raspbian.sh
#######################################################################

# Set git values for the cross compiler tools
CROSS_COMPILER_GIT="https://github.com/raspberrypi/tools.git"
CROSS_COMPILER_GIT_DEPTH=1
CROSS_COMPILER_DEST=$(pwd)

# Set the git values for the firmware
FIRMWARE_GIT="https://github.com/raspberrypi/firmware.git"
FIRMWARE_GIT_DEPTH=1
FIRMWARE_DEST=$(pwd)

# Set the git values for the kernel source
KERNEL_GIT="https://github.com/raspberrypi/linux.git"
KERNEL_GIT_DEPTH=1
KERNEL_DEST=$(pwd)


#######################################################################


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
if [ ! -d "${CROSS_COMPILER_DEST}" ]; then
	mkdir -p "${CROSS_COMPILER_DEST}"
fi
if [ ! -d "${FIRMWARE_DEST}" ]; then
	mkdir -p "${FIRMWARE_DEST}"
fi
if [ ! -d "${KERNEL_DEST}" ]; then
	mkdir -p "${KERNEL_DEST}"
fi


# Pull the repos
cd "${CROSS_COMPILER_DEST}"
git clone "${CROSS_COMPILER_GIT}" --depth=${CROSS_COMPILER_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone cross compiler tools"
fi

cd "${FIRMWARE_DEST}"
git clone "${FIRMWARE_GIT}" --depth=${FIRMWARE_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone firmware"
fi

cd "${KERNEL_DEST}"
git clone "${KERNEL_GIT}" --depth=${KERNEL_GIT_DEPTH}
if [ $? -ne 0 ]; then
	Exit "Failed to clone kernel"
fi

Print "Info" "Done"
