#!/bin/bash
# This only runs at boot time and decides whether the photo frame should be started or not
# If the hour of the day is 7:00am or later AND before 10:00pm then start

# Note that the times here should correspond with the times that cron is starting 
# and stopping the photo frame. 

HOUR="$(date +%H)"

if [ $HOUR -gt "06" ] && [ $HOUR -lt "22" ]; then
  echo "We rebooted! Hour is $HOUR, so photo frame is starting..."
  /root/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "We rebooted! Hour is $HOUR, so photo frame is NOT starting..."
fi
