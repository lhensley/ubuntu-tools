#!/bin/bash
# cleanup-and-exit.sh
# Should have owner root:$USER_NAME
# Should have permissions 770
#

# Remove all remaining tempfiles. #####################################
rm /tmp/$LANE_SCRIPTS_PREFIX-$UUID* > /dev/null 2>&1
exit
