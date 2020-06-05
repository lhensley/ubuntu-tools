#!/bin/bash
# test.sh
# Revised 2020-06-04
# PURPOSE: Install uncomplicated, no-down-side utilities.

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

$SBIN/setup/instill-utils.sh
df
