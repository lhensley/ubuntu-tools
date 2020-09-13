# Notes on Restoring a System
These are things I'm doing manually after restoring an existing system.
* fstab: Re-establishing mount points and adapting fstab.

The script below attempts to deal with these. This is a work in progress. For now, it applies exclusively to oz.
```bash
#!/bin/bash
# restore-oz

# Create mount points
    mkdir -p /mnt/ssd1tb      # Make mount point for internal 1TB SDD drive
    mkdir -p /mnt/ext10tb01   # Make mount point for extral 10TB drive

# Dismount peripherals that mounted automatically
    umount /media/$ADMIN_USER/* > /dev/null 2>&1

# Mount peripherals again
    mount --all



# INSTALL PLEX FIRST!

ln -s /mnt/ssd1tb /var/lib/plexmediaserver/Library/work

_
