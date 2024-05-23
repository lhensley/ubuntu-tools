
########################################################################################################
#
# nuc01
#
########################################################################################################
#
# These are the known peripheral (including internal non-root filesystem drives) mounts
# as of 3/21/2022
#
# To show all devices, even unformatted:    sudo lsblk
#
# To format an entire device as ext, unmount it and issue this:
# sudo mkfs.ext4 -L new-volume-label /dev/yourpartitionhere
# Example: sudo umount /dev/sdh; sudo mkfs.ext4 -L 12TBB /dev/sdh
#
# To format a drive, use the command above to find /dev/yourpartitionhere
# Then:
#    sudo umount /dev/yourpartitionhere
#    sudo mkfs.ext4 /dev/yourpartitionhere
#        NOTE: The UUID will change!
#
# To find all UUIDs on connected devices: sudo blkid | grep UUID
# When possible, use the UUID and not PARTUUID.
#
######################################################################################################## 
#
# For entries below:
# Uncomment UUID definitions for local devices.
# Uncomment NFS definitions for remote devices.
#
########################################################################################################
#
# 12TBA (12TB) Black 12TB External Seagate
# Good condition; reliable
UUID=901c4177-b514-408a-997c-0cbeee89fa6e /mnt/12TBA ext4 auto,nofail 0 0
#
########################################################################################################
#
