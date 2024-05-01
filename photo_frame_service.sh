#!/usr/bin/env bash

# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
# (readlink is used to expand a possible relative path to an
#  absolute path)
MYDIR="$(readlink -f ${0%/*})"

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
  
  if [[ 10#$START_TIME -lt 10#$STOP_TIME_ADJ && 10#$TIME -ge 10#$START_TIME && 10#$TIME -lt 10#$STOP_TIME_ADJ ]]; then
    # typical start and stop within the same day
    SLEEP_TIME=0
  elif [[ 10#$START_TIME -gt 10#$STOP_TIME_ADJ && 10#$TIME -ge 10#$STOP_TIME_ADJ && 10#$TIME -lt 10#$START_TIME ]]; then
    # start during one one day, run through midnight and stop the next day
    SLEEP_TIME=0
  else
    # compute how long to sleep until it is time to start displaying photos
    # Honestly, I don't fully understand this, but I copied it from somewhere and it seems to work.
    SLEEP_TIME=$(( ( $(printf 'tomorrow %s\nnow\n' $START_TIME | date -f - +%s-)0 )%86400 ))
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
  
  SLEEP_TIME=$(( ( $(printf 'tomorrow %s\nnow\n' $STOP_TIME | date -f - +%s-)0 )%86400 ))
  echo "Sleep until stop_time: $SLEEP_TIME seconds"
  sleep $SLEEP_TIME

done
