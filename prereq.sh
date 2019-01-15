#!/bin/bash

#######################################################################
##	Script: prereq.sh
##	Desc: Used to prepare the host machine with needed packages for
##			the debootstrap process. 
##	Usage: ./prereq.sh
#######################################################################


##
## Function to display a 'tag' and message to user
## Arguments : $1 - Tag value to display
##			   $2 - Message to display
##
function Print() {
	echo ""
	echo "##########################################"
	echo "##   $1    :   $2"
	echo "##   FROM: $0"
	echo "##########################################"
}

Print "Info" "Installing prereq packages..."

sudo apt-get install debootstrap
sudo apt-get install qemu-user-static

Print "Info" "Done gathering prereq packages"
