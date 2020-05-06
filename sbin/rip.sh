#!/bin/bash
# rip.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/lhlib.sh

if [ "$1" == "" ]; then
  echo "Usage: rip.sh \"Title (year)\" &"
  exit -1
  fi

if [ "$2" == "" ]; then
    MINLENGTH=1200
  else if [ "$2" == "movie" ]; then
    MINLENGTH=4500
    else MINLENGTH=$2
    fi
  fi

HANDBRAKE="HandBrakeCLI"
MKV_BASE_PATH="/mnt/bertha/mkv"
MKV_PATH=$MKV_BASE_PATH/$1
BASH_SHELL="/bin/bash"
TRANSCODE_UTILITY="/usr/local/sbin/transcode.sh"

mkdir -p "$MKV_PATH"

makemkvcon --minlength=$MINLENGTH mkv disc:0 all "$MKV_PATH"
exit_status=$?
if [ $exit_status -eq 0 ] ; then
  echo "$1: Disk ripping completed successfully." | mail lanecell
  if [ $(lh_is_running "$HANDBRAKE") == "false" ] ; then
    $BASH_SHELL $TRANSCODE_UTILITY
    fi
  else echo "$1: Disk ripping FAILED. Code $exit_status" | mail lanecell
  fi

exit $?
