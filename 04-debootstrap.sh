#!/bin/bash

#######################################################################
##	Script: 04-debootstrap.sh
##	Desc: Used to prepare a minimum useable rootfs via the 'deboostrap'
##			package from Debian.
##	Usage: ./04-debootstrap.sh
#######################################################################

#######################################################

# Script that contains the variables needed
CONFIG_SCRIPT="config.sh"

#######################################################

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
	
	# Ensure a clean exit
	EndChrootEnvironment
	
	exit 1
}

## 
## Function to initialize all variables using the 'config script'
##
function GetVars()
{
	if [ ! -e "${CONFIG_SCRIPT}" ]; then
		Exit "Failed to find config script - Exiting..."
	fi

	BASE=$(./${CONFIG_SCRIPT} BASE) || Exit "Failed to parse base directory"
	DEBOOTSTRAP=$(./${CONFIG_SCRIPT} DEBOOTSTRAP) || Exit "Failed to parse debootstrap directory"
	DEBOOTSTRAP_TAR=$(./${CONFIG_SCRIPT} DEBOOTSTRAP_TAR) || Exit "Failed to parse debootstrap tar value"
	DEBOOTSTRAP_OPTIONS=$(./${CONFIG_SCRIPT} DEBOOTSTRAP_OPTIONS) || Exit "Failed to parse debootstrap options"
	PACKAGE_REPO=$(./${CONFIG_SCRIPT} PACKAGE_REPO) || Exit "Failed to parse package repo"
	DISTRO=$(./${CONFIG_SCRIPT} DISTRO) || Exit "Failed to parse distro"
	ARCH=$(./${CONFIG_SCRIPT} ARCH) || Exit "Failed to parse arch"
	QEMU_BINARY=$(./${CONFIG_SCRIPT} QEMU_BINARY) || Exit "Failed to parse qemu binary"
	QEMU_HOST_PARENT=$(./${CONFIG_SCRIPT} QEMU_HOST_PARENT) || Exit "Failed to parse qemu path"
	CHROOT_SCRIPT=$(./${CONFIG_SCRIPT} CHROOT_SCRIPT) || Exit "Failed to parse chroot script"
	OVERLAY_DIR=$(./${CONFIG_SCRIPT} OVERLAY_DIR) || Exit "Failed to parse overlay directory"
	PASSWORD=$(./${CONFIG_SCRIPT} PASSWORD) || Exit "Failed to get debootstrap root password"
	QEMU_HOST_PATH="${QEMU_HOST_PARENT}/${QEMU_BINARY}"
}

##
## Function to print a message
## Arguments: $1 - 'Tag' value to use
##			  $2 - Message to display
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
## Function to prompt user for y/n input. Exits 1 for 'no' - 0 for 'yes'
## Arguments: $1 - Message to display
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
## Function to setup the chroot environment. Creates the directories
##	/proc /dev /sys - mounts relevant filesystems. Copies the host's
##	qemu binary into rootfs
##
function SetupChrootEnvironment()
{
	# Ensure /proc/
	if [ ! -d "${DEBOOTSTRAP}/proc" ]; then
		sudo mkdir "${DEBOOTSTRAP}/proc" || Exit "Failed to create chroot ${DEBOOTSTRAP}/proc"
	fi
	
	# Ensure /dev/
	if [ ! -d "${DEBOOTSTRAP}/dev" ]; then
		sudo mkdir "${DEBOOTSTRAP}/dev" || Exit "Failed to create chroot ${DEBOOSTRAP}/dev"
	fi
	
	# Ensure /sys/
	if [ ! -d "${DEBOOTSTRAP}/sys" ]; then
		sudo mkdir "${DEBOOTSTRAP}/sys" || Exit "Failed to create chroot ${DEBOOTSTRAP}/sys"
	fi
	
	# Ensure /usr/bin
	if [ ! -d "${DEBOOTSTRAP}/usr/bin" ]; then
		sudo mkdir -p "${DEBOOTSTRAP}/usr/bin" || Exit "Failed to create chroot /usr/bin"
	fi
	
	sudo mount -t proc proc "${DEBOOTSTRAP}/proc/" || Exit "Failed to mount chroot proc"
	sudo mount -t sysfs sys "${DEBOOTSTRAP}/sys/" || Exit "Failed to mount chroot sysfs"
	sudo mount -o bind "/dev" "${DEBOOTSTRAP}/dev" || Exit "Failed to mount chroot dev"
	
	# Copy over the qemu binary
	sudo cp -a "${QEMU_HOST_PATH}" "${DEBOOTSTRAP}/usr/bin" || Exit "Failed to copy over the qemu binary"
}

## 
## Function to run the debootstrap secondary stage. Sets the password within
##	chroot. 
##
function RunDebootstrapSecondary()
{
	# Set the password of the root account
	sudo touch "${DEBOOTSTRAP}/pass"
	echo "root:${PASSWORD}" | sudo tee -a "${DEBOOTSTRAP}/pass"
	
	# Enter chroot - run secondary and set password
	sudo chroot "${DEBOOTSTRAP}" << EOF
/debootstrap/debootstrap --second-stage
chpasswd </pass
EOF
	# Remove password file
	sudo rm "${DEBOOTSTRAP}/pass"
	# Remove the debootstrap binary from rootfs
	sudo rm "${DEBOOTSTRAP}/debootstrap/debootstrap"
}

## 
## Function to clean the chroot environment. Unmounts relevant filesystems
##	and removes qemu binary from rootfs
##
function EndChrootEnvironment()
{
	# Umount the chroot directories
	sudo umount "${DEBOOTSTRAP}/proc" 2>/dev/null
	sudo umount "${DEBOOTSTRAP}/dev" 2>/dev/null
	sudo umount "${DEBOOTSTRAP}/sys" 2>/dev/null
	
	# Remove the qemu binary
	sudo rm "${DEBOOTSTRAP}/usr/bin/${QEMU_BINARY}" 2>/dev/null
}

##
## Function to execute the chroot script within rootfs
##
function ExecuteChrootScript()
{
	# Notify user and copy the script into rootfs
	Print "Info" "Copy chroot script..."
	sudo cp -a "${CHROOT_SCRIPT}" "${DEBOOTSTRAP}" || Exit "Failed to copy chroot script: ${CHROOT_SCRIPT}"
	
	# Notify user and enter chroot - execute script
	Print "Info" "Executing chroot script"
	cat << EOF | sudo chroot "${DEBOOTSTRAP}"
chmod +x ${CHROOT_SCRIPT}
./${CHROOT_SCRIPT}
exit
EOF
	# Remove the script from rootfs
	sudo rm "${DEBOOTSTRAP}/${CHROOT_SCRIPT}"
	# Notify user
	Print "Info" "Done with chroot"
}

##
## Function to create the initial debootstrap rootfs
##
function CreateDebootstrap()
{
	# Notify and create debootstrap directory
	Print "Info" "Create debootstrap directory"
	sudo mkdir "${DEBOOTSTRAP}" || Exit "Failed to create debootstrap directory"

	# Notify and start the initial debootstrap package downloads
	Print "Info" "Starting debootstrap for ${DISTRO}..."
	sudo debootstrap --arch "${ARCH}" $DEBOOTSTRAP_OPTIONS "${DISTRO}" "${DEBOOTSTRAP}" "${PACKAGE_REPO}" || Exit "Failed to create deboostrap"
	Print "Info" "Done with initial debootstrap process"
}

##
## Function to copy over the overlay
##
function CopyOverlay()
{
	Print "Info" "Applying overlay..."
	if [ ! -z $(ls ${OVERLAY_DIR}) ]; then
		sudo cp -a "${OVERLAY_DIR}"/* "${DEBOOTSTRAP}" || Exit "Failed to copy overlay to: ${DEBOOTSTRAP}"
	fi
	Print "Info" "Done applying overlay"
}

##
## Function to append apt repos to the sources list
##
function AppendRepos()
{
	Print "Info" "Adding additional APT repositories"
	echo "$MORE_REPOS" | sudo tee -a "${DEBOOTSTRAP}/etc/apt/sources.list"
	sudo chroot "${DEBOOTSTRAP}" << EOF
apt-get update
EOF
}

#################### SCRIPT LOGIC #####################

# Init all needed variables
GetVars

# Check for existing debootstrap directory
if [ -d "${DEBOOTSTRAP}" ]; then
	# Get the current number of files within the directory
	EXISTING_FILES=$(ls ${DEBOOTSTRAP} | wc -l)
	# If there are files within directory
	if (( EXISTING_FILES > 0 )); then
		# Prompt user if we should remove these files
		ReadUserBool "Remove previous deboostrap files?"
		## If they answered 'y'
		if [ $? -eq 0 ]; then
			# Notify and remove files
			Print "Info" "Remove old debootstrap..."
			sudo rm -rf "${DEBOOTSTRAP}" || Exit "Failed to remove old debootstrap"
			# Create the debootstrap rootfs
			CreateDebootstrap
		fi
	# There were no files in the directory
	else
		# Remove the empty directory
		sudo rmdir "${DEBOOTSTRAP}"
		# Create the debootstrap rootfs
		CreateDebootstrap
	fi
# Directory does not exist
else
	# Create the debootstrap rootfs
	CreateDebootstrap
fi

# Notify and setup chroot
SetupChrootEnvironment

# Check if we have a debootstrap binary in rootfs 
#	- If we don't have binary - assume secondary already ran
if [ -e "${DEBOOTSTRAP}/debootstrap/debootstrap" ]; then
	Print "Info" "Starting secondary debootstrap process for ${DISTRO}..."
	RunDebootstrapSecondary
fi

# Append any extra apt repos before running chroot script
AppendRepos

# Check for an additional chroot script to run
if (( ${#CHROOT_SCRIPT} > 0 )); then
	# Notify and run chroot script
	ExecuteChrootScript
fi

EndChrootEnvironment

# Check if we have an overlay directory - apply if we do
if (( ${#OVERLAY_DIR} > 0 ));then
	CopyOverlay
fi

# Determine if user wishes to tar debootstrap
ReadUserBool "Create tar of debootstrap?"
if [ $? -eq 0 ]; then
	# Check for existing tar and remove
	if [ -e "${DEBOOTSTRAP_TAR}" ]; then
		sudo rm "${DEBOOTSTRAP_TAR}"
	fi
	# Create the tar
	sudo tar czf "${DEBOOTSTRAP_TAR}" -C "${DEBOOTSTRAP}" .
	# Prompt if we should remove the debootstrap rootfs
	ReadUserBool "Remove debootstrap files?"
	if [ $? -eq 0 ];then
		Print "Info" "Remove debootstrap files..."
		sudo rm -rf "${DEBOOTSTRAP}"
	fi
fi

Print "Info" "Done"
exit 0
