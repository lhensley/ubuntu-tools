#!/bin/bash
# db-backup.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

# For mysqldump to work in unattended move, we need, in /root/ and in $HOME_DIR:
#   File .my.cnf, containing this text:
#     [client]
#     user=root
#     password=[pwd]
#
#     [mysqldump]
#     user=root
#     password=[pwd]
#   sudo chmod 600 /root/.my.cnf
#   sudo chown root:root /root/.my.cnf
#   sudo chmod 600 $HOME_DIR/.my.cnf
#   sudo chown $USER_NAME:$USER_NAME $HOME_DIR/.my.cnf
#
#   mysql --batch --skip-column-names --execute "show databases"
#
# Include header file
# echo "$(/bin/date) Running setup routine."
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

# echo "$(/bin/date) Setting backup parameters."
LOGFILE=$ARCHIVE_DIRECTORY/backup.log
DIRECTORY_FROM=/

ARCHIVE_TAR_FILE="$HOST_NAME-$START_DATESTAMP.gz"
ARCHIVE_TAR_FULL="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_FILE"
ARCHIVE_TAR_WEEKDAY_FILE="$HOST_NAME-weekday-$START_WEEKDAYSTAMP.gz"
ARCHIVE_TAR_FULL_WEEKDAY="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_WEEKDAY_FILE"
ARCHIVE_TAR_DAY_FILE="$HOST_NAME-day-$START_DAYSTAMP.gz"
ARCHIVE_TAR_FULL_DAY="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_DAY_FILE"
ARCHIVE_TAR_MONTH_FILE="$HOST_NAME-month-$START_MONTHSTAMP.gz"
ARCHIVE_TAR_FULL_MONTH="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_MONTH_FILE"
ARCHIVE_MYSQL_FILE="$HOST_NAME-$START_DATESTAMP.sql"
ARCHIVE_MYSQL_FULL="$ARCHIVE_DIRECTORY/$ARCHIVE_MYSQL_FILE"
ARCHIVE_MYSQL_LITURGY="$ARCHIVE_DIRECTORY/$HOST_NAME-liturgy.sql"
ARCHIVE_MYSQL_DB="$ARCHIVE_DIRECTORY/$HOST_NAME-$START_DATESTAMP-"

TAR="/bin/tar"
EXEC_BACKUP="$TAR --create --gzip --auto-compress --preserve-permissions"
EXEC_BACKUP="$EXEC_BACKUP --file=$ARCHIVE_TAR_FULL_WEEKDAY"
EXEC_BACKUP="$EXEC_BACKUP --exclude-backups"
EXEC_BACKUP="$EXEC_BACKUP --exclude-vcs --exclude-caches"
EXEC_BACKUP="$EXEC_BACKUP --verbose"
EXEC_BACKUP="$EXEC_BACKUP --exclude-from=$SOCKETS_TEMP_FILE"
EXEC_BACKUP="$EXEC_BACKUP /etc /home /root /usr/local/sbin /var/www"
# EXEC_BACKUP="$EXEC_BACKUP /var/local/archives/*.sql"

RSYNC_NO_DELETE="rsync -aopqrtzE -e 'ssh -p $OFFSITE_PORT'"
RSYNC_SU="$RSYNC_NO_DELETE '$ARCHIVE_DIRECTORY'"
RSYNC_SU="$RSYNC_SU $OFFSITE_SERVER:$OFFSITE_PATH"

# Create archive directory
mkdir -p $ARCHIVE_DIRECTORY

# Delete old backup log and start another one.
BACKUPLOG=$ARCHIVE_DIRECTORY/$HOST_NAME-backup.log
rm $BACKUPLOG 2>> /dev/null
date > $BACKUPLOG
printf "\n" >> $BACKUPLOG

# Dump old SQL backups
/bin/rm -f $ARCHIVE_DIRECTORY/*.sql >> $BACKUPLOG 2>&1

# Dump last weekday backup
/bin/rm -f $ARCHIVE_TAR_FULL_WEEKDAY >> $BACKUPLOG 2>&1

# echo $ARCHIVE_SQL_FULL
echo "$(/bin/date) Dumping MySQL database contents to the filesystem."
mysql -B -N -e 'show databases' >> $TEMP_DATABASES
for db in $(cat $TEMP_DATABASES); do
    echo "$ARCHIVE_MYSQL_DB$db.sql"
    mysqldump --databases $db --routines --force \
    > "$ARCHIVE_MYSQL_DB$db.sql" 2>> $BACKUPLOG
  done
mkdir $HOME_DIR/mysql-dumps
mv $ARCHIVE_DIRECTORY/*.sql $HOME_DIR/mysql-dumps/
/bin/chown -R $USER_NAME:$USER_NAME $HOME_DIR/mysql-dumps
/bin/chmod -R 600 $HOME_DIR/mysql-dumps

exit

# Append known backup exceptions to list of socket files.
cat $SCRIPTS_INCLUDES/files-excluded.txt >> $SOCKETS_TEMP_FILE

# Run the backup.
echo "$(/bin/date) Running the actual backup."
$EXEC_BACKUP >>$BACKUPLOG 2>&1

# Remove the SQL dumps
rm -R $HOME_DIR/mysql-dumps

# Copy the weekday backup to the monthly version
# echo "$(/bin/date) Copying backup file to monthly version."
/bin/cp $ARCHIVE_TAR_FULL_WEEKDAY $ARCHIVE_TAR_FULL_MONTH >>$BACKUPLOG 2>&1

# Set permissions of files in the archive directory
# echo "$(/bin/date) Setting permissions on archives files."
/bin/chown $USER_NAME:$USER_NAME $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1
/bin/chmod 600 $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1

# Sync to offsite server
echo "$(/bin/date) Syncing backup to $OFFSITE_SERVER."
su -c "$RSYNC_SU" $USER_NAME >> $BACKUPLOG 2>&1

# Add footer to backup log
# echo "$(/bin/date) Recording information to backup log."
printf "\n\nCONTENTS OF $ARCHIVE_DIRECTORY\n" >>$BACKUPLOG
ls -al $ARCHIVE_DIRECTORY >>$BACKUPLOG 2>&1
printf "\n\nBACKUP SCRIPT VARIABLES:\n" >>$BACKUPLOG 2>&1

# Remove all remaining tempfiles. #####################################
echo "$(/bin/date) Exiting."
source $SCRIPTS_DIRECTORY/cleanup-and-exit.sh
