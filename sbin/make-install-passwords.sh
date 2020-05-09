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

echo "PASSWORD_ME=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\""
echo "PASSWORD_UBUNTU=\"$(apg -c cl_seed -a 1 -m $LENGTH_OF_PASSWORDS -n 1 -E $EXCLUDED_PASSWORD_CHARACTERS)\""
