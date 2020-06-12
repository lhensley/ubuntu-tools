#!/bin/bash
# install-openvpn.sh

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

logger Installing OpenVPN
upd.sh

# Following https://www.cyberciti.biz/faq/ubuntu-20-04-lts-set-up-openvpn-server-in-5-minutes/
apt-get update && apt-get -y install ca-certificates wget net-tools gnupg
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian $UBUNTU_CODENAME main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
apt-get install -y openvpn

