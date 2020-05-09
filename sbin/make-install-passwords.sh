#!/bin/bash
# make-ubstall passwords.sh
# Revised 2020-05-09
# PURPOSE: Create bash code for strong passwords with no problematic characters.

NUMBER_OF_PASSWORDS=20
LENGTH_OF_PASSWORDS=32
EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"

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
echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "MYSQL_ROOT_PASSWORD=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "PHPMYADMIN_APP_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "PHPMYADMIN_ROOT_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "PHPMYADMIN_APP_DB_PASS=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "PHPMYADMIN_BLOWFISH_SECRET=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_00=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_01=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_02=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_03=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_04=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_05=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_06=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_07=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_08=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_09=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_10=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_11=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_12=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_13=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_14=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_15=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_16=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_17=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_18=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "ADDITIONAL_PASSWORD_19=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\"" >> /tmp/passwords.sh
echo "" >> /tmp/passwords.sh

chown root:root /tmp/passwords.sh
chmod 400 /tmp/passwords.sh
cat /tmp/passwords.sh