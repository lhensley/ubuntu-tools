#!/bin/bash
# XXX.sh
# Revised 2020-05-07
# PURPOSE:
# IMPORTANT: Check variables at the top of the script before running it!

# Still to add:
#    wordpress
#    ssh keys
#    lets encrypt
#    turn off password
#    If a clone, make some things unique: hostname, address, keys (ssh, ssl, mysql, webmin)

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

USER_ME=lhensley
USER_UBUNTU=ubuntu

install_apache2=true
install_certbot=true
# Strongly recommended to install curl. Other installs depend on it.
install_curl=true
install_fail2ban=true
install_mailutils=true
install_mysql_server=true
install_net_tools=true
install_openssh_server=true
install_openssl=true
install_php=true
install_phpmyadmin=true
install_plexmediaserver=false
install_sysbench=true
install_tasksel=true
install_unzip=true
# Strongly recommended
install_wget=true
# NOTE: xrdp will allow remote desktop protocol. Use with care.
install_xrdp=true
enable_ufw=true

work_directory=$(pwd)

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Do updates
# apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove


# phpMyAdmin should be installed AFTER php and MySQL
if $install_mysql_server ; then
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y mysql-server
  MYSQL_ROOT_PASSWORD="YtMhe5rY#Qs2fFb&%n#qDtAi3k!Q3mUN"
  debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"
  mysql_secure_installation --use-default
#  cp /etc/mysql/mysql.conf.d/mysqld.cnf \
#  /etc/mysql/mysql.conf.d/mysqld.cnf-$(date '+%Y%m%d%H%M%S')
#  cp $(dirname $0)/configs/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
#  chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf
#  chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
#  mysql_ssl_rsa_setup
#  chown -R mysql:mysql /var/lib/mysql
  fi

exit

# phpMyAdmin should be installed AFTER php and MySQL
# ASKS QUESTIONS!
if $install_phpmyadmin ; then
# Based on https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04
  PHPMYADMIN_APP_PASS="8hBUeXCmATanaSwP6^mci4mUUUzfJ!ih"
  PHPMYADMIN_ROOT_PASS="YtMhe5rY#Qs2fFb&%n#qDtAi3k!Q3mUN"
  PHPMYADMIN_APP_DB_PASS="BL%4yFUevWJ*bag2mX#gP^VjnGnW8S49"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_ROOT_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_DB_PASS"
  apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl

  cd /usr/share
  rm -R phpmyadmin
  wget -P /usr/share/ "https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip"
  unzip phpMyAdmin-latest-all-languages.zip
  rm phpMyAdmin-latest-all-languages.zip
  mv phpMyAdmin-* phpmyadmin
  mkdir phpmyadmin/tmp
  cd $work_directory
  phpenmod mbstring
  touch /usr/share/phpmyadmin/config.inc.php
  cp /usr/share/phpmyadmin/config.inc.php \
  /usr/share/phpmyadmin/config.inc.php-$(date '+%Y%m%d%H%M%S')
  cp configs/phpmyadmin.config.inc.php /usr/share/phpmyadmin/config.inc.php
  chown -R www-data:www-data /usr/share/phpmyadmin
  chmod 644 /usr/share/phpmyadmin/config.inc.php
  systemctl restart apache2
  fi

if $install_plexmediaserver ; then
  curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
  echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
  apt-get update
  apt-get -y install apt-transport-https plexmediaserver
  apt-get -y install plexmediaserver
  ufw allow plexmediaserver
  fi

