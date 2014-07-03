#!/bin/bash

FIND='/usr/bin/find'
EXCLUDESFILE='/root/photo_frame_excludes.txt'


# cd to the base dir of the images so the relative path is shorter
cd /mnt/wizhome/scottg/Photos/

# Set "field separater" to end of line to allow spaces and other special chars in filepaths
IFS=$(echo -en "\n\b")
NEWL=$(echo -en "\n\b")


# Note: keep the total number of images select below a few thousand to keep from exceeding max argument length
#       If one is displaying 2 images per minute, then only 2880 images will be displayed in 24 hours.
#       Therefore there is no benefit to including more images than that in the list.

# Build "find" parameters incorporating the patterns from the excludes file (skipping comments and blank lines)
EXCLUDES=""
while read line; do
  if [[ $line != \#* ]] && [ "$line" != "" ] ; then
    EXCLUDES="$EXCLUDES ! -path '${line}'"
  fi
done < $EXCLUDESFILE

# Include 1000 random pictures
FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -print"
IMAGES="$(eval $FINDCMD |/usr/bin/sort -R|/usr/bin/head -n 1000)"

# Include 300 "good" pictures (ie: have an 'a' appended to filename indicating they have been edited)
FINDCMD="$FIND ./ $EXCLUDES -iname '*a.j*g' -print"
IMAGES="$IMAGES$NEWL$(eval $FINDCMD |/usr/bin/sort -R|/usr/bin/head -n 500)"

# Include 300 "most recent" pictures (from the last 180 days)
FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -mtime -180 -print"
IMAGES="$IMAGES$NEWL$(eval $FINDCMD |/usr/bin/sort -R|/usr/bin/head -n 500)"

# Include 200 "most most recent" pictures (from the last 30 days)
FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -mtime -10 -print"
IMAGES="$IMAGES$NEWL$(eval $FINDCMD |/usr/bin/sort -R|/usr/bin/head -n 200)"

# Include (up to) 200 pictures from "same day of the year as today"
FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -path '*-$(date +%m-%d)*' -print"
IMAGES="$IMAGES$NEWL$(eval $FINDCMD |/usr/bin/sort -R|/usr/bin/head -n 200)"

# For debugging purposes, log IMAGES list to file:
echo $IMAGES > /var/log/photo_frame_image_list-$(date +%d).log

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
