#!/bin/bash
# installation-configs
# Revised 2020-05-09

######################################################
######### IMPORTANT! #################################
######### Fill in this section carefully, ############
######### copy-and-paste it into Roboform ############
######### BEFORE running install script ##############
NUMBER_OF_EXTRA_PASSWORDS=5
LENGTH_OF_PASSWORDS=63
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
install_plexmediaserver=false
install_sysbench=true
install_tasksel=true
install_unzip=true
install_webmin=true
# Strongly recommended
install_wget=true
# NOTE: xrdp will allow remote desktop protocol. Use with care.
install_xrdp=true
enable_ufw=true

EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"
NUMBER_OF_DESIGNATED_PASSWORDS=7
TOTAL_PASSWORDS=$NUMBER_OF_DESIGNATED_PASSWORDS+NUMBER_OF_EXTRA_PASSWORDS

work_directory=$(pwd)
running_directory=$(dirname $0)
configs_directory="$running_directory/configs"
source /etc/os-release

if ! [ -x "$(command -v apg)" ]; then
  apt-get update
  apt-get install -y apg
fi

echo "" > /tmp/passwords.sh
echo "# IMPORTANT: Copy these passwords into Roboform before continuing." >> /tmp/passwords.sh
echo "# Once you continue, they cannot be recovered." >> /tmp/passwords.sh
echo "" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 0
echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 1
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 2
echo "MYSQL_ROOT_PASSWORD=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 3
echo "PHPMYADMIN_APP_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 4
echo "PHPMYADMIN_ROOT_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 5
echo "PHPMYADMIN_APP_DB_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 6
echo "PHPMYADMIN_BLOWFISH_SECRET=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
progress-bar.sh $TOTAL_PASSWORDS 7
echo "" >> /tmp/passwords.sh

for ((i = 1; i <= $NUMBER_OF_EXTRA_PASSWORDS; i++)); do
    echo "ADDITIONAL_PASSWORD_$i=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
    let COUNTER=i+NUMBER_OF_DESIGNATED_PASSWORDS
    progress-bar.sh $TOTAL_PASSWORDS COUNTER
done

echo "" >> /tmp/passwords.sh

chown root:root /tmp/passwords.sh
chmod 500 /tmp/passwords.sh
progress-bar.sh
source /tmp/passwords.sh
cat /tmp/passwords.sh
rm /tmp/passwords.sh
read -p "Press any key to continue AFTER copying this information."
read -p "Once more just to be sure ..."
echo Version ID: $VERSION_ID
echo PHPMYADMIN_ROOT_PASS: $PHPMYADMIN_ROOT_PASS
echo install_php: $install_php





