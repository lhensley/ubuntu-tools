#!/bin/bash
# upd.sh
# Should have owner root:$USER_NAME
# Should have permissions 770
#
# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

HOME_DIRECTORY="/home/lhensley"

# Changed apt-get to apt 1/31/19.
# See https://itsfoss.com/apt-vs-apt-difference/ for rationale.

# "update" downloads package information from all configured sources
apt -y update
# "upgrade" is an extraneous subset of "dist-upgrade" below
#    sudo apt -y upgrade \
# "dist-upgrade" installs available upgrades of all packages
# currently installed on the system and intelligently handles
# changing dependencies with new versions of packages
apt -y dist-upgrade
# "clean" clears out the local repository of retrieved package files.
apt -y clean
# "autoremove" removes those dependencies that were installed with
# now-removed applications and that are no longer used
# by anything else on the system
apt -y autoremove
# Install any *.deb files in the home directory
# apt-get install -y $HOME_DIRECTORY/*.deb && rm -f $HOME_DIRECTORY/*.deb
