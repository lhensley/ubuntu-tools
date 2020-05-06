#!/bin/bash
# git-pull.sh

# Include header file (forces running with sudo)
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

USERNAME="lhensley"
REPOSITORY="/var/local/git/go"
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
sudo chmod -R 400 /var/local/git
# Copy scripts into /usr/local/sbin
sudo cp -r /var/local/git/go/sbin /usr/local
# Set ownership and permissions in /usr/local/sbin
sudo chown -R root:lhensley /usr/local/sbin
sudo find /usr/local/sbin -type d -print0 | sudo xargs -0 chmod 750
sudo find /usr/local/sbin -type f -print0 | sudo xargs -0 chmod 440
sudo chmod -R 400 /usr/local/sbin/setup/configs
sudo chmod 540 /usr/local/sbin/*.sh /usr/local/sbin/setup/*.sh /usr/local/sbin/*.py /usr/local/sbin/ccextractor




