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
chmod -R 400 /var/local/git
# Copy scripts into /usr/local/sbin
rm -rf /usr/local/sbin
cp -r /var/local/git/go/sbin /usr/local
# Set ownership and permissions in /usr/local/sbin
chown -R root:lhensley /usr/local/sbin
find /usr/local/sbin -type d -print0 | xargs -0 chmod 750
find /usr/local/sbin -type f -print0 | xargs -0 chmod 440
chmod -R 400 /usr/local/sbin/setup/configs
chmod 540 /usr/local/sbin/*.sh /usr/local/sbin/setup/*.sh /usr/local/sbin/*.py /usr/local/sbin/ccextractor




