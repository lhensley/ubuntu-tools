#!/bin/bash
# install-910-webmin.sh
# Revised 2020-05-07
# PURPOSE: Sets up Webmin.

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

install_webmin=true

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Do updates
apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove

if $install_webmin ; then
  wget http://www.webmin.com/download/deb/webmin-current.deb
  apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl \
  libpam-runtime libio-pty-perl apt-show-versions python
  dpkg --install webmin-current.deb
  rm webmin-current.deb
  ufw allow webmin
  echo Webmin installed.
  fi
  
