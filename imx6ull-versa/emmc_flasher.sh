#!/bin/bash
#     
# Calixto Systems Pvt. Ltd. - Bengaluru	
# Script: emmc_flasher.sh
#
# This distribution contains contributions or derivatives under copyright
# as follows:
#
# Copyright (c) 2024-25 Calixto Systems Pvt. Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# - Neither the name of Calixto Systems nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=================================================================================

cat << EOM

##################################################################################

 This script will create a bootable eMMC for IMX6ULL-VERSA and IMX6ULL-TINY Boards 

 Run the script like given below an example

 Example:
  $ ./emmc_flasher.sh

##################################################################################

EOM

# Define the block device name & path. 
BLOCK=mmcblk1
DRIVE="/dev/$BLOCK"

# Function to check fdisk version.
check_fdisk_version() {
   
    # Get the current version of fdisk
    CUR_VERSION=$(sfdisk -v | awk {'print $NF'})
    echo " "
    echo " Current version of sfdisk : ${CUR_VERSION}"
    echo " "
    # Minimum required version
    REQUIRED_VERSION="2.26.3"
    
    # Compare versions
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$CUR_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        echo "Error: fdisk version must be >= $REQUIRED_VERSION. Current version is $CUR_VERSION."
        exit 1
    fi
}

# Check fdisk version
check_fdisk_version

echo " [Umounting all existing partition on $DRIVE...]"
echo " "

# Umount any partions on the device & supress error messages
umount "/dev/$BLOCK"p* &> /dev/null
umount "/media/$BLOCK"p* &> /dev/null

echo " [Creating Partition on $DRIVE...]"
echo " "

sudo sfdisk ${DRIVE} <<-__EOF__   
1M,,L,*
__EOF__

sleep 2 
echo " [syncing....]"
sync
sync


echo " [Done Partitioning.]"
# List the partition table to verify the changes 
fdisk $DRIVE -l

sleep 2
echo " [syncing....]"
sync
sync


echo " [Making filesystem...]"
umount "/dev/$BLOCK"p* &> /dev/null
sleep 2
echo " [syncing....]"
sync
sync

# Format the single partition 
mkfs.ext4 -L rootfs /dev/${BLOCK}p1

sleep 2
echo " [syncing....]"
sync
sync


echo " [Mounting Root Partition..]"
# Mount the new partition to /mnt
mount "$DRIVE"p1 /mnt

sleep 2
echo " [syncing....]"
sync
sync

echo " [Extracting the file systems..]"
tar -xvf rootfs.tar -C /mnt

echo " [Syncing....]"
sync
sync

echo " [Umounting root partition]"
umount /mnt
echo " "
echo " [Syncing....]"
sync
sync

echo " "
echo " eMMC Setup completed."
