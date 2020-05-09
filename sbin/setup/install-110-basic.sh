#!/bin/bash
# install-110-basic.sh
# Revised 2020-05-07
# PURPOSE: Installs basic software.
# IMPORTANT: Check variables at the top of the script before running it!

# Still to add:
#    wordpress
#    ssh keys
#    lets encrypt
#    turn off password
#    If a clone, make some things unique: hostname, address, keys (ssh, ssl, mysql, webmin)

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
source $PROGRAM_DIRECTORY/configs/installation-configs

echo "The buck stops here."
exit

# Do updates
apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove

# Make $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access
useradd $USER_ME
useradd $USER_UBUNTU
usermod -aG sudo $USER_ME
usermod -aG sudo $USER_UBUNTU
printf "\n\nAllowUsers $USER_ME $USER_UBUNTU\n\n" >> vi /etc/ssh/sshd_config
systemctl restart sshd
echo Users $USER_ME and $USER_UBUNTU installed.

echo "$USER_ME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lane-NOPASSWD-users
echo "$USER_UBUNTU ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/lane-NOPASSWD-users
chmod 440 /etc/sudoers.d/lane-NOPASSWD-users
passwd -d $USER_ME
passwd -d $USER_UBUNTU
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
chmod 755 /etc/ssh/sshd_config
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

if $install_mailutils ; then
  debconf-set-selections <<< "postfix postfix/relayhost $RELAYHOST"
  debconf-set-selections <<< "postfix postfix/mailname string $MAILNAME"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string $MAIN_MAILER_TYPE"
  apt-get install -y mailutils
  ufw allow mail
  fi

# Edit .vimrc settings
touch /home/$USER_ME/.vimrc && cp /home/$USER_ME/.vimrc /home/$USER_ME/.vimrc.backup.$(date "+%Y.%m.%d-%H.%M.%S") && echo "set background=dark" > /home/$USER_ME/.vimrc && echo "set visualbell" >> /home/$USER_ME/.vimrc
echo .vimrc edited.

echo $0 complete.
echo You MUST reboot NOW.
