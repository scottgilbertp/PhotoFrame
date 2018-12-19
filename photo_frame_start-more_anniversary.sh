#!/bin/bash

# Total number of pictures to select
# (we currently display photos for 16 hours/day and 
#  average 100 photos/hour.)
TOTALPICS=1700

# Set DEBUG to 1 for debug messages, anything else to turn off debug
DEBUG=0

FBI='/usr/bin/fbi'
FIND='/usr/bin/find'
EXCLUDESFILE='/root/PhotoFrame/photo_frame_excludes.txt'
HTMLFILE='/var/www/html/index.html'

# cd to the base dir of the images so the relative path is shorter
cd /mnt/wizhome/scottg/Photos/

# Set "field separater" to end of line to allow spaces and other special chars
# in filepaths
IFS=$'\n\b'
NEWL=$'\n'

# Note: keep the total number of images select below a few thousand to keep from
#       exceeding max argument length. If one is displaying 2 images per minute,
#       then only 2880 images will be displayed in 24 hours. Therefore there is 
#       no benefit to including more images than that in the list.

# Build "find" parameters incorporating the patterns from the excludes file
# (skipping comments and blank lines)
EXCLUDES=""
while read line; do
  # strip off any stray trailing blanks
  line="$(echo "$line" | sed 's/ *$//')"

  if [[ $line != \#*  &&  ! "$line" == "" ]] ; then
    EXCLUDES="$EXCLUDES ! -path '${line}'"
  fi
done < $EXCLUDESFILE


#  Include 100 "good" pictures (ie: have an 'a' appended to filename suggesting
#  they have been edited)
FINDCMD="$FIND ./ $EXCLUDES ! -path '*Jaques*' -iname '*a.j*g' -print"
IMAGES="$(eval $FINDCMD | sort -R | head -n 100)"

# Include (up to) 400 "most recent" pictures (from the last 10 days)
FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -mtime -10 -print"
IMAGES="${IMAGES}${NEWL}$(eval $FINDCMD | sort -R | head -n 400)"

# Include (up to) TOTALPICS pictures from "same day of the year (+/- 1 day)"
# (match either dates with '-' separaters OR no separators and trailing underscore)
DATES="\( -path '*-$(date +%m-%d)*' \
      -or -path '*-$(date --date=yesterday +%m-%d)*' \
      -or -path '*-$(date --date=tomorrow +%m-%d)*' \
      -or -path '*$(date +%m%d)_*' \
      -or -path '*$(date --date=yesterday +%m%d)_*' \
      -or -path '*$(date --date=tomorrow +%m%d)_*' \)"

FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' ${DATES} -print"
IMAGES="${IMAGES}${NEWL}$(eval $FINDCMD | sort -R | head -n $TOTALPICS)"

# Remove duplicates
IMAGES=$(echo "$IMAGES" | sort | uniq)

# Include enough random pictures to reach target number of pics (plus 10% to
# compensate for removal of dups)
[[ $DEBUG -eq 1 ]] && echo "Num of pics before random: $(echo "$IMAGES"|wc -l)"
IMGCOUNT=$(echo "$IMAGES" | wc -l) 
if [[ $IMGCOUNT -lt $TOTALPICS ]] ; then
  RANDOMPICS=$(($TOTALPICS + $TOTALPICS/10 - $IMGCOUNT))
  [[ $DEBUG -eq 1 ]] && echo "RANDOMPICS: ${RANDOMPICS}"
  FINDCMD="$FIND ./ $EXCLUDES -iname '*.j*g' -print"
  IMAGES="${IMAGES}${NEWL}$(eval $FINDCMD | sort -R | head -n $RANDOMPICS)"
fi

[[ $DEBUG -eq 1 ]] && echo "Num of pics before removal of dups: \
  $(echo "$IMAGES" | wc -l)"

# Remove duplicate listings and randomize image list
IMAGES=$(echo "$IMAGES" | sort | uniq | sort -R | head -n $TOTALPICS)
[[ $DEBUG -eq 1 ]] && echo "Final number of pics:  $(echo "$IMAGES" | wc -l)" 
[[ $DEBUG -eq 1 ]] && exit 99

# Log IMAGES list to file:
echo "$IMAGES" > /var/log/photo_frame_image_list-$(date +%d).log

# Generate web page list of today's images
# note: Assumes that images will be displayed for an average of 36.2 seconds
#       each. This time includes: intentional display time, load time, 
#       scaling time, and blend time.
echo "<h2> $(date +'%A %F') </h2> <br>" > "$HTMLFILE"
echo "$IMAGES" | sed 's/^\.\/\(.*\)$/<a href="Photos\/\1">\1<\/a><br>/' \
  | nl \
  | gawk '{print strftime("%H:%M - ",systime() + ($1 * 36.2) ),$0 ; }' \
  >> "$HTMLFILE"

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
#  -f 'font' = specify font to use for status info
#  -readahead = read ahead images into cache (pre-fetches next image 
#               immediately after showing current image)
#  -blend = image blend time in milliseconds

$FBI -T 1 -a -t 30 -f 'DejaVu Sans Mono-23' -readahead -blend 750 $IMAGES
