#!/bin/bash
# update-production.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

# Include header file (forces running with sudo)
PRODUCTION_DIRECTORY="/usr/local/sbin"
source $PRODUCTION_DIRECTORY/source.sh

USERNAME="lhensley"
REPOSITORY="/home/$USERNAME/lane-utilities"
CURRENT_WORKING_DIRECTORY=$(pwd)
# Change to local repository directory
cd $REPOSITORY
# Blow away any local changes not uploaded to github
git reset --hard
# Select the master branch
git checkout master
# Pull down a copy of the repository
git pull
# Select the master branch
git checkout master
# Blow away the current production directory, recursively
rm -R $PRODUCTION_DIRECTORY/*
# Copy the correct contents from the local repository
cp -R sbin/* $PRODUCTION_DIRECTORY
# Set permissions correctly
chmod -R 770 $PRODUCTION_DIRECTORY/*
chown -R root:$USERNAME $PRODUCTION_DIRECTORY/*
# Change back to the original directory
cd $CURRENT_WORKING_DIRECTORY
# Send everything to remote servers now
$PRODUCTION_DIRECTORY/push-utilities.sh
