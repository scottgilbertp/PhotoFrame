#!/usr/bin/env bash

echo "$(date +%F-%T) - Stopping photo_frame"

# turn off display
tvservice -o

killall fbi
killall fim
