#!/bin/bash
# /usr/local/sbin/source-2019-03-20.sh
# Source file for lane scripts
# Should have owner root:$USER_NAME
# Should have permissions 770
#
debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# echo "$(/bin/date) Starting up."
source /etc/os-release

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi
# Set local Variables
HOST_NAME=$(/bin/hostname -s)
USER_ME="lhensley"
USER_UBUNTU="ubuntu"
HOME_DIRECTORY="/home/$USER_ME"
case $HOST_NAME in
  nell )
    ADDRESS=192.168.168.21
    USER_NAME=lhensley
    OFFSITE_SERVER=nuc01.local
    OFFSITE_PORT=22
    OFFSITE_PATH=/var/local/archives
    ;;
  pearl )
    ADDRESS=192.168.0.36
    USER_NAME=lhensley
    OFFSITE_SERVER=lane.is-a-geek.org
    OFFSITE_PORT=10103
    OFFSITE_PATH=/var/local/archives
    ;;
  red )
    ADDRESS=192.168.168.23
    USER_NAME=lhensley
    OFFSITE_SERVER=nuc01.local
    OFFSITE_PORT=22
    OFFSITE_PATH=/var/local/archives
    ;;
  nuc01 )
    ADDRESS=192.168.168.31
    USER_NAME=lhensley
    OFFSITE_SERVER=nell.local
    OFFSITE_PORT=22
    OFFSITE_PATH=/var/local/archives
    ;;
esac

# Set basic Variables
START_DATESTAMP=$(/bin/date '+%Y-%m-%d')
START_DAYSTAMP=$(/bin/date '+%d')
START_WEEKDAYSTAMP=$(/bin/date '+%a')
START_MONTHSTAMP=$(/bin/date '+%Y-%m')
START_TIMESTAMP=$(/bin/date)
EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"
UUID=$(uuidgen)
ARCHIVE_DIRECTORY=/var/local/archives/$(hostname -s)
GIT=/var/local/git
GO=$GIT/go
GO_CONFIGS=$GO/configs
GO_SBIN=$GO/sbin
GO_SETUP=$GO_SBIN/setup
HOME_RELATIVE=home/$USER_NAME
HOME_DIR=/$HOME_RELATIVE
MYSQL_DUMP_DIR=$HOME_DIR/mysql-dumps
LANE_SCRIPTS_PREFIX="lane-scripts"
SBIN_PARENT="/usr/local"
SBIN_DIR="$SBIN_PARENT/sbin"
SSHD_CONFIG="/etc/ssh/sshd_config"
TEMP_DATABASES="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-databases.tmp"
TEMP_PASSWORD_INCLUDE="/tmp/passwords.sh"
TEMP_INCLUDES="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-includes.tmp"
SOCKETS_TEMP_FILE="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-socket-files.tmp"
TEMP_LOG="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-log.tmp"
SCRIPTS_DIRECTORY=/usr/local/sbin
SCRIPTS_INCLUDES=$SCRIPTS_DIRECTORY/include

# Make a list of all the include files
# /usr/bin/find $SCRIPTS_INCLUDES/ -type f -name "*.sh" \
#   >> "$TEMP_INCLUDES" 2>/dev/null
# Loop through the file, integrating the file indicated in each line
# Not clear on what IFS is doing here.
# See https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
find $SCRIPTS_INCLUDES -name "*.sh" -type f | while read INFILE
  do
    source "$INFILE"
  done
# while IFS='' read -r line || [[ -n "$line" ]]; do
#   source "$line"
# done < "$TEMP_INCLUDES"

# Commands to execute every time ######################################

# Set key file ownerships #############################################
/bin/chown root:root /etc/mysql/conf.d/mysqldump.cnf >> /dev/null 2>&1
/bin/chown -R root:$USER_NAME $SCRIPTS_DIRECTORY >> /dev/null 2>&1
/bin/chown -R www-data:www-data /var/www/html/ >> /dev/null 2>&1

# Set key file permissions ############################################
/bin/chmod 600 /etc/mysql/conf.d/mysqldump.cnf >> /dev/null 2>&1
/bin/chmod -R 770 $SCRIPTS_DIRECTORY >> /dev/null 2>&1

# Echo variable values in debug mode
#
if $debug_mode ; then
  echo $(date)
  env
  fi
