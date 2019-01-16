#!/bin/bash

#######################################################################
##	Script: chroot-script.sh
##	Desc: Executed within a chroot environment to automate tasks
##	Usage: ./chroot-script.sh
#######################################################################

# Install nano edditor
apt-get -y --allow-unauthenticated install nano

# Install OpenSSH server
apt-get -y --allow-unauthenticated install openssh-server

exit 0