#!/bin/bash
# setup-os.sh
# PURPOSE: Installs basic software.
# IMPORTANT: Check variables at the top of the script before running it!

######################################################
######### IMPORTANT! #################################
######### Fill in this section carefully, ############
######### copy-and-paste it into Roboform ############
######### BEFORE running install script ##############
MAIN_MAILER_TYPE="'Internet with smarthost'"
RELAYHOST="mail.twc.com" # Spectrum Internet
# RELAYHOST="mail.mchsi.com" # Mediacom Cable Internet
######### END password information ###################
######################################################

install_apache2=true
install_openssl=true
install_php=true
install_certbot=true
install_mailutils=true
install_mysql_server=true
install_phpmyadmin=true
install_plexmediaserver=false # CAUTION: NOT TESTED FOR UBUNTU 20
install_webmin=true
install_zoom=true
install_chrome=true
install_handbrake=true

echo "#########################################################################"
echo "#########################################################################"
echo "#########################################################################"
echo "Starting setup ...  #####################################################"
echo "#########################################################################"
echo "#########################################################################"

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

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

# Install uncomplicated, no-down-side utilities.
$SBIN_DIR/setup/install-utils.sh

# NUMBER_OF_DESIGNATED_PASSWORDS=7
TEMP_PASSWORD_INCLUDE="/tmp/passwords.sh"
echo "" > $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 0
echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 1
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 2
echo "MYSQL_ROOT_PASSWORD=\"$(apg -c cl_seed -a 1 -m $MAX_MYSQL_PASSWORD_LENGTH -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 3
echo "MYSQL_ADMIN_PASSWORD=\"$(apg -c cl_seed -a 1 -m $MAX_MYSQL_PASSWORD_LENGTH -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 5
echo "PHPMYADMIN_APP_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 5
echo "PHPMYADMIN_ROOT_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 6
echo "PHPMYADMIN_APP_DB_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
# progress-bar.sh $NUMBER_OF_DESIGNATED_PASSWORDS 7
echo "" >> $TEMP_PASSWORD_INCLUDE

chown root:root $TEMP_PASSWORD_INCLUDE
chmod 500 $TEMP_PASSWORD_INCLUDE
# progress-bar.sh
source $TEMP_PASSWORD_INCLUDE

# Update hostname
echo "Updating hostname"
hostnamectl set-hostname $HOST_NAME
echo $HOST_NAME > /etc/hostname
chmod 644 /etc/hostname
chown root:root /etc/hostname

# Make $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access
echo "Making $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access"
# useradd $USER_ME
# useradd $USER_UBUNTU
# TWO PROBLEMS WITH THE COMMANDS BELOW: The --stdin flag doesn't work in this version of Linux, and my password is going to be dropped anyway.
# echo $PASSWORD_ME | passwd --stdin $USER_ME
# echo $PASSWORD_UBUNTU | passwd --stdin $USER_UBUNTU
usermod -aG sudo $USER_ME
# usermod -aG sudo $USER_UBUNTU
mkdir -p /home/$USER_ME/.ssh
chown -R $USER_ME:$USER_ME /home/$USER_ME/.ssh
touch $HOME_ME/.ssh/id_rsa $HOME_ME/.ssh/id_rsa.pub
SSH_KEY_NAME="$HOST_NAME-$(date "+%Y%m%d-%H%M%S")"
mv $HOME_ME/.ssh/id_rsa $HOME_ME/.ssh/id_rsa.$(date "+%Y.%m.%d-%H.%M.%S")
mv $HOME_ME/.ssh/id_rsa.pub $HOME_ME/.ssh/id_rsa.pub.$(date "+%Y.%m.%d-%H.%M.%S")
ssh-keygen -C "$SSH_KEY_NAME" -P "" -f "$HOME_ME/.ssh/id_rsa"
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
cp $GO_CONFIGS/lane-applications /etc/ufw/applications.d/
chown root:root /etc/ufw/applications.d/lane-applications
chmod 644 /etc/ufw/applications.d/lane-applications
ufw app update lane-applications
echo "Special LANE applications installed to ufw."

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

if $install_openssl ; then
  echo "Installing openssl"
  OPENSSL_PACKAGES="openssl libcurl4-openssl-dev libssl-dev libcurl4-doc"
  OPENSSL_PACKAGES="$OPENSSL_PACKAGES libidn11-dev libkrb5-dev libldap2-dev "
  OPENSSL_PACKAGES="$OPENSSL_PACKAGES librtmp-dev libssh2-1-dev zlib1g-dev libssl-doc"
  apt-get install -y 
  echo "openssl installed."
  fi

if $install_php ; then
  echo "Installing php"
  PHP_PACKAGES="php libapache2-mod-php php-mysql php-gd php-curl php-imap php-ldap"
  PHP_PACKAGES="$PHP_PACKAGES libmcrypt-dev php-mbstring php-dev php-pear"
  PHP_PACKAGES="$PHP_PACKAGES libc-client2007e mlock php-curl php-imap uw-mailutils"
  apt-get install -y $PHP_PACKAGES
  phpenmod gd curl imap ldap mbstring
  systemctl restart apache2
  echo "php installed."
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
  MYSQL_PACKAGES="mysql-server openssl libcurl4-openssl-dev libssl-dev php-gmp php-symfony-service-implementation php-imagick php-twig-doc php-symfony-translation"
  apt-get install -y $MYSQL_PACKAGES
  ufw allow mysql
  mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test_%'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_ADMIN_NAME'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$MYSQL_ADMIN_PASSWORD'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_NAME'@localhost WITH GRANT OPTION"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES"
#  echo "Test point mysql-server G"
  mkdir -p $MYSQL_CLIENT_CERTS_DIR
  cp "$MYSQL_SERVER_BIN_DIR/ca.pem" "$MYSQL_CLIENT_CERTS_DIR/$HOST_NAME-MySQL-ca.pem"
  cp "$MYSQL_SERVER_BIN_DIR/client-cert.pem" "$MYSQL_CLIENT_CERTS_DIR/$HOST_NAME-MySQL-client-cert.pem"
  cp "$MYSQL_SERVER_BIN_DIR/client-key.pem" "$MYSQL_CLIENT_CERTS_DIR/$HOST_NAME-MySQL-client-key.pem"
  chown -R $USER_ME:$USER_ME "$MYSQL_CLIENT_CERTS_DIR"
  # Install .my.cnf in home directory
    backup-file.sh $HOME_ME/.my.cnf
    cp $GO_CONFIGS/mysql/home_directory_.my.cnf $HOME_ME/.my.cnf
    replace-in-file.sh "$HOME_ME/.my.cnf" "UserValue" "$MYSQL_ADMIN_NAME"
    replace-in-file.sh "$HOME_ME/.my.cnf" "PasswordValue" "$MYSQL_ADMIN_PASSWORD"
    chown $USER_ME:$USER_ME "$HOME_ME/.my.cnf*"
    chmod 600 "$HOME_ME/.my.cnf*"
  # Install .my.cnf for root user
    backup-file.sh /root/.my.cnf
    cp $GO_CONFIGS/mysql/home_directory_.my.cnf /root/.my.cnf
    replace-in-file.sh "root/.my.cnf" "UserValue" "$MYSQL_ADMIN_NAME"
    replace-in-file.sh "root/.my.cnf" "PasswordValue" "$MYSQL_ADMIN_PASSWORD"
    chown root:root "/root/.my.cnf*"
    chmod 600 "root/.my.cnf*"
  echo "MySQL server installed."
  fi

# phpMyAdmin should be installed AFTER php and MySQL
if $install_phpmyadmin ; then
  echo "Installing phpMyAdmin"
  # Based on https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04
  debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_ROOT_PASS"
  debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_DB_PASS"
  apt install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl
  phpenmod mbstring
  cp $GO_CONFIGS/phpmyadmin.config.inc.php $PHPMYADMIN_DIR/config.inc.php
  chown -R www-data:www-data $PHPMYADMIN_DIR
  chmod 644 $PHPMYADMIN_DIR/config.inc.php
#  cp $GO_CONFIGS/html/.htaccess.html.www.var $THIS_WEB_ROOT/.htaccess
#  chown -R www-data:www-data $THIS_WEB_ROOT/.htaccess
#  chmod 644 $THIS_WEB_ROOT/.htaccess
  systemctl restart apache2
  echo "phpMyAdmin installed."
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
  WEBMIN_PACKAGES="openssl libcurl4-openssl-dev libssl-dev perl libnet-ssleay-perl libauthen-pam-perl"
  WEBMIN_PACKAGES="$WEBMIN_PACKAGES libnet-ssleay-perl libauthen-pam-perl libpam-runtime"
  WEBMIN_PACKAGES="$WEBMIN_PACKAGES libio-pty-perl apt-show-versions python"
  apt-get install -y $WEBMIN_PACKAGES
  dpkg --install webmin-current.deb
  rm webmin-current.deb
  ufw allow webmin
  echo "Webmin installed."
  fi

# Install Zoom Client
if $install_zoom ; then
  echo "Installing Zoom Client"
  wget https://zoom.us/client/latest/zoom_amd64.deb
  apt-get install -y ./zoom_amd64.deb
  rm ./zoom_amd64.deb
  echo "Zoom Client installed."
  fi

# Install Google Chrome
if $install_chrome ; then
  echo "Installing Google Chrome"
  apt-get install -y gdebi-core
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  gdebi --n google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
  echo "Google Chrome installed."
  fi

# Install MakeMKV
# DON'T USE THE SNAP INSTALLER
if $install_makemkv ; then
  echo "Installing MakeMKV"
  add-apt-repository ppa:heyarje/makemkv-beta
  apt-get update
  apt-get install -y makemkv-bin makemkv-oss
  usermod -a -G cdrom $USER_ME
  echo "MakeMKV installed."
  echo "NOT configured: License must be applied."
  fi

if $install_handbrake ; then
  echo "Installing HandBrake"
  add-apt-repository -y ppa:stebbins/handbrake-releases
  apt-get update
  apt-get install -y handbrake-gtk
  apt-get install -y handbrake-cli
  echo "HandBrake installed."
  echo "NOT configured: Presets need to be added."
  fi

# Edit .vimrc settings
echo "Editing .vimrc settings"
touch $HOME_ME/.vimrc
backup-file.sh "$HOME_ME/.vimrc"
# Retaining the following command in case the prior command fails.
# cp $HOME_ME/.vimrc $HOME_ME/.vimrc.backup.$(date "+%Y.%m.%d-%H.%M.%S")
echo "set background=dark" > $HOME_ME/.vimrc
echo "set visualbell" >> $HOME_ME/.vimrc
chown $USER_ME:$USER_ME $HOME_ME/.vi*
echo ".vimrc edited."

# Set up some cron jobs
echo "Adding cronjobs"
crontab -l > $TEMP_CRON
if grep -Fxq "ddclient" $TEMP_CRON
then
    unlink $TEMP_CRON
else
    echo "@reboot /usr/sbin/ddclient -daemon 600 -syslog #Updates dyndns.org" >> $TEMP_CRON
    echo "@reboot echo \"$(hostname) booted\" | mail $LANE_CELL #Bootup Notification" >> $TEMP_CRON
    echo "59 23 * * * $SBIN_DIR/secureserver.sh #Secure Server" >> $TEMP_CRON
    crontab $TEMP_CRON
    unlink $TEMP_CRON
fi

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
echo "# Add to $GO_CONFIGS/ssh/$USER_ME/authorized_keys:"
echo ""
echo "# $SSH_KEY_NAME"
echo "$HOME_ME/.ssh/id_rsa.pub"
echo "#"
rm $TEMP_PASSWORD_INCLUDE

echo Done.
exit 0
