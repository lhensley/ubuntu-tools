# rsync options
```
# rsync options considered
# Until string constants and variable definitions are moved to _vars, this should ONLY be run on oz.
#    -a = archive mode, equivalent to -rlptgoD
#    -g = preserve group ownership
#    -l = recreate symlinks on destination
#    -n = dry run
#    -o = preserve owner
#    -p = preserve permissions
#    -q = quiet
#    -r = recursive (includes subdirectories)
#    -t = preserve modification times
#    -v = verbose
#    -D = preserve device files and special files
#    -E = preserve executability
#    -R = use relative paths (see https://linux.die.net/man/1/rsync for more info)
#    --delete = delete extraneous files from dest dirs
```