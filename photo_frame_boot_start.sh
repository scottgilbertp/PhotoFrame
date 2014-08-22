#!/bin/bash
# This only runs at boot time and decides whether the photo frame should be started or not
# If the time of the day is 6:30am or later AND before 10:00pm then start

# Note that the times here should correspond with the times that cron is starting 
# and stopping the photo frame. 

TIME=$(date +%H%M)

if [ $TIME -gt 0630 ] && [ $TIME -lt 2200 ]; then
  echo "We rebooted! Time is $TIME, so photo frame is starting..."
  /root/photo_frame/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "We rebooted! Time is $TIME, so photo frame is NOT starting..."
fi
