#! /usr/bin/env bash
# Adding second disk for SIEM
echo 'start=2048, type=83' | sfdisk /dev/sdb
mkfs.ext4 /dev/sdb1
echo "/dev/sdb1 /opt ext4 rw,relatime 0 0" | tee -a /etc/fstab
mount -a