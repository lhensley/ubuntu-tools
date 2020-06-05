#!/bin/bash
# replace-in-file.sh

# Usage: replace-in-file.sh path_and_filename search_text replace_text
# Until I do some more work on this, the search and replace strings cannot include / \1 through \9 " ' or &

# Include header file
logger Begin $0
source $(dirname $0)/source.sh

sed -i "s/$2/$3/g" $1
