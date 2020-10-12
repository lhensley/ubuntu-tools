# To Do
* Run fsck on nuc01
* Fix domain name; not defined, can't refer by short name
* Scripts to Write
  * Delete old newscasts & late night talk shows
  * Update syncplex to accommodate Pool06, etc.
* Check code in all lgh daemons for string constants that should be in _vars
* Turn pretend daemons into real ones
* Faster way to back up Plex configs
* Need to preserve MySQL credentials by backing them up and being able to restore them.
  * Probably best to specify credentials before creating a new instance so they can be re-created.
* Fix the MakeMKV install "press RETURN to continue" issue.
* Fix Plex install prompting for config info
* Figure out why oz won't resolve nuc01 without FQDN
* Pick up missed m4v files from work and move to store
* Backup tiers: Incrementals to external drive, then zip the contents weekly?
* Update backup script for oz and nuc01
* Backup ~/.ssh and /root/.ssh
* Amend config lookup so it checks the variable and not the file
 