#!/bin/bash
# secureserver.sh
# Should have owner root:$USER_NAME
# Should have permissions 700
#
# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh

HOME_DIRECTORY="/home/lhensley"

# Secure webmin
DIRNAME=/usr/share/webmin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure phpmyadmin
DIRNAME=/usr/share/phpmyadmin
cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure father-lane.gets-it
DIRNAME=/var/www/father-lane.gets-it/wp-admin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure html
DIRNAME=/var/www/html/wp-admin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure lane.likes-pie
DIRNAME=/var/www/lane.likes-pie/wp-admin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure limesurvey
DIRNAME=/var/www/limesurvey/admin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Secure music.from-tx.com
DIRNAME=/var/www/music.from-tx.com/wp-admin
# cp /usr/local/sbin/.htaccess.all.off $DIRNAME/.htaccess
# rm $DIRNAME/.htaccess

# Restart web secure
/etc/init.d/apache2 restart
