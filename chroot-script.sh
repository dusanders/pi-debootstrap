#!/bin/bash

#######################################################################
##	Script: chroot-script.sh
##	Desc: Executed within a chroot environment to automate tasks.
##          This script is executed within the chroot debootstrap environment
##          to provide additional setup during the build process
##	Usage: ./chroot-script.sh
#######################################################################

##
## Function to print a message to console
##
function Print()
{
    echo ""
    echo "################ INFO #################"
    echo ""
    echo "$1"
    echo ""
    echo "######################################"
    echo ""
}

##
## Function to add additional APT repositories. This is for Pi 1 and Zero
##
function AddRepos() 
{
    # Additional apt repos for Pi 1
    local additionalRepos="deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi firmware"

    # Add the repos to the sources.list
	echo "$additionalRepos" | tee -a "/etc/apt/sources.list"

    # Prompt info
    local repos=$(cat /etc/apt/sources.list)
    Print "Using repos: ${repos}"

    # Update apt
    apt-get update
}

##
## Function to install Node.js
##
function InstallNode() 
{
    local NODE_TAR="node-v11.9.0-linux-armv6l.tar.xz"
    local NODE_UNZIP="node-v11.9.0-linux-armv6l"
    wget "https://nodejs.org/dist/v11.9.0/${NODE_TAR}"
    Print "Extract ${NODE_TAR}"
    tar -xf "${NODE_TAR}"
    Print "Copy files..."
    cd "${NODE_UNZIP}"
    cp -a ./* /usr/local

    # Print out the version installed
    local node_version=$(node --version)
    Print "Using Node.js version: ${node_version}"

    # Clean up files
    Print "Clean up temp files..."
    cd ..
    rm "${NODE_TAR}"
    rm -rf "${NODE_UNZIP}"
    Print "Done with Node.js"
}

##
## Function to pull the non-free firmware from Raspbians github 
##
function GetNonFreeFirmware()
{
    # Clone the firmware repo
    Print "Cloning firmware..."
    git clone https://github.com/RPi-Distro/firmware-nonfree
    cd firmware-nonfree

    # Copy firmware files into place
    Print "Copy firmware"
    mkdir -p /lib/firmware/
    cp -a ./* /lib/firmware/
    sync

    # Clean up the cloned repo files
    cd /
    Print "Clean up"
    rm -rf firmware-nonfree
}

# Check for enabled en_US
LOCALE=$(cat /etc/locale.gen | grep -x "en_US.UTF-8 UTF-8")
if [ -z "${LOCALE}" ]; then
    
    Print "Adding en_US locale..."
    
    # Add default locale to gen file
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    
    # Generate the default locale
    locale-gen en_US.UTF-8
fi

# Add the raspbian repos
AddRepos

# Install Node.js
InstallNode

# Get the required firmware files
GetNonFreeFirmware

# Ensure everything wraps up
sync 

# Exit
exit 0