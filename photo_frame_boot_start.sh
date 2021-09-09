#!/usr/bin/env bash
# This only runs at boot time and decides whether the photo frame display should 
# be started or not. 

# If the time of the day is 6:00am or later AND before 9:45pm, then start, else 
# run the stop script (primarly just to turn off the monitor). We are only 
# starting if we are at least 15 minutes before the "stop" time - this 
# eliminates the "race condition" of starting photo selection just before "stop 
# time" and having the "stop" script run while photo selection is # still in 
# progress.  Besides, why go to all the effort to select a whole lot # of 
# photos, if we would only be able to display a handful before stopping?

# Note that the times here should correspond with the times that cron is 
# starting and stopping (minus about 15 minutes) the photo frame. 

# Note: If time starts with a leading zero, bash wants to interpret it as
# octal. So, for example, a time of "0900" (which is not a valid octal number)
# causes problems.  To prevent this, the time is forced to be interpreted as 
# decimal in the comparisons by prefixing the variable with '10#'.

TIME=$(date +%H%M)

# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
# (readlink is used to expand a possible relative path to an
#  absolute path)
MYDIR="$(readlink -f ${0%/*})"

echo -n "$(date +%F-%T) - We rebooted! Time is $TIME, so "

if [[ 10#$TIME -ge 600 && 10#$TIME -lt 2145 ]]; then
  echo "photo frame is starting..."
  $MYDIR/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "photo frame is NOT starting..."
  # run the "stop" script to turn off the display
  $MYDIR/photo_frame_stop.sh 2>&1 >> /var/log/photo_frame.log
fi
