#!/bin/bash

# cd to the base dir of the images so the relative path is shorter
cd /mnt/wizhome/scottg/Photos/

# Set "field separater" to end of line to allow spaces and other special chars in filepaths
IFS=$(echo -en "\n\b")

# Note: keep the total number of images select below about 3000 to keep from exceeding max argument length

# Include 500 random kristi pictures
IMAGES="$(/usr/bin/find ./kristi\'s\ phone\ photos\ from\ dropbox/ -iname '*.j*g' -print |/usr/bin/sort -R|/usr/bin/head -n 500)"

# Include 500 random scott pictures
IMAGES="$IMAGES $(/usr/bin/find ./iPhone_photos/ -iname '*.j*g' -print |/usr/bin/sort -R|/usr/bin/head -n 500)"

# For debugging purposes, log IMAGES list to file:
echo $IMAGES > /var/log/photo_frame_image_list.log

# turn on display
/usr/bin/tvservice -p
/bin/fbset -depth 8
/bin/fbset -depth 16

# fbi parms:
#  -T 1   = display on first console
#  -a     = autoscale images to display size
#  -t 30  = display each image for 30 seconds
#  -u     = randomize order of images
#  -noverbose = do not display status info at bottom of screen

#/usr/bin/fbi -T 1 -noverbose -a -t 30 -u $IMAGES
/usr/bin/fbi -T 1 -a -t 30 -u $IMAGES
