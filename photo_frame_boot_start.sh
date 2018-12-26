#!/bin/bash
# This only runs at boot time and decides whether the photo frame should be
# started or not. If the time of the day is 6:00am or later AND before 10:00pm,
# then start, else just exit.

# Note that the times here should correspond with the times that cron is 
# starting and stopping the photo frame. 

# Note: If time starts with a leading zero, bash wants to interpret it as
# octal. So, for example, a time of "0900" (which is not a valid octal number)
# causes problems.  To prevent this, the time is forced to be interpreted as 
# decimal in the comparisons by prefixing the variable with '10#'.

TIME=$(date +%H%M)
# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
MYDIR="${0%/*}"

if [[ 10#$TIME -ge 600 && 10#$TIME -lt 2200 ]]; then
  echo "We rebooted! Time is $TIME, so photo frame is starting..."
  $MYDIR/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "We rebooted! Time is $TIME, so photo frame is NOT starting..."
  # run the "stop" script to turn off the display
  $MYDIR/photo_frame_stop.sh 2>&1 >> /var/log/photo_frame.log
fi
