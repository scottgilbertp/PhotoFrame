#!/usr/bin/env bash

# MYDIR is the directory of this script.
# we assume that other files are in this same dir.
# (readlink is used to expand a possible relative path to an
#  absolute path)
MYDIR="$(readlink -f ${0%/*})"

# Issue warning if the difference, in minutes, between START_TIME and STOP_TIME is less
# than MIN_RUN_MINS
if [[ 10#$START_TIME -le 10#$STOP_TIME ]]; then
  # Use case of: Typical start and stop within the same day
  if [[ $(( ( $(date +%s --date "today $STOP_TIME") - $(date +%s --date "today $START_TIME") ) / 60 )) -le $MIN_RUN_MINS ]]; then
    echo "ERROR:  The difference between START_TIME and STOP_TIME is less than MIN_RUN_MINS: Photos will never get displayed!! Exiting..."
    exit 99
  fi
else
  # Use case of: Start during one day, run through midnight and stop the next day
  if [[ $(( ( $(date +%s --date "tomorrow $STOP_TIME") - $(date +%s --date "today $START_TIME") ) / 60 )) -le $MIN_RUN_MINS ]]; then
    echo "ERROR:  The difference between START_TIME and STOP_TIME is less than MIN_RUN_MINS: Photos will never get displayed!! Exiting..."
    exit 99
  fi
fi

# Sometimes, after booting, the NTP services have not quite set the 
# system clock yet.  So, if uptime is less than REBOOT_UPTIME_SECONDS when
# the service starts, we introduce a brief delay here to help ensure 
# the NTP service has time to correct the system clock before we 
# make start/stop decisions based on the current time.
if [ $(cat /proc/uptime | grep -o '^[0-9]*') -lt $REBOOT_UPTIME_SECONDS ] ; then
  [[ $DEBUG -eq 1 ]] && echo "uptime is less than $REBOOT_UPTIME_SECONDS seconds, so pausing for $BOOT_DELAY_SECONDS seconds" 
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

  [[ $DEBUG -eq 1 ]] && echo "START_TIME=$START_TIME"
  [[ $DEBUG -eq 1 ]] && echo "STOP_TIME=$STOP_TIME"
  [[ $DEBUG -eq 1 ]] && echo "STOP_TIME_ADJ=$STOP_TIME_ADJ"
  [[ $DEBUG -eq 1 ]] && echo "TIME=$TIME"

  if [[ 10#$START_TIME -lt 10#$STOP_TIME_ADJ ]]; then
    # Use case of: Typical start and stop within the same day
    if [[ 10#$TIME -ge 10#$START_TIME && 10#$TIME -lt 10#$STOP_TIME_ADJ ]]; then
      # we are currently within the display time and should start immediately
      SLEEP_TIME=0
    elif [[ 10#$TIME -lt 10#$START_TIME ]] ; then
      # we are currently before display time, so  sleep until start time later today
      # sleep time is:
      #  (unix timestamp for start time today) minus (unix timestamp for current date/time)
      SLEEP_TIME=$(( $(date +%s --date "today $START_TIME") - $(date +%s --date "now") ))
    else
      # we are currently after display time, so  sleep until start time tomorrow
      # sleep time is:
      #  (unix timestamp for start time tomorrow) minus (unix timestamp for current date/time)
      SLEEP_TIME=$(( $(date +%s --date "tomorrow $START_TIME") - $(date +%s --date "now") ))
    fi
  else
    # Use case of: Start during one day, run through midnight and stop the next day
    if  [[ 10#$TIME -ge 10#$STOP_TIME_ADJ && 10#$TIME -lt 10#$START_TIME ]]; then
      # we are currently inside the display time and should start immediately
      SLEEP_TIME=0
    else
      # we are currently outside the display time, so sleep until start time, later today
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
  
  if [[ 10#$START_TIME -lt 10#$STOP_TIME ]]; then
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
