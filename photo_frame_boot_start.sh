#!/bin/bash
# This only runs at boot time and decides whether the photo frame should be started or not
# If the time of the day is 6:00am or later AND before 10:00pm then start

# Note that the times here should correspond with the times that cron is starting 
# and stopping the photo frame. 

# Times *must* not start with a leading zero, as this causes bash to interpret them
# as octal instead of decimal.  For example, 6:00am must appear as "600" and NOT "0600".

TIME=$(date +%-H%M)

if [[ $TIME -gt 600 && $TIME -lt 2200 ]]; then
  echo "We rebooted! Time is $TIME, so photo frame is starting..."
  /root/photo_frame/photo_frame_start.sh 2>&1 >> /var/log/photo_frame.log
else
  echo "We rebooted! Time is $TIME, so photo frame is NOT starting..."
fi
