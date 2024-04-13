#!/usr/bin/env bash

echo "$(date +%F-%T) - Stopping photo_frame"

# turn off display
/usr/bin/vcgencmd display_power 0
# pre-bookworm, we used this:
#tvservice -o

killall fbi
