#!/bin/bash
# pull-utilities.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

# This should go BEFORE header so nothing runs on the wrong server.
ONLY_BAD_SERVER="nuc01"
if [[ $(/bin/hostname -s) == $ONLY_BAD_SERVER ]]; then
    echo "$0 NEVER runs on server $ONLY_BAD_SERVER."
    exit
fi

# Include header file
PRODUCTION_DIRECTORY="/usr/local/sbin"
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh


REMOTE_SOURCE_DIRECTORY=$PRODUCTION_DIRECTORY
REMOTE_SERVER=lane.is-a-geek.org
REMOTE_PORT=10103
LOCAL_TARGET_DIRECTORY=/usr/local
# rsync options used
#    -a = archive mode, equivalent to -rlptgoD
#    -g = preserve group ownership
#    -l = recreate symlinks on destination
#    -o = preserve owner
#    -p = preserve permissions
#    -q = quiet
#    -r = recursive (includes subdirectories)
#    -t = preserve modification times
#    -z = compress file data during transfer
#    -D = preserve device files and special files
#    -E = preserve executability
#    --delete = delete extraneous files from dest dirs
RSYNC="rsync -gopqrzE --delete"
RSYNC="$RSYNC -e 'ssh -p $REMOTE_PORT'"
RSYNC="$RSYNC '$REMOTE_SERVER:$REMOTE_SOURCE_DIRECTORY'"
RSYNC="$RSYNC '$LOCAL_TARGET_DIRECTORY'"

# Sync to target server
# su options used
#    -c = Pass command to the shell
echo 'Syncing.'
su -c "$RSYNC" $USER_NAME

