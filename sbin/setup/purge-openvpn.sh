#!/bin/bash
# purge-openvpn.sh

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

systemctl stop openvpn@client.service
systemctl stop openvpn@server.service
systemctl disable openvpn@client.service
systemctl disable openvpn@server.service
logger Purging OpenVPN
upd.sh
apt-get -f install
apt-get purge -y openvpn

ufw deny 1194
ufw deny 1900