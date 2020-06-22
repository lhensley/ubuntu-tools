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

# Install git token
# To get a new token, go to https://github.com/settings/tokens.
MY_GIT_TOKEN=4b662b7d4431ec1956127aa9d4fdbd8d75ec821a
git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/"
git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"
chmod 400 $HOME_DIR/.gitconfigs
chmod 400 ~/.gitconfigs
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
# 6/22/2020: Read access for root ONLY.
chown -R root:lhensley $SBIN_DIR
find $SBIN_DIR -type d -print0 | xargs -0 chmod 700
find $SBIN_DIR -type f -print0 | xargs -0 chmod 400
# chmod -R 400 $SBIN_DIR/setup/configs
# chmod 500 $SBIN_DIR/ccextractor
chmod 500 $SBIN_DIR/*.sh $SBIN_DIR/setup/*.sh $SBIN_DIR/*.py
cd
echo git update complete.

# Copy in config files
# ddclient configs
cp $GO_CONFIGS/ddclient/$HOST_NAME/ddclient.conf /etc/
# Update /home/$USER_ME/.ssh/authorized_keys
mkdir -p /home/$USER_ME/.ssh/
# mkdir -p /home/$UBUNTU_ME/.ssh/
cp $GO_CONFIGS/ssh/$USER_ME/authorized_keys /home/$USER_ME/.ssh/
# cp $GO_CONFIGS/ssh/$USER_ME/authorized_keys /home/$USER_ME/.ssh/
chown -R $USER_ME:$USER_ME /home/$USER_ME/.ssh
# chown $USER_UBUNTU:$USER_UBUNTU /home/$USER_UBUNTU/.ssh/authorized_keys
chmod 600 /home/$USER_ME/.ssh/authorized_keys
# chmod 600 /home/$USER_UBUNTU/.ssh/authorized_keys

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
