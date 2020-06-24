#!/bin/bash
# lhlib

# Hoping to develop
# lh_has_files
# lh_has_subdirectories (DONE)
# lh_is_directory
# lh_is_empty
# lh_is_file
# lh_is_in_use (DONE)
# lh_is_running (DONE)
# lh_this_process_name
# lh_this_process_number

# Takes one argument: An existing path
# Returns true if the path has subdirectories, false if not.
# Example: lh_has_subdirectories "/path/to/parent/directory"
lh_has_subdirectories () {
  if [ $(find $1 -maxdepth 1 -type d | wc -l) -eq 1 ]; then
    echo "false"
    else echo "true"
    fi
  }

# Takes one argument: absolute or relative filename
# Returns true if the file is in use, false if not.
# Example: lh_is_in_use "/path/to/file"
lh_is_in_use () {
  if [ -n "$(lsof "$1" 2>/dev/null)" ]; then
    echo "true"
    else echo "false"
    fi
  }

# Takes one argument: The NAME ONLY (NOT full path) of the process in question.
# Example: lh_is_running "httpd" or ls_is_running "dnsmasq"
# THIS WILL FAIL: ls_is_running "/usr/sbin/dnsmasq"
# Flaw: Will return a false positive if a process of the same name
#     is running.
lh_is_running () {
  ps -C "$1" >/dev/null
  if [ $? -eq 0 ]; then
    echo "true"
    else echo "false"
    fi
  }
