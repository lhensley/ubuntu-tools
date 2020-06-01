#!/bin/bash
# make-letsencrypt-p12-files.sh
# Should have owner root:$USER_NAME
# Should have permissions 700
#
# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

letsencrypt_live_directory="/etc/letsencrypt/live"

for d in $letsencrypt_live_directory/*
	do
		if [ -d $d ]; then
			cd $d
			for x in cert chain fullchain privkey
				do
					echo "Working with $d/$x.pem"
					openssl pkcs12 -export -inkey privkey.pem -in $x.pem -out $x.p12
				done
		fi
done