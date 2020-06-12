#!/bin/bash
# purge-openvpn.sh

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

logger Purging OpenVPN
upd.sh
apt-get -f install
apt-get purge -y openvpn

