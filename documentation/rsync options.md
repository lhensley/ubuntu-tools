# rsync options
```
# rsync options considered
# Until string constants and variable definitions are moved to _vars, this should ONLY be run on oz.
#    -n --dry-run
#       dry run
#    -a --archive    
#       archive mode, equivalent to -rlptgoD
#    -g
#       preserve group ownership
#    -l --links
#       recreate symlinks on destination
#    -o --owner
#       preserve owner
#    -p --perms
#       preserve permissions
#    -q --quiet
#       quiet
#    -r --recursive 
#       recursive (includes subdirectories)
#    -t --times
#       preserve modification times
#    -v --verbose 
#       verbose
#    -D
#       preserve device files and special files
#    -E --executability
#       preserve executability
#    -R --relative
#       use relative paths (see https://linux.die.net/man/1/rsync for more info)
#    --delete = delete extraneous files from dest dirs
#    --remove-source-files = what you think it means

```