#!/bin/bash

#######################################################################
##	Script: chroot-script.sh
##	Desc: Executed within a chroot environment to automate tasks
##	Usage: ./chroot-script.sh
#######################################################################

# Install nano edditor
apt-get install nano

# Install OpenSSH server
apt-get install openssh openssh-server