#!/bin/bash

#######################################################################
##	Script: chroot-script.sh
##	Desc: Executed within a chroot environment to automate tasks
##	Usage: ./chroot-script.sh
#######################################################################

##
## Function to install Node.js
##
function installNode() {
    # Get the setup script from nodesource
    curl -sL "https://deb.nodesource.com/setup_11.x" | bash -

    # Install Node.js
    apt-get install -y nodejs

    # Print out the version installed
    local node_version=$(node --version)
    echo "Using Node.js version: ${node_version}"
}

# Install locales
apt-get -y --allow-unauthenticated install locales

# Add default locale to gen file
echo "en_US UTF-8" >> /etc/locale.gen

# Generate the default locale
locale-gen en_US.UTF-8

# Update apt
apt-get -y --allow-unauthenticated update

# Install HTTPS transport for apt
apt-get -y --allow-unauthenticated install apt-transport-https

# Install nano edditor
apt-get -y --allow-unauthenticated install nano

# Install OpenSSL
apt-get -y --allow-unauthenticated install openssl

# Install OpenSSH server
apt-get -y --allow-unauthenticated install openssh-server

# Install curl util
apt-get -y --allow-unauthenticated install curl

# Install tar xz tools
apt-get -y --allow-unauthenticated install xz-utils

# Install build tools for Node.js
apt-get -y --allow-unauthenticated install gcc g++ make

# Install Node.js
installNode

exit 0