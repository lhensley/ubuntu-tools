#!/bin/bash
# make-letsencrypt-p12-files.sh
# Should have owner root:$USER_NAME
# Should have permissions 700
#
# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

letsencrypt_live_directory="/etc/letsencrypt/live"

for d in $letsencrypt_live_directory
do
	echo "Hit on $letsencrypt_live_directory"
done