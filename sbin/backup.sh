#!/bin/bash
# backup.sh

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
source $(dirname $0)/source.sh

################ DELETE THIS SECTION? ##################################################
# echo "$(/bin/date) Setting backup parameters."
# The definition below seems not to be used. Delete it?
LOGFILE=$ARCHIVE_DIRECTORY/backup.log

# Create archive directory, defined in source.sh
mkdir -p $ARCHIVE_DIRECTORY

# Delete old backup log and start another one.
rm -f $BACKUPLOG
printf "$(date)\n" > $BACKUPLOG

# Dump old SQL backups
logger Removing MySQL dumps at $ARCHIVE_DIRECTORY and $MYSQL_DUMP_DIR
/bin/rm -f $ARCHIVE_DIRECTORY/*.sql >> $BACKUPLOG 2>&1
rm -f -R $MYSQL_DUMP_DIR

# Dump last weekday backup
/bin/rm -f $ARCHIVE_TAR_FULL_WEEKDAY >> $BACKUPLOG 2>&1
# echo $ARCHIVE_SQL_FULL
printf '\n\nDumping MySQL database contents to the filesystem.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
# Redundant
# logger Dumping MySQL database contents to the filesystem.
USERS_FILE="users.txt"
mysql -B -N -e 'show databases' >> $TEMP_DATABASES
mysql -e "SELECT user, host FROM mysql. user;" > $ARCHIVE_MYSQL_DB$USERS_FILE
for db in $(cat $TEMP_DATABASES); do
  if [ $db != 'information_schema' ] && [ $db != 'performance_schema' ] ; then
    logger Dumping MySQL database $db to $ARCHIVE_MYSQL_DB$db.sql
    mysqldump --databases $db --routines --force \
      > "$ARCHIVE_MYSQL_DB$db.sql" 2>> $BACKUPLOG
    fi
  done
logger Moving $ARCHIVE_DIRECTORY .sql and .txt files to $MYSQL_DUMP_DIR and setting ownership and privileges.
mkdir -p $MYSQL_DUMP_DIR
mv $ARCHIVE_DIRECTORY/*.sql $MYSQL_DUMP_DIR/
mv $ARCHIVE_DIRECTORY/*.txt $MYSQL_DUMP_DIR/
/bin/chown -R $USER_NAME:$USER_NAME $MYSQL_DUMP_DIR
/bin/chmod -R 600 $MYSQL_DUMP_DIR
/bin/chmod 700 $MYSQL_DUMP_DIR

# Append known backup exceptions to list of socket files.
cat $SCRIPTS_INCLUDES/files-excluded.txt >> $SOCKETS_TEMP_FILE

# Run the backup.
printf '\n\nRunning the actual backup.\n' >> $BACKUPLOG 2>&1
logger Running "$EXEC_BACKUP"
echo $(date) >>$BACKUPLOG 2>&1
$EXEC_BACKUP >>$BACKUPLOG 2>&1
logger Exit code $?

# Remove any remaining SQL dumps
# logger Removing MySQL dumps at $MYSQL_DUMP_DIR
# rm -R $MYSQL_DUMP_DIR
# Can't remember why I wanted to drop these, except for security reasons.
# Permissions already are set very strictly above.

# Copy the weekday backup to the monthly version
printf '\n\nCopying backup file to monthly version.\n' >>$BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
logger Copying $ARCHIVE_TAR_FULL_WEEKDAY to $ARCHIVE_TAR_FULL_MONTH
/bin/cp $ARCHIVE_TAR_FULL_WEEKDAY $ARCHIVE_TAR_FULL_MONTH >>$BACKUPLOG 2>&1

# Set permissions of files in the archive directory
printf '\n\nSetting permissions on archives files.\n' >>$BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
logger Setting permisssions for $ARCHIVE_DIRECTORY and its contents.
/bin/chown $USER_NAME:$USER_NAME $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1
/bin/chmod 600 $ARCHIVE_DIRECTORY/* >>$BACKUPLOG 2>&1

# Sync to offsite server
printf '\n\nSyncing backup to $OFFSITE_SERVER.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
logger Attempting to sync to $OFFSITE_SERVER as $USER_NAME
su -c "$RSYNC_SU" $USER_NAME >> $BACKUPLOG 2>&1
logger Exit code for attempted sync to $OFFSITE_SERVER as $USER_NAME: $?

# Add footer to backup log
printf '\n\nCONTENTS OF $ARCHIVE_DIRECTORY\n' >>$BACKUPLOG
ls -al $ARCHIVE_DIRECTORY >>$BACKUPLOG 2>&1

# Drop orphaned temp files
rm $ARCHIVE_DIRECTORY/.* >/dev/null 2>&1

# Remove all remaining tempfiles. #####################################
printf '\n\nExiting.\n' >> $BACKUPLOG 2>&1
echo $(date) >>$BACKUPLOG 2>&1
logger Backup details recorded to $BACKUPLOG
logger End $0
source $SCRIPTS_DIRECTORY/cleanup-and-exit.sh
