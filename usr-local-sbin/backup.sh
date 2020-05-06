#!/bin/bash
# backup.sh
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
EXEC_BACKUP="$EXEC_BACKUP --totals"
# EXEC_BACKUP="$EXEC_BACKUP --verbose"
EXEC_BACKUP="$EXEC_BACKUP --exclude-from=$SOCKETS_TEMP_FILE"
EXEC_BACKUP="$EXEC_BACKUP /etc /home /root /usr/local/sbin /var/www"
# EXEC_BACKUP="$EXEC_BACKUP /var/local/archives/*.sql"

# NOTE: -t flag removed from next line 3/28/19. Generates error.
RSYNC_NO_DELETE="rsync -aopqrzE -e 'ssh -p $OFFSITE_PORT'"
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
printf '\n\nDumping MySQL database contents to the filesystem.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
mysql -B -N -e 'show databases' >> $TEMP_DATABASES
for db in $(cat $TEMP_DATABASES); do
  if [ $db != 'information_schema' ] && [ $db != 'performance_schema' ] ; then
    mysqldump --databases $db --routines --force \
      > "$ARCHIVE_MYSQL_DB$db.sql" 2>> $BACKUPLOG
    fi
  done
mkdir -p $MYSQL_DUMP_DIR
mv $ARCHIVE_DIRECTORY/*.sql $MYSQL_DUMP_DIR/
/bin/chown -R $USER_NAME:$USER_NAME $MYSQL_DUMP_DIR
/bin/chmod -R 600 $MYSQL_DUMP_DIR

# Append known backup exceptions to list of socket files.
cat $SCRIPTS_INCLUDES/files-excluded.txt >> $SOCKETS_TEMP_FILE

# Run the backup.
printf '\n\nRunning the actual backup.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
$EXEC_BACKUP >>$BACKUPLOG 2>&1

# Remove the SQL dumps
rm -R $MYSQL_DUMP_DIR

# Copy the weekday backup to the monthly version
printf '\n\nCopying backup file to monthly version.\n' >>$BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
/bin/cp $ARCHIVE_TAR_FULL_WEEKDAY $ARCHIVE_TAR_FULL_MONTH >>$BACKUPLOG 2>&1

# Set permissions of files in the archive directory
printf '\n\nSetting permissions on archives files.\n' >>$BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
/bin/chown $USER_NAME:$USER_NAME $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1
/bin/chmod 600 $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1

# Sync to offsite server
printf '\n\nSyncing backup to $OFFSITE_SERVER.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
su -c "$RSYNC_SU" $USER_NAME >> $BACKUPLOG 2>&1

# Add footer to backup log
printf '\n\nCONTENTS OF $ARCHIVE_DIRECTORY\n' >>$BACKUPLOG
ls -al $ARCHIVE_DIRECTORY >>$BACKUPLOG 2>&1

# Drop orphaned temp files
rm $ARCHIVE_DIRECTORY/.* >/dev/null 2>&1

# Remove all remaining tempfiles. #####################################
printf '\n\nExiting.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
source $SCRIPTS_DIRECTORY/cleanup-and-exit.sh
