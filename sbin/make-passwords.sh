#!/bin/bash
# make-passwords.sh
# Revised 2020-05-09
# PURPOSE: Create strong passwords with no problematic characters.

NUMBER_OF_PASSWORDS=20
LENGTH_OF_PASSWORDS=32
EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

apt-get update
apt-get install -y apg
apg -s -a 1 -m $LENGTH_OF_PASSWORDS -n $NUMBER_OF_PASSWORDS -E $TEST
