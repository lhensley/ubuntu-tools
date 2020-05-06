#!/bin/bash
# fetch-branch.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

# Include header file (forces running with sudo)
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

USERNAME="lhensley"
REPOSITORY="/home/$USERNAME/lane-utilities"
# Change to local repository directory
cd $REPOSITORY
# Blow away any local changes not uploaded to github
git reset --hard
# Select the designated branch
git checkout $1
# Pull down a copy of the repository
git pull
# Set permissions correctly
chmod -R 770 sbin/*
chown -R root:$USERNAME sbin/*
# Switch to sbin subdirectory
cd $REPOSITORY/sbin
