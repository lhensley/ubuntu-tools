
########################################################################################################
#
# oz
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
# nuc01
#
########################################################################################################
#
# 5TBE (5TB) Black 5TB External Seagate
# UUID=f8aad385-2d47-42aa-b62e-9a4afd024beb /mnt/5TBE ext4 nobootwait 0 0
nuc01:/mnt/5TBE /mnt/5TBE nfs rw,nobootwait
#
# 12TBB (12TB)
# UUID=27cf148b-4b43-4747-8a4f-e7013639b989 /mnt/12TBB ext4 nobootwait 0 0
nuc01:/mnt/12TBB /mnt/12TBB nfs rw,nobootwait
#
# bertha (3TB)
# UUID=d28256f9-c258-451e-b299-d4849cf19e0b /mnt/bertha ext4 nobootwait 0 0
nuc01:/mnt/bertha /mnt/bertha nfs rw,nobootwait
#
# bob (1TB SSD internal, Samsung EVO 960)
# UUID=d8f30f08-2698-411c-a3ea-32b9748e9ba9 /mnt/bob ext4 nobootwait 0 0
nuc01:/mnt/bob /mnt/bob nfs rw,nobootwait
#
# cloteal (10TB)
# UUID=4e356144-2e69-4812-8958-d035a9ebc28e /mnt/cloteal ext4 nobootwait 0 0
nuc01:/mnt/cloteal /mnt/cloteal nfs rw,nobootwait
#
# MyBook3T01 (3TB)
# UUID=C6B89CABB89C9B8D /mnt/MyBook3T01 ntfs nobootwait 0 0
nuc01:/mnt/MyBook3T01 /mnt/MyBook3T01 nfs rw,nobootwait
#
# # Silver5TB-A (5TB)
# # UUID=0A538B3244DE3676 /mnt/Silver5TB-A ntfs nobootwait 0 0
# # nuc01:/mnt/SilverTB-A /mnt/SilverTB-A nfs rw,nobootwait
#
# # Silver5TB-B (5TB)
# # UUID=D2929F3D929F254F /mnt/Silver5TB-B ntfs nobootwait 0 0
# # nuc01:/mnt/SilverTB-B /mnt/SilverTB-B nfs rw,nobootwait
#
########################################################################################################
#
# oz
#
########################################################################################################
#
# 5TBC (5TB) Black 5TB External Seagate
UUID=fa9f5c57-94fd-4706-979e-4c30189592a5 /mnt/5TBC ext4 defaults 0 0
# oz:/mnt/5TBC /mnt/5TBC nfs rw,nobootwait
#
# 12TBC (12TB) Black 12TB External Seagate
UUID=64414aac-65cf-4e81-a561-f007cb82418b /mnt/12TBC ext4 defaults 0 0
# oz:/mnt/12TBC /mnt/12TBC nfs rw,nobootwait
#
# ext10tb01 (10TB); external drive for Plex
UUID=08853dd9-14a7-4707-b6d6-9f49150a7f32 /mnt/ext10tb01 ext4 rw,nobootwait 0 0
# oz:/mnt/ext10tb01 /mnt/ext10tb01 nfs rw,nobootwait
#
# ssd1tb (1TB); internal SSD drive
UUID=be4a7edd-1cde-4dfe-ab3c-f5b64a59a9ce /mnt/ssd1tb ext4 nobootwait 0 0
# oz:/mnt/ssd1tb /mnt/ssd1tb nfs rw,nobootwait
#
########################################################################################################
#
# adam
#
########################################################################################################
#
# adam: 12TBA (12TB)
# UUID=901c4177-b514-408a-997c-0cbeee89fa6e /mnt/12TBA ext4 nobootwait 0 0
adam:/mnt/12TBA /mnt/12TBA nfs rw,nobootwait
#
# adam: 3TBB (3TB)
# UUID=74fcf036-b72c-47d9-be61-e63bdaf31881 /mnt/3TBB ext4 nobootwait 0 0
adam:/mnt/3TBB /mnt/3TBB nfs rw,nobootwait
#
# adam: 5TBD (5TB) UUID=5b0eab37-02f0-441a-b15a-fb05045d7b85
# UUID=5b0eab37-02f0-441a-b15a-fb05045d7b85 /mnt/5TBD ext4 nobootwait 0 0
adam:/mnt/5TBD /mnt/5TBD nfs rw,nobootwait
#
# adam: 5TBF (5TB) UUID=9c311371-fbce-423b-9f44-4301aca9e6e5
# UUID=C824163824162A48 /mnt/5TBF ntfs nobootwait 0 0
# adam:/mnt/5TBF /mnt/5TBF ntfs rw,nobootwait
#
########################################################################################################
