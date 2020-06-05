#!/bin/bash
# backup-file.sh

# NOTE: Wildcards and multiple files are not yet allowed. Maybe later.
# Creates an empty source file if it doesn't already exist.

# Include header file
logger Begin $0
source $(dirname $0)/source.sh

mkdir -p $(dirname $1)
touch $1
cp $1 $1.backup.$(date "+%Y.%m.%d-%H.%M.%S")
