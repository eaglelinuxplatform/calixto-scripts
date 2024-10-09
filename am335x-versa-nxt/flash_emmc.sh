#!/bin/sh
 
BLOCK=mmcblk1
DRIVE="/dev/$BLOCK"

echo "[Unmounting all existing partitions on $DRIVE... ]"

umount "/dev/$BLOCK"p* &> /dev/null
umount "/media/$BLOCK"p* &> /dev/null


echo "[Creating Partitions on $DRIVE...]"


#	fdisk
#			o   create a new empty DOS partition table
#			n   add a new partition
#			p   primary 
#			t   change a partition's system id
#			c   FAT32
#			w   write table to disk and exit

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

echo CYLINDERS - $CYLINDERS

echo "o
x
h
255
s
63
c
$CYLINDERS
r
n
p
1

+800M

t
c
n
p
2


w
" | fdisk $DRIVE &> /dev/null

sleep 1

echo "[Done Partitioning.]"
fdisk $DRIVE -l

sleep 1
echo "[Making filesystems...]"

umount "/dev/$BLOCK"p* &> /dev/null
sleep 1
umount "/media/$BLOCK"p* &> /dev/null
sleep 2
mkfs.vfat -F 32 -n boot /dev/mmcblk1p1 
sleep 2
mke2fs -t ext3 -L rootfs /dev/mmcblk1p2 -j

echo "[Mounting Root Partition..]"
mount "$DRIVE"p2 /mnt

echo "[Extracting Filesystem..]"
mkdir -p /media/mmcblk0p2
mount /dev/mmcblk0p2 /media/mmcblk0p2 &> /dev/null
cp -rf /media/mmcblk0p2/* /mnt

echo "[Syncing..]"
sync

echo "[Unmounting Root Partition]"
umount "$DRIVE"p2

fw_setenv boot_targets emmc

echo " "
echo "eMMC Setup completed."




