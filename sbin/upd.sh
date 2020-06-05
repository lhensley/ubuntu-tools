#!/bin/bash
# upd.sh
# Should have owner root:$USER_NAME
# Should have permissions 770
#
# Include header file
logger Begin $0
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

# Changed apt-get to apt 1/31/19.
# See https://itsfoss.com/apt-vs-apt-difference/ for rationale.

# This section re-pulls all go files from github and updates /usr/local/sbin
USERNAME=$USER_ME
REPOSITORY=$GO
BRANCH="master"
# Change to local repository directory
cd $REPOSITORY
# Blow away any local changes not uploaded to github
git reset --hard
# Select the designated branch
git checkout $BRANCH
# Pull down a copy of the repository
git pull
# Set permissions for git directory
chmod -R 400 $GIT
# Copy scripts into /usr/local/sbin
rm -rf $SBIN_DIR
cp -r $GO_SBIN $SBIN_PARENT
# Set ownership and permissions in /usr/local/sbin
chown -R root:lhensley $SBIN_DIR
find $SBIN_DIR -type d -print0 | xargs -0 chmod 750
find $SBIN_DIR -type f -print0 | xargs -0 chmod 440
# chmod -R 400 $SBIN_DIR/setup/configs
chmod 540 $SBIN_DIR/*.sh $SBIN_DIR/setup/*.sh $SBIN_DIR/*.py $SBIN_DIR/ccextractor
cd
# Update /home/$USER_ME/.ssh/authorized_keys
mkdir -p /home/$USER_ME/.ssh/
# mkdir -p /home/$UBUNTU_ME/.ssh/
cp $GO_CONFIGS/ssh/$USER_ME/authorized_keys /home/$USER_ME/.ssh/
# cp $GO_CONFIGS/ssh/$USER_ME/authorized_keys /home/$USER_ME/.ssh/
chown -R $USER_ME:$USER_ME /home/$USER_ME/.ssh
# chown $USER_UBUNTU:$USER_UBUNTU /home/$USER_UBUNTU/.ssh/authorized_keys
chmod 644 /home/$USER_ME/.ssh/authorized_keys
# chmod 644 /home/$USER_UBUNTU/.ssh/authorized_keys
echo git update complete.

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
