#!/bin/bash
# setup-os.sh
# Revised 2020-05-11
# PURPOSE: Installs basic software.
# IMPORTANT: Check variables at the top of the script before running it!

# Still to add:
#    wordpress
#    ssh keys
#    lets encrypt
#    turn off password
#    If a clone, make some things unique: hostname, address, keys (ssh, ssl, mysql, webmin)

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
LENGTH_OF_PASSWORDS=32
HOSTNAME="$(hostname)"
USER_ME="lhensley"
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
configs_directory="$running_directory/configs"
source /etc/os-release

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
  apt-get install -y apg
fi

EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"
NUMBER_OF_DESIGNATED_PASSWORDS=7
TEMP_PASSWORD_INCLUDE="/tmp/passwords.sh"
echo "" > $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 0
echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 1
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 2
echo "MYSQL_ROOT_PASSWORD=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 3
echo "PHPMYADMIN_APP_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 4
echo "PHPMYADMIN_ROOT_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 5
echo "PHPMYADMIN_APP_DB_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 6
echo "PHPMYADMIN_BLOWFISH_SECRET=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> $TEMP_PASSWORD_INCLUDE
progress-bar.sh $TOTAL_PASSWORDS 7
echo "" >> $TEMP_PASSWORD_INCLUDE

chown root:root $TEMP_PASSWORD_INCLUDE
chmod 500 $TEMP_PASSWORD_INCLUDE
progress-bar.sh
source $TEMP_PASSWORD_INCLUDE
rm $TEMP_PASSWORD_INCLUDE

# Update hostname
hostnamectl set-hostname $HOSTNAME
echo $HOSTNAME > /etc/hostname
chmod 644 /etc/hostname
chown root:root /etc/hostname

# Make $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access
useradd $USER_ME
useradd $USER_UBUNTU
echo $PASSWORD_ME | passwd --stdin $USER_ME
echo $PASSWORD_UBUNTU | passwd --stdin $USER_UBUNTU
usermod -aG sudo $USER_ME
usermod -aG sudo $USER_UBUNTU
printf "\n\nAllowUsers $USER_ME $USER_UBUNTU\n\n" /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
chmod 755 /etc/ssh/sshd_config
systemctl restart sshd
echo Users $USER_ME and $USER_UBUNTU installed and configured for ssh.

echo "$USER_ME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lane-NOPASSWD-users
echo "$USER_UBUNTU ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/lane-NOPASSWD-users
chmod 440 /etc/sudoers.d/lane-NOPASSWD-users
passwd -d $USER_ME
passwd -d $USER_UBUNTU
echo Passwords removed for $USER_ME and $USER_UBUNTU

# Add custom application definitions for ufw
cp $PROGRAM_DIRECTORY/configs/lane-applications /etc/ufw/applications.d/
chown root:root /etc/ufw/applications.d/lane-applications
chmod 644 /etc/ufw/applications.d/lane-applications
ufw app update lane-applications
echo Special LANE applications installed to ufw.

# CRITICAL: Install this first.
if $install_curl ; then
  apt-get install -y curl
  echo curl installed.
  fi

# Install this early.
if $install_unzip ; then
  apt-get install -y unzip
  echo unzip installed.
  fi

# Install this early.
if $install_wget ; then
  apt-get install -y wget
  echo wget installed.
  fi

if $install_apache2 ; then
  apt-get install -y apache2
  ufw allow 'Apache'
  ufw allow 'Apache Full'
  ufw allow http
  ufw allow https
  echo wget installed.
  fi

if $install_fail2ban ; then
  apt-get install -y fail2ban
  echo fail2ban installed.
  fi

if $install_net_tools ; then
  apt-get install -y net-tools
  echo net-tools installed.
  fi

if $install_openssl ; then
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  echo openssl installed.
  fi

if $install_php ; then
  apt-get install -y php libapache2-mod-php
  apt-get install -y php-mysql php-gd php-curl php-imap php-ldap
  apt-get install -y libmcrypt-dev php-mbstring
  apt-get install -y php-dev php-pear
  phpenmod gd curl imap ldap mbstring
  systemctl restart apache2
  echo php installed.
  fi

if $install_sysbench ; then
  apt-get install -y sysbench
  echo sysbench installed.
  fi

if $install_tasksel ; then
  apt-get install -y tasksel
  echo tasksel installed.
  fi

if $install_xrdp ; then
  apt-get install -y xrdp
  ufw allow from 192.168.1.0/24 to any port 3389 proto tcp
  echo xrdp installed.
  fi

if $enable_certbot ; then
  apt install -y certbot python3-certbot-apache
  echo certbot installed.
  fi

if $install_mailutils ; then
  debconf-set-selections <<< "postfix postfix/relayhost $RELAYHOST"
  debconf-set-selections <<< "postfix postfix/mailname string $MAILNAME"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string $MAIN_MAILER_TYPE"
  apt-get install -y mailutils
  ufw allow mail
  fi

if $install_mysql_server ; then
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y mysql-server
  mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES"
  fi

# phpMyAdmin should be installed AFTER php and MySQL
if $install_phpmyadmin ; then
  # Based on https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_ROOT_PASS'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_DB_PASS'
  apt install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl
  phpenmod mbstring
  systemctl restart apache2
  fi

if $install_plexmediaserver ; then
# CAUTION: NOT TESTED FOR UBUNTU 20
  rm /etc/apt/sources.list.d/plexmediaserver.list
  deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
  curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
  apt update
  apt install plexmediaserver
  ufw allow plexmediaserver
  fi

if $install_webmin ; then
  wget http://www.webmin.com/download/deb/webmin-current.deb
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y perl libnet-ssleay-perl libauthen-pam-perl \
  libpam-runtime libio-pty-perl apt-show-versions python
  dpkg --install webmin-current.deb
  rm webmin-current.deb
  ufw allow webmin
  echo Webmin installed.
  fi

# Edit .vimrc settings
touch /home/$USER_ME/.vimrc && cp /home/$USER_ME/.vimrc /home/$USER_ME/.vimrc.backup.$(date "+%Y.%m.%d-%H.%M.%S") && echo "set background=dark" > /home/$USER_ME/.vimrc && echo "set visualbell" >> /home/$USER_ME/.vimrc
echo .vimrc edited.

echo ""
echo "# IMPORTANT: Copy these passwords into Roboform IMMEDIATELY and reboot."
echo "# Once you continue, these passwords cannot be recovered."
echo ""
echo 'PASSWORD_ME: $PASSWORD_ME'
echo 'MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD'
echo 'PHPMYADMIN_APP_PASS: $PHPMYADMIN_APP_PASS'
echo 'PHPMYADMIN_ROOT_PASS: $PHPMYADMIN_ROOT_PASS'
echo 'PHPMYADMIN_APP_DB_PASS: $PHPMYADMIN_APP_DB_PASS'
# echo 'PHPMYADMIN_BLOWFISH_SECRET: $PHPMYADMIN_BLOWFISH_SECRET'
echo ""

echo Done.
exit 0
