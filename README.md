# pi-debootstrap
A set of scripts that will create a minimum useable rootfs from the Debian repositories.
 - Run the 'prereq.sh' script first to ensure the host machine has the required packages installed. Required packages are 'debootstrap' and 'qemu-user-static'.
 - (Optional) Run the 'pull-raspbian.sh' script to pull the current repos for the cross compiler tools, linux kernel, and firmware files. These are pulled from: https://github.com/raspberrypi
 - Adjust the 'config.sh' script values to point variables to proper locations on the host machine.
 - Run the 'debootstrap.sh' script to create the rootfs. 

    - The script is capable of running a script within a chroot environment in the rootfs. This is useful for installing or setting up custom packages before first boot. 
    - The script is capable of copying an overlay directory after initial creation; allowing customized files at first boot. 
    - The script can also apply an overlay before running the chroot script, this is useful for Raspbian as the apt sources.list will contain the Debian repositories after initial debootstrap process leading to errors when running apt-get commands during the chroot step. Using the presecondary overlay allows for copying a proper apt sources.list file into the rootfs before running the chroot script.

 - Run the 'install.sh' script and passing the SD Card block device to flash the rootfs and boot partitions. 

    - Recommend a blank SD Card block device be passed as the argument. The script will only remove the first two partitions of an SD Card, so cards with multiple partitions will fail.

# config.sh configuration
This script contains the values used by the debootstrap.sh and install.sh scripts. 

- BASE : Base working directory
- TMP : Path to the directory where temp files can be placed during the debootstrap/install process
- BOOT_PARTITION_MOUNT : Path to the directory where the boot partition will be mounted during the install process
- ROOTFS_PARTITION_MOUNT : Path to the directory where the rootfs partition will be mounted during the install process
- BOOT_DISK_LABEL : Value to be used as the label for the boot partition on the SD Card
- ROOTFS_DISk_LABEL : Value to be used as the label for the rootfs partition on the SD Card
- DEBOOTSTRAP : Path to the directory which will contain the debootstrap rootfs
- DEBOOTSTRAP_TAR : Full path to pass to 'tar' when building the rootfs tar file. Must end with the filename, <filename>.tar.gz
- DEBOOTSTRAP_OPTIONS : Options passed to 'debootstrap' when initializing the process. 
- PACKAGE_REPO : Main distro repository to use for the 'debootstrap' process.
- DISTRO : The desired distro that 'debootstrap' will attempt to pull.
- ARCH : The desired architecure that 'debootstrap' will attempt to pull.
- QEMU_BINARY : The filename of the qemu binary to use for chroot commands.
- QEMU_HOST_PARENT : The path to the directory which contains the qemu binary.
- CHROOT_SCRIPT : The script name that is to be run within chroot environment.
- CHROOT_SCRIPT_PARENT : The path to the directory which contains the script that will be run within the chroot environment.
- OVERLAY_DIR : The path to the directory which is to be copied over the rootfs after the debootstrap process completes.
- PRESECONDARY_OVERLAY : The path to the directory which is to be copied over the rootfs after the debootstrap secondary stage and before running the chroot script. So this will be copied over a completed debootstrap process but before the chroot environment is setup and the custom script run.

# Additional notes
The debootstrap process does not install required kernel, boot, and firmware files. These files should be placed in the overlay directory that is applied to the rootfs.
- Example
        
        ../overlay/boot/ : Contains the kernel.img, bootcode.bin, etc for the boot process 
        ../overlay/lib/modules/<kernel version>/ : Contains all the required kernel modules needed for the board
        ../overlay/opt/ : Contains the required user-space drivers needed for the board

The install process will copy the /boot/ files from the rootfs into the boot parition. This directory should contain all needed files for the boot process; kernel.img, bootcode.bin, etc.