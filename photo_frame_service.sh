#!/usr/bin/env bash

# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
# (readlink is used to expand a possible relative path to an
#  absolute path)
MYDIR="$(readlink -f ${0%/*})"

# Sometimes, after booting, the NTP services have not quite set the 
# system clock yet.  So, if uptime is less than 60 seconds when
# the service starts, we introduce a brief delay here to help ensure 
# we have accurate time before making start/stop decisions
if [ $(cat /proc/uptime | grep -o '^[0-9]*') -lt 60 ] ; then
  sleep $BOOT_DELAY_SECONDS
fi

# compute the time MIN_RUN_MINS before STOP_TIME
STOP_TIME_ADJ="$(date +%H%M --date "$STOP_TIME - $MIN_RUN_MINS minutes")"

while /bin/true; do

  #
  # - stop frame 
  #

  echo "Stop showing pictures"  
  $MYDIR/photo_frame_stop.sh 

  #
  # - sleep until start time (incl recognizing when it should start immediately)
  #

  # Note: If time starts with a leading zero, bash wants to interpret it as
  # octal. So, for example, a time of "0900" (which is not a valid octal number)
  # causes problems.  To prevent this, the time is forced to be interpreted as 
  # decimal in the comparisons by prefixing the variable with '10#'.

  # IF start_time is less than stop_time, then we are starting and stopping within the same day.
  # IF start_time is greater than stop_time, then we are starting, running through midnight, and
  #    stopping the next day.
  # The following logic accounts for these two possibilities.

  TIME=$(date +%H%M)
  
  if [[ 10#$START_TIME -lt 10#$STOP_TIME_ADJ ]]; then
    # typical start and stop within the same day
    if [[ 10#$TIME -ge 10#$START_TIME && 10#$TIME -lt 10#$STOP_TIME_ADJ ]]; then
      # we are currently inside the display time and should start immediately
      SLEEP_TIME=0
    else
      # we are currently outside the display time and sleep until start time
      # sleep time is:
      #  (unix timestamp for start time tomorrow) minus (unix timestamp for current date/time)
      SLEEP_TIME=$(( $(date +%s --date "tomorrow $START_TIME") - $(date +%s --date "now") ))
    fi
  else
    # start during one one day, run through midnight and stop the next day
    if  [[ 10#$TIME -ge 10#$STOP_TIME_ADJ && 10#$TIME -lt 10#$START_TIME ]]; then
      # we are currently inside the display time and should start immediately
      SLEEP_TIME=0
    else
      # we are currently outside the display time and sleep until start time
      # sleep time is:
      #  (unix timestamp for start time today) minus (unix timestamp for current date/time)
      SLEEP_TIME=$(( $(date +%s --date "today $START_TIME") - $(date +%s --date "now") ))
    fi
  fi
  
  echo "Sleep until start_time: $SLEEP_TIME seconds"
  sleep $SLEEP_TIME

  #
  # - start showing photos (in the background?)
  #

  echo "Start showing pictures"  
  $MYDIR/photo_frame_start.sh 2>&1 

  #
  # - sleep until stop time
  #
  
  if [[ 10#$START_TIME -lt 10#$STOP_TIME_ADJ ]]; then
    # typical start and stop within the same day
    # sleep time is:
    #  (unix timestamp for stop time) minus (unix timestamp for current date/time)
    SLEEP_TIME=$(( $(date +%s --date "today $STOP_TIME") - $(date +%s --date "now") ))
  else
    # start during one one day, run through midnight and stop the next day
    # sleep time is:
    #  (unix timestamp for stop time tomorrow) minus (unix timestamp for current date/time)
    SLEEP_TIME=$(( $(date +%s --date "tomorrow $STOP_TIME") - $(date +%s --date "now") ))
  fi

  echo "Sleep until stop_time: $SLEEP_TIME seconds"
  sleep $SLEEP_TIME

done
