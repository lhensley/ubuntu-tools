#!/bin/bash
# configure-clone.sh
# Revised 2020-05-10
# PURPOSE: Updates unique features of a VirtualBox clone.
# IMPORTANT: Check variables at the top of the script before running it!

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
HOSTNAME=u20b
MAILNAME=$HOSTNAME
USER_ME="lhensley"
USER_UBUNTU="ubuntu"
MAIN_MAILER_TYPE="'Internet with smarthost'"
RELAYHOST="mail.twc.com" # Spectrum Internet
# RELAYHOST="mail.mchsi.com" # Mediacom Cable Internet
######### END password information ###################
######################################################

echo "Starting setup ..."

work_directory=$(pwd)
running_directory=$(dirname $0)
configs_directory="$running_directory/configs"
source /etc/os-release

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

# Generate new SSH server keys and update configs
rm /etc/ssh/ssh_host_*
/usr/sbin/dpkg-reconfigure openssh-server
printf "\n\nAllowUsers $USER_ME $USER_UBUNTU\n\n" >> /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
chmod 755 /etc/ssh/sshd_config
systemctl restart sshd

echo ""
echo "# IMPORTANT: Copy these passwords into Roboform IMMEDIATELY and reboot."
echo "# Once you continue, these passwords cannot be recovered."
echo ""
echo "PASSWORD_ME: $PASSWORD_ME"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "PHPMYADMIN_APP_PASS: $PHPMYADMIN_APP_PASS"
echo "PHPMYADMIN_ROOT_PASS: $PHPMYADMIN_ROOT_PASS"
echo "PHPMYADMIN_APP_DB_PASS: $PHPMYADMIN_APP_DB_PASS"
echo "PHPMYADMIN_BLOWFISH_SECRET: $PHPMYADMIN_BLOWFISH_SECRET"
echo ""

echo Done.
