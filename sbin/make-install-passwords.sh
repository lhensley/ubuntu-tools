#!/bin/bash
# make-install passwords.sh
# Revised 2020-05-09
# PURPOSE: Create bash code for strong passwords with no problematic characters.

NUMBER_OF_DESIGNATED_PASSWORDS=7
NUMBER_OF_EXTRA_PASSWORDS=5
LENGTH_OF_PASSWORDS=32
EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"
TOTAL_PASSWORDS=$NUMBER_OF_DESIGNATED_PASSWORDS+NUMBER_OF_EXTRA_PASSWORDS

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

if ! [ -x "$(command -v apg)" ]; then
  apt-get update
  apt-get install -y apg
fi

echo "" > /tmp/passwords.sh
echo "# IMPORTANT: Copy these passwords into Roboform and into /tmp/passwords before running the installation script." >> /tmp/passwords.sh
echo "# The installation script will delete /tmp/passwords after installing them, and they cannot be recovered." >> /tmp/passwords.sh
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
cat /tmp/passwords.sh