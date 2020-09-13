# To Back Up
Connect a peripheral hard drive 1TB or more for the "live" backups
*  Define it in fstab to mount manually only.
*  Keep it unmounted when not in use.
*  Figure out a rolling purge of old data

"Live" backups happen by rsync
* Once done, use tar to compress an archive version
* If feasible, rsync live backups off-site
* If feasible, store archives on same drive as "live" backups
* Giant file systems (e.g., Plex data) get rsync mirroring, but not archiving

Consider mounting the hugest file systems (bertha, rerun, 5TBA, 5TBB)
  as read-only, and make them readable only when they're being edited.
  Use a "work" volume to store recent adds.

Backup 1: Security
 * (don't follow symbolic links)
 * LetsEncrypt
   * Certificates in /etc
 * MYSQL
    Users, Passwords, Privileges
   * Data (includes app passwords, e.g., LimeSurvey, WordPress users)
   * Certificates
   * .my.cnf in ADMIN & ROOT
 * phpMyAdmin
   * Doesn't Matter
 * SSH
   * .ssh directory contents
   * /etc/ssh ...
 * MakeMKV
   * /etc config file with license key
 * Vault Files (put somewhere else; /var/local? and link from home)

Backup 2: Application Data
 * (don't follow symbolic links)
 * ~/.config
 * ~/.gitconfig
 * ~/.ssh
 * ~/.vimrc
 * /etc
 * /opt
 * /var/lib/plexmediaserver/Library/Application Support
 * /var/spool/cron/crontabs/
 * /var/spool/mail/
 * /var/www

Backup 3: Home Directories
 * (don't follow symbolic links)
