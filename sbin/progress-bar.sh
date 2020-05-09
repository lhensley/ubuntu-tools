#!/bin/bash
# progress-bar.sh
# Revised 2020-05-09
# PURPOSE: Create, update, or erase a progress bar to standard output.
# Usage #-OF-ITEMS #-DONE
# If #-OF-ITEMS = 0, the progress bar is erased.
# If #-DONE < 0, #-DONE = 0
# If #-DONE > #-OF-ITEMS, #-DONE = #-OF-ITEMS

ITEMS=$1
DONE=$2
let WIDTH = $(tput cols)-2

function pounds () {
    for i in {1..$1}
        do
    	        echo -ne "#"
        done
}

function spaces () {
    for i in {1..$1}
        do
    	        echo -ne " "
        done
}

if [ $WIDTH -lt 10 ]; then
    exit
    fi

if [ $ITEMS -lt 0 ]; then
    DONE=0
    fi

if [ $DONE -lt 0 ]; then
    DONE=0
    fi

if [ $DONE -gt $ITEMS ]; then
    DONE=$ITEMS
    fi

if [ $ITEMS -lt 0 ]; then
    DONE=0
    fi

if [ $WIDTH -lt 10 ]; then
    exit
    fi

let ERASE=$WIDTH-2
if [ $ITEMS -eq 0 ]; then
    spaces($ERASE)
    echo -ne "\r"
    exit
    fi

let RANGE=$WIDTH=10
let POUNDS=$ITEMS-$DONE
let POUNDS=$POUNDS/$RANGE
let POUNDS=$POUNDS*$DONE
let SPACES=$RANGE-$POUNDS
let PERCENT=$DONE/$ITEMS

echo Width: $WIDTH
echo Items: $ITEMS
echo Done: $DONE
echo Range: $RANGE
echo Pounds: $POUNDS
echo Spaces: $SPACES
echo Percent $PERCENT
echo ""

$WIDTH=$(printf "%.0f\n" $WIDTH)
$ITEMS=$(printf "%.0f\n" $ITEMS)
$DONE=$(printf "%.0f\n" $DONE)
$RANGE=$(printf "%.0f\n" $RANGE)
$POUNDS=$(printf "%.0f\n" $POUNDS)
$SPACES=$(printf "%.0f\n" $SPACES)
$PERCENT=$(printf "%.0f\n" $PERCENT)

echo Width: $WIDTH
echo Items: $ITEMS
echo Done: $DONE
echo Range: $RANGE
echo Pounds: $POUNDS
echo Spaces: $SPACES
echo Percent $PERCENT
echo ""
