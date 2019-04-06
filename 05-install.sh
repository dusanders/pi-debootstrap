#!/bin/bash

#######################################################################
##	Script: 05-install.sh
##	Desc: Used to flash the sdcard with the debootstrapped rootfs 
##	Usage: ./05-install.sh <SD Card block device>
#######################################################################

#######################################################

# Script that contains the needed variables
CONFIG_SCRIPT="config.sh"

# Get the pass SD Card block device
SDCARD=$1

#######################################################

########## SUPPORTING FUNCTIONS #######################

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

##
## Function to initialize the variables needed
##
function GetVars()
{
	# Check for args
	if [ ${#SDCARD} == 0 ]; then
		Exit "No SD Card specified"
	fi
	if [ ! -e "${CONFIG_SCRIPT}" ]; then
		Exit "Failed to find config script - Exiting..."
	fi
	BOOT_BLOCK_DEV="${SDCARD}1"
	ROOTFS_BLOCK_DEV="${SDCARD}2"
	BASE=$(./${CONFIG_SCRIPT} BASE) || Exit "Failed to parse base directory"
	DEBOOTSTRAP_TAR=$(./${CONFIG_SCRIPT} DEBOOTSTRAP_TAR) || Exit "Failed to parse debootstrap tar filename"
	DEBOOTSTRAP=$(./${CONFIG_SCRIPT} DEBOOTSTRAP) || Exit "Failed to parse debootstrap directory"
	TMP=$(./${CONFIG_SCRIPT} TMP) || Exit "Failed to parse temp directory"
	MODULES_TMP=$(./${CONFIG_SCRIPT} MODULES_TMP) || Exit "Failed to get modules temp directory"
	BOOT_TMP=$(./${CONFIG_SCRIPT} BOOT_TMP) || Exit "Failed to get boot files"
	BOOT_PARTITION_MOUNT=$(./${CONFIG_SCRIPT} BOOT_PARTITION_MOUNT) || Exit "Failed to parse boot partition mount directory"
	ROOTFS_PARTITION_MOUNT=$(./${CONFIG_SCRIPT} ROOTFS_PARTITION_MOUNT) || Exit "Failed to parse rootfs partition mount directory"
	BOOT_DISK_LABEL=$(./${CONFIG_SCRIPT} BOOT_DISK_LABEL) || Exit "Failed to parse boot disk label"
	ROOTFS_DISK_LABEL=$(./${CONFIG_SCRIPT} ROOTFS_DISK_LABEL) || Exit "Failed to parse rootfs disk label"
	FIRMWARE_DEST=$(./${CONFIG_SCRIPT} FIRMWARE_DEST) || Exit "Failed to get firmware location"
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
## Function to display a question to the user and return 0 for 'y', 1 for 'n'
## Arguments: $1 - Question to display
##
function ReadUserBool()
{
	input=""
	while [ true ]; do
		Print "Question" "$1  (y or n)"
		read input
		if [ "${input}" == "y" ]; then
			return 0
		elif [ "${input}" == "n" ]; then
			return 1
		fi
	done
}

##
## Function to unmount the rootfs and boot block devices
##
function UnmountDevice()
{
	sudo sync
	sudo umount ${BOOT_BLOCK_DEV}
	sudo umount ${ROOTFS_BLOCK_DEV}
}

##
## Function to unmount the rootfs and boot partitions
##
function UnmountPartitions()
{
	sudo sync
	sudo umount "${BOOT_PARTITION_MOUNT}" || Exit "Failed to umount boot"
	sudo umount "${ROOTFS_PARTITION_MOUNT}" || Exit "Failed to umount rootfs"
}

##
## Function to mount the rootfs and boot partitions
##
function MountPartitions()
{
	sudo mount "${BOOT_BLOCK_DEV}" "${BOOT_PARTITION_MOUNT}" || Exit "Failed to mount boot"
	sudo mount "${ROOTFS_BLOCK_DEV}" "${ROOTFS_PARTITION_MOUNT}" || Exit "Failed to mount rootfs"
}

## 
## Function to format the rootfs and boot partitions
##
function FormatPartitions()
{
	sudo mkfs.msdos -F 32  ${BOOT_BLOCK_DEV} -n ${BOOT_DISK_LABEL}
	sleep 2
	sudo sync
	sudo mkfs.ext4 -b 4096 -L ${ROOTFS_DISK_LABEL} ${ROOTFS_BLOCK_DEV}
	sleep 2
	sudo sync
}

## 
## Function to write the boot and rootfs partition table
##
function WritePartitionTable()
{
	sudo fdisk ${SDCARD} << EOF
d

d

n
p
1
8192
212991
t
c
n
p
2
212992

p
w
EOF
	sleep 2
	sudo sync
}

##
## Function to copy the rootfs files into a tmp directory
##
function CopyToTemp()
{
	Print "Info" "Copy rootfs to tmp..."
	sudo cp -a "${DEBOOTSTRAP}"/* "${TMP}" || Exit "Failed to copy rootfs to tmp"
}

##
## Function to prompt user for removal of existing temp files
##
function PromptCleanTmpFiles()
{
	# See if user wishes to remove old temp files
	ReadUserBool "Remove old tmp?"

	# If they want to remove old build, start a new build
	if [ $? -eq 0 ]; then
		# Remove the old temp files
		Print "Info" "Remove old temp files..."
		sudo rm -rf "${TMP}"/*
	fi
}

##
## Function to use a rootfs tar - extracts tar to temp directory
##
function UseTar()
{
	# If we have an existing build - gather user input
	if (( $TMP_FILE_COUNT > 0 )); then
		PromptCleanTmpFiles
	fi
	Print "Info" "Extracting tar..."
	sudo tar -xf "${DEBOOTSTRAP_TAR}" -C "${TMP}" || Exit "Failed to extract rootfs tar"
}

##
## Function to use an uncompressed directory as the rootfs
##
function UseDebootstrap()
{
	if [ ! -d "${DEBOOTSTRAP}" ]; then
		Exit "No rootfs!"
	fi
	
	# Determine if we have any files in the tmp/previous build
	TMP_FILE_COUNT=$(ls ${TMP} | wc -l)

	# If we have an existing build - gather user input
	if (( $TMP_FILE_COUNT > 0 )); then
		PromptCleanTmpFiles
	else
		Print "Info" "Copy files to temp..."
		# Copy the files to the tmp location
		CopyToTemp
	fi
}

##
## Function to copy the provided firmware for Raspberry Pi
##
function CopyBootFirmware()
{
	sudo cp "${FIRMWARE_DEST}/boot/start"* "${BOOT_PARTITION_MOUNT}"
	sudo cp "${FIRMWARE_DEST}/boot/fixup"* "${BOOT_PARTITION_MOUNT}"
	sudo cp "${FIRMWARE_DEST}/boot/bootcode.bin" "${BOOT_PARTITION_MOUNT}"
}

##
## Function to copy the provided firmware for Raspberry Pi
##
function CopyOptionalFirmware()
{
	# Ensure directories
	sudo mkdir -p "${ROOTFS_PARTITION_MOUNT}/hardfp/opt/vc/"
	sudo mkdir -p "${ROOTFS_PARTITION_MOUNT}/opt/vc/"
	# Copy the firmware
	sudo cp -a "${FIRMWARE_DEST}/hardfp/opt/vc"/* "${ROOTFS_PARTITION_MOUNT}/opt/vc/"
	sudo cp -a "${FIRMWARE_DEST}/opt/vc"/* "${ROOTFS_PARTITION_MOUNT}/opt/vc/"
}
	
	

########################################################



#################### SCRIPT LOGIC ######################

# Get the variables from config
GetVars

# Ensure directories and files exists
if [ ! -e "${SDCARD}" ]; then
	Exit "ERROR" "Invalid SD Card location!"
fi
if [ ! -d "${TMP}" ]; then
	mkdir -p "${TMP}"
fi

# Check if we are using a tar
if (( ${#DEBOOTSTRAP_TAR} > 0 )); then
	if [ -e "${DEBOOTSTRAP_TAR}" ]; then
		UseTar
	else
		UseDebootstrap
	fi
else
	UseDebootstrap
fi

# Ensure boot partition mount point
if [ ! -d ${BOOT_PARTITION_MOUNT} ]; then
	sudo mkdir -p "${BOOT_PARTITION_MOUNT}"
fi

# Ensure rootfs parition mount point
if [ ! -d "${ROOTFS_PARTITION_MOUNT}" ]; then
	sudo mkdir -p "${ROOTFS_PARTITION_MOUNT}"
fi

# Ensure everything is unmounted
Print "Info" "Umounting devices..."
UnmountDevice

# Create the partition table
Print "Info" "Create Parition Table...."
WritePartitionTable

# Format the partitions
Print "Info" "Formatting partitions..."
FormatPartitions

# Mount the partitions
Print "Info" "Mounting partitions..."
MountPartitions

# Copy the boot firmware
CopyBootFirmware

# Copy the optional firmware
CopyOptionalFirmware

# Copy the boot files into boot partition
Print "Info" "Copy boot files to boot partition..."
sudo cp -r "${BOOT_TMP}"/* "${BOOT_PARTITION_MOUNT}" || Exit "Failed to copy boot files"
sudo sync

# Copy overlay boot files to boot partition
if [ -d "${TMP}/boot" ]; then
	Print "Info" "Copy boot overlay files to boot partition..."
	sudo cp -r "${TMP}/boot"/* "${BOOT_PARTITION_MOUNT}"
	sudo sync
	# Remove files from boot overlay to keep rootfs clean
	sudo rm -f "${TMP}/boot"/*
fi

# Copy over the rootfs
Print "Info" "Copy rootfs..."
sudo cp -a "${TMP}"/* "${ROOTFS_PARTITION_MOUNT}" || Exit "Failed to copy rootfs"
sudo sync

# Copy over the modules
Print "Info" "Copy modules..."
sudo cp -a "${MODULES_TMP}"/* "${ROOTFS_PARTITION_MOUNT}" || Exit "Failed to copy modules"
sudo sync

Print "Info" "Remove tmp files..."
sudo rm -rf "${TMP}"

Print "Info" "Umounting partitions..."
UnmountPartitions

Print "Info" "Done"
