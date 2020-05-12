#!/bin/bash
# stopwatch.sh
# Should have owner root:$USER_NAME
# Should have permissions 770
#
$SWDIR="/tmp"
$SW="$SWDIR/stopwatch"
NOW=$(($(date +%s%N)/1000000))
if [ $1 == "" ]; then
	echo "Usage: stopwatch.sh name start (e.g., stopwatch \"Test Stopwatch\" start): Starts the counter from zero."
	echo "stopwatch.sh name lap (e.g., stopwatch \"Test Stopwatch\" lap): Marks a lap and displays all laps. Can be used multiple times."
	echo "stopwatch.sh name # (e.g., stopwatch \"Test Stopwatch\" 60 ): Displays \"yes\" and returns 0 if specified number of seconds has elapsed."
	echo "   Displays \"no\" and returns 1 if specified number of seconds has not elapsed."
	exit 2
	fi
if [ $2 == "start" ]; then
	mkdir -p $SWDIR
	echo $NOW > $SW-$1
	echo "Started."
	exit 0
	fi
if [ $2 == "lap" ]; then
	mkdir -p $SWDIR
	echo $NOW >> $SW-$1
	while LAP= read -r line
	do
		echo $line
	done < $SW-$1
	exit 0
	fi

LET ELAPSED=NOW-$(read -r line < $SW-$1)
echo $ELAPSED
