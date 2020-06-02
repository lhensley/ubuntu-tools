#!/bin/bash
# setup-os.sh
# Revised 2020-05-11
# PURPOSE: Installs basic software.
# IMPORTANT: Check variables at the top of the script before running it!

# Still to add:
#    lets encrypt
#    turn off password

echo "Starting setup ..."

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

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

######################################################
######### IMPORTANT! #################################
######### Fill in this section carefully, ############
######### copy-and-paste it into Roboform ############
######### BEFORE running install script ##############
LENGTH_OF_PASSWORDS=63
MAX_MYSQL_PASSWORD_LENGTH=32
HOSTNAME="$(hostname)"
USER_ME="lhensley"
MYSQL_ADMIN_NAME="admin"
USER_UBUNTU="ubuntu"
MAILNAME="$(hostname)"
MAIN_MAILER_TYPE="'Internet with smarthost'"
RELAYHOST="mail.twc.com" # Spectrum Internet
# RELAYHOST="mail.mchsi.com" # Mediacom Cable Internet
######### END password information ###################
######################################################

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
install_plexmediaserver=false # CAUTION: NOT TESTED FOR UBUNTU 20
install_sysbench=true
install_tasksel=true
install_unzip=true
install_webmin=true
# Strongly recommended
install_wget=true
# NOTE: xrdp will allow remote desktop protocol. Use with care.
install_xrdp=true
enable_ufw=true

work_directory=$(pwd)
running_directory=$(dirname $0)
git_directory="/var/local/git"
go_directory="$git_directory/go"
configs_directory="$go_directory/configs"
mkdir -p /home/$USER_ME/.ssh
chown -R $USER_ME:$USER_ME /home/$USER_ME/.ssh

if [[ $NAME = "Ubuntu" ]]; then
    if [[ $(echo $VERSION_ID | cut -c1-3) = "20." ]]; then
      echo "Ubuntu version 20 confirmed."
    else
      echo "This script does not support version $VERSION_ID of Ubuntu."
      exit 1
    fi
else
  echo "This script works only on Ubuntu."
  exit 1
fi

# Do updates
apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove

if ! [ -x "$(command -v apg)" ]; then
  echo "Installing apg"
  apt-get install -y apg
fi

EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"
NUMBER_OF_DESIGNATED_PASSWORDS=7
TEMP_PASSWORD_INCLUDE="/tmp/passwords.sh"
echo "" > $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 0
echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 1
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 2
echo "MYSQL_ROOT_PASSWORD=\"$(apg -c cl_seed -a 1 -m $MAX_MYSQL_PASSWORD_LENGTH -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 3
echo "MYSQL_ADMIN_PASSWORD=\"$(apg -c cl_seed -a 1 -m $MAX_MYSQL_PASSWORD_LENGTH -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 5
echo "PHPMYADMIN_APP_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 5
echo "PHPMYADMIN_ROOT_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 6
echo "PHPMYADMIN_APP_DB_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 7
echo "" >> $TEMP_PASSWORD_INCLUDE

chown root:root $TEMP_PASSWORD_INCLUDE
chmod 500 $TEMP_PASSWORD_INCLUDE
progress-bar.sh
source $TEMP_PASSWORD_INCLUDE
rm $TEMP_PASSWORD_INCLUDE

# Update hostname
echo "Updating hostname"
hostnamectl set-hostname $HOSTNAME
echo $HOSTNAME > /etc/hostname
chmod 644 /etc/hostname
chown root:root /etc/hostname

# Make $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access
echo "Making $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access"
useradd $USER_ME
# useradd $USER_UBUNTU
# TWO PROBLEMS WITH THE COMMANDS BELOW: The --stdin flag doesn't work in this version of Linux, and my password is going to be dropped anyway.
# echo $PASSWORD_ME | passwd --stdin $USER_ME
# echo $PASSWORD_UBUNTU | passwd --stdin $USER_UBUNTU
usermod -aG sudo $USER_ME
# usermod -aG sudo $USER_UBUNTU
printf "\n\nAllowUsers $USER_ME $USER_UBUNTU\n\n" >> $SSHD_CONFIG
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' $SSHD_CONFIG
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' $SSHD_CONFIG
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' $SSHD_CONFIG
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' $SSHD_CONFIG
sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords no/g' $SSHD_CONFIG
sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' $SSHD_CONFIG
chmod 755 $SSHD_CONFIG
systemctl restart sshd
# echo Users $USER_ME and $USER_UBUNTU installed and configured for ssh.
# echo User $USER_ME installed and configured for ssh.

echo Configure sudo $USER_ME and $USER_UBUNTU as sudo users
echo "$USER_ME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lane-NOPASSWD-users
echo "$USER_UBUNTU ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/lane-NOPASSWD-users
echo Removing passwords for $USER_ME and $USER_UBUNTU
chmod 440 /etc/sudoers.d/lane-NOPASSWD-users
# Not sure I want to drop my password. Still don't need it for ssh. 6/1/2020
# passwd -d $USER_ME
# This probably will fail, and that's fine.'
# passwd -d $USER_UBUNTU
echo "Passwords removed for $USER_ME and $USER_UBUNTU"
echo "Or not"

# Add custom application definitions for ufw
echo "Adding custom application definitions for ufw"
cp $configs_directory/lane-applications /etc/ufw/applications.d/
chown root:root /etc/ufw/applications.d/lane-applications
chmod 644 /etc/ufw/applications.d/lane-applications
ufw app update lane-applications
echo "Special LANE applications installed to ufw."

# CRITICAL: Install this first.
if $install_curl ; then
  echo "Installing curl"
  apt-get install -y curl
  echo "curl installed."
  fi

# Install this early.
if $install_unzip ; then
  echo "Installing unzip"
  apt-get install -y unzip
  echo "unzip installed."
  fi

# Install this early.
if $install_wget ; then
  echo "Installing wget"
  apt-get install -y wget
  echo "wget installed."
  fi

if $install_apache2 ; then
  echo "Installing apache2"
  apt-get install -y apache2 apache2-doc apache2-suexec-pristine
  ufw allow 'Apache'
  ufw allow 'Apache Full'
  ufw allow http
  ufw allow https
  a2enmod ssl rewrite
  systemctl restart apache2
  echo "apache2 installed."
  fi

if $install_fail2ban ; then
  echo "Installing fail2ban"
  apt-get install -y fail2ban monit sqlite3 python-pyinotify-doc
  echo "fail2ban installed."
  fi

if $install_net_tools ; then
  echo "installing net_tools"
  apt-get install -y net-tools
  echo net-tools installed.
  fi

if $install_openssl ; then
  echo "Installing openssl"
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev libcurl4-doc libidn11-dev libkrb5-dev libldap2-dev librtmp-dev libssh2-1-dev zlib1g-dev libssl-doc
  echo "openssl installed."
  fi

if $install_php ; then
  echo "Installing php"
  apt-get install -y php libapache2-mod-php
  apt-get install -y php-mysql php-gd php-curl php-imap php-ldap
  apt-get install -y libmcrypt-dev php-mbstring
  apt-get install -y php-dev php-pear
  apt-get install -y libc-client2007e mlock php-curl php-gd php-imap php-ldap php-mysql uw-mailutils
  phpenmod gd curl imap ldap mbstring
  systemctl restart apache2
  echo "php installed."
  fi

if $install_sysbench ; then
  echo "Installing sysbench"
  apt-get install -y sysbench
  echo "sysbench installed."
  fi

if $install_tasksel ; then
  echo "Installing tasksel"
  apt-get install -y tasksel
  echo "tasksel installed."
  fi

if $install_xrdp ; then
  echo "Installing xrdp"
  apt-get install -y xrdp
  ufw allow from 192.168.1.0/24 to any port 3389 proto tcp
  echo "xrdp installed."
  fi

if $enable_certbot ; then
  echo "Installing certbot"
  apt install -y certbot python3-certbot-apache
  echo "certbot installed."
  fi

if $install_mailutils ; then
  echo "installing mailutils"
  debconf-set-selections <<< "postfix postfix/relayhost $RELAYHOST"
  debconf-set-selections <<< "postfix postfix/mailname string $MAILNAME"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string $MAIN_MAILER_TYPE"
  apt-get install -y mailutils
  ufw allow mail
  echo "mailutils installed."
  fi

if $install_mysql_server ; then
  echo "Installing mysql server"
###### EXTREMELY IMPORTANT: Edit /etc/mysql/mysql.conf.d/mysqld.cnf and open up bind-address * ###########
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y php-gmp php-symfony-service-implementation php-imagick php-twig-doc
  apt-get install -y php-symfony-translation
  apt-get install -y mysql-server
  ufw allow mysql
  mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
  echo "Test point mysql-server A"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  echo "Test point mysql-server B"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
  echo "Test point mysql-server C"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test_%'"
  echo "Test point mysql-server D"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_ADMIN_NAME'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$MYSQL_ADMIN_PASSWORD'"
  echo "Test point mysql-server E"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_NAME'@localhost WITH GRANT OPTION"
  echo "Test point mysql-server F"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES"
  echo "Test point mysql-server G"
  MYSQL_SERVER_BIN_DIR="/var/lib/mysql"
  MYSQL_CLIENT_CERTS_DIR="$HOME_DIRECTORY/certs"
  mkdir -p $MYSQL_CLIENT_CERTS_DIR
  cp "$MYSQL_SERVER_BIN_DIR/ca.pem" "$MYSQL_CLIENT_CERTS_DIR/$(hostname)-MySQL-ca.pem"
  cp "$MYSQL_SERVER_BIN_DIR/client-cert.pem" "$MYSQL_CLIENT_CERTS_DIR/$(hostname)-MySQL-client-cert.pem"
  cp "$MYSQL_SERVER_BIN_DIR/client-key.pem" "$MYSQL_CLIENT_CERTS_DIR/$(hostname)-MySQL-client-key.pem"
  chown -R $USER_ME:$USER_ME "$MYSQL_CLIENT_CERTS_DIR"
  echo "mysql server installed"
  fi

# phpMyAdmin should be installed AFTER php and MySQL
if $install_phpmyadmin ; then
  echo "Instlling phpmyadmin"
  # Based on https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04
  debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_ROOT_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_DB_PASS"
  apt install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl
  phpenmod mbstring
  cp $configs_directory/phpmyadmin.config.inc.php /usr/share/phpmyadmin/config.inc.php
  chown -R www-data:www-data /usr/share/phpmyadmin
  chmod 644 /usr/share/phpmyadmin/config.inc.php
#  cp $configs_directory/html/.htaccess.html.www.var /var/www/html/.htaccess
#  chown -R www-data:www-data /var/www/html/.htaccess
#  chmod 644 /var/www/html/.htaccess
  systemctl restart apache2
  echo "phpmyadmin installed."
  fi

if $install_plexmediaserver ; then
# CAUTION: NOT TESTED FOR UBUNTU 20
  echo "Installing Plex Media Server"
  rm /etc/apt/sources.list.d/plexmediaserver.list
  deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
  curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
  apt update
  apt install plexmediaserver
  ufw allow plexmediaserver
  echo "Plex Media Server installed."
  fi

if $install_webmin ; then
  echo "Installing Webmin"
  wget http://www.webmin.com/download/deb/webmin-current.deb
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y perl libnet-ssleay-perl libauthen-pam-perl \
  libpam-runtime libio-pty-perl apt-show-versions python
  dpkg --install webmin-current.deb
  rm webmin-current.deb
  ufw allow webmin
  echo "Webmin installed."
  fi

# Edit .vimrc settings
echo "Editing .vimrc settings"
touch /home/$USER_ME/.vimrc && cp /home/$USER_ME/.vimrc /home/$USER_ME/.vimrc.backup.$(date "+%Y.%m.%d-%H.%M.%S") && echo "set background=dark" > /home/$USER_ME/.vimrc && echo "set visualbell" >> /home/$USER_ME/.vimrc
chown $USER_ME:$USER_ME /home/$USER_ME/.vi*
echo ".vimrc edited."

echo ""
echo "# IMPORTANT: Copy these passwords into Roboform IMMEDIATELY and reboot."
echo "# Once you continue, these passwords cannot be recovered."
echo ""
# echo "PASSWORD_ME: $PASSWORD_ME"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "MYSQL_ADMIN_NAME: $MYSQL_ADMIN_NAME"
echo "MYSQL_ADMIN_PASSWORD: $MYSQL_ADMIN_PASSWORD"
echo "PHPMYADMIN_APP_PASS: $PHPMYADMIN_APP_PASS"
echo "PHPMYADMIN_ROOT_PASS: $PHPMYADMIN_ROOT_PASS"
echo "PHPMYADMIN_APP_DB_PASS: $PHPMYADMIN_APP_DB_PASS"
echo ""

echo Done.
exit 0
