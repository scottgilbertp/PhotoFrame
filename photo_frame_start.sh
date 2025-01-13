#!/usr/bin/env bash

echo "$(date +%F-%T) - Starting photo_frame"

# Set "field separater" to end of line to allow spaces and other special chars
# in filepaths
IFS=$'\n\b'
NEWL=$'\n'

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

[[ $DEBUG -eq 1 ]] && echo "Excludes: $EXCLUDES"

# cd to the base dir of the images to minimize the relative path length
cd $PHOTODIR
IMAGES=''

# Include (up to) NUM_PICS_RECENT "recent" pictures 
# ("recent" means within the last NUM_PICS_RECENT_DAYS days)
if [[ $NUM_PICS_RECENT -gt 0 ]]; then
  FINDCMD="find ./ $EXCLUDES $RECENT_PICS_ADDL_PARMS $PHOTO_EXTS \
    -daystart -mtime -${NUM_PICS_RECENT_DAYS} -print"
  IMAGES="$(eval $FINDCMD | shuf -n $NUM_PICS_RECENT)"
fi

[[ $DEBUG -eq 1 ]] && echo "Number of photos selected after adding up to " \
                           "$NUM_PICS_RECENT recent: $(echo "$IMAGES"|wc -l)"

# Include (up to) NUM_PICS_ANNIV pictures from "same day of the year"
# and "almost the same day", as defined by ANNIV_DAYS_BEFORE and
# ANNIV_DAYS_AFTER.
# (match either dates with '-' separaters OR no separators and trailing underscore)
if [[ $NUM_PICS_ANNIV -gt 0 ]]; then

  # if either ANNIV_DAYS_BEFORE or ANNIV_DAYS_AFTER are unset, or not a valid integer
  # then default them to '0'
  ANNIV_DAYS_BEFORE="${ANNIV_DAYS_BEFORE:-0}"
  ANNIV_DAYS_AFTER="${ANNIV_DAYS_AFTER:-0}"
  [[ "$ANNIV_DAYS_BEFORE" =~ ^[0-9]+$ ]] || ANNIV_DAYS_BEFORE='0'  
  [[ "$ANNIV_DAYS_AFTER" =~ ^[0-9]+$ ]] || ANNIV_DAYS_AFTER='0'  

  # always include today
  DATES="\( -path '*-$(date +%m-%d)*'  -or -path '*$(date +%m%d)_*' "

  # include ANNIV_DAYS_BEFORE days before current date
  while [ "$ANNIV_DAYS_BEFORE"  -gt "0" ] ; do
    ADD_DATE="$(date --date="$ANNIV_DAYS_BEFORE days ago" +%m-%d)"
    DATES="$DATES -or -path '*-${ADD_DATE}*'"
    ADD_DATE="$(date --date="$ANNIV_DAYS_BEFORE days ago" +%m%d)"
    DATES="$DATES -or -path '*${ADD_DATE}_*'"
    ANNIV_DAYS_BEFORE="$(( $ANNIV_DAYS_BEFORE - 1 ))"
  done

  # include ANNIV_DAYS_AFTER days after current date
  while [ "$ANNIV_DAYS_AFTER"  -gt "0" ] ; do
    ADD_DATE="$(date --date="$ANNIV_DAYS_AFTER days" +%m-%d)"
    DATES="$DATES -or -path '*-${ADD_DATE}*'"
    ADD_DATE="$(date --date="$ANNIV_DAYS_AFTER days" +%m%d)"
    DATES="$DATES -or -path '*${ADD_DATE}_*'"
    ANNIV_DAYS_AFTER="$(( $ANNIV_DAYS_AFTER - 1 ))"
  done

  DATES="$DATES \)"
  # [[ $DEBUG -eq 1 ]] && echo "DATES=$DATES"
  FINDCMD="find ./ $EXCLUDES $ANNIV_PICS_ADDL_PARMS $PHOTO_EXTS ${DATES} -print"
  IMAGES="${IMAGES}${NEWL}$(eval $FINDCMD | shuf -n $NUM_PICS_ANNIV)"
fi

[[ $DEBUG -eq 1 ]] && echo "Number of photos selected after adding up to " \
                           "$NUM_PICS_ANNIV anniv: $(echo "$IMAGES"|wc -l)"

# Remove duplicates
IMAGES=$(echo "$IMAGES" | sort | uniq)

# Include enough random pictures to reach target number of pics 
# (plus RAND_PICS_ADDL_PERCENT to compensate for removal of possible dups)
[[ $DEBUG -eq 1 ]] && echo "Number of photos after removal of dups: $(echo "$IMAGES"|wc -l)"
IMGCOUNT=$(echo "$IMAGES" | wc -l) 
if [[ $IMGCOUNT -lt $TOTALPICS ]] ; then
  RANDOMPICS=$(($TOTALPICS - $IMGCOUNT))
  RANDOMPICS=$(($RANDOMPICS + ( $RANDOMPICS * $RAND_PICS_ADDL_PERCENT / 100 ) + 1))
  [[ $DEBUG -eq 1 ]] && echo "Number of random pics to add, to reach $TOTALPICS + " \
                             "${RAND_PICS_ADDL_PERCENT}% : ${RANDOMPICS}"
  FINDCMD="find ./ $EXCLUDES $RAND_PICS_ADDL_PARMS $PHOTO_EXTS -print"
  IMAGES="${IMAGES}${NEWL}$(eval $FINDCMD | shuf -n $RANDOMPICS)"
fi

[[ $DEBUG -eq 1 ]] && echo "Number of pics before removal of dups: " \
                           "$(echo "$IMAGES" | wc -l)"

# Remove duplicate listings, remove leading './',  and randomize image list
IMAGES=$(echo "$IMAGES" | sort | uniq | sed 's/^\.\///' | shuf -n $TOTALPICS)

[[ $DEBUG -eq 1 ]] && echo "Final number of pics:  $(echo "$IMAGES" | wc -l)" 
[[ $EXIT_AFTER_SELECT -eq 1 ]] && echo "$IMAGES" > /tmp/photo_frame_debug_file_list.txt
[[ $EXIT_AFTER_SELECT -eq 1 ]] && exit 50

# Log IMAGES list to file:
if [[ ! -z $PHOTO_LIST_TEXT ]] ; then
  # update filename to replace %d with the current "day of the month"
  PHOTO_LIST_TEXT="${PHOTO_LIST_TEXT/\%d/$(date +%d)}"
  echo "$IMAGES" > "$PHOTO_LIST_TEXT"
fi

# Generate web page list of today's images
# note: Assumes that images will be displayed for an average of TOTAL_TIME_PER_PHOTO 
#       seconds  each. This time includes: intentional display time, load time, 
#       scaling time, and blend time.
if [[ ! -z $PHOTO_LIST_HTML ]] ; then
  echo "<h2> $(hostname) - $(date +'%A %F') </h2> <br>" > "$PHOTO_LIST_HTML"
  echo "$IMAGES" \
    | sed "s/^\(.*\)$/<a href=\"${PHOTO_LIST_HTML_PREFIX//\//\\\/}\1\">\1<\/a><br>/" \
    | nl \
    | gawk "{print strftime(\"%H:%M - \",systime() + (\$1 * $TOTAL_TIME_PER_PHOTO) ),\$0 ; }" \
    >> "$PHOTO_LIST_HTML"
fi

[[ $DEBUG -eq 1 ]] && echo "$(date +%F-%T) - Photo selection complete. Starting display."

# For some reason, the framebuffer doesn't seem to always activate.
# switching to virt console 2 seems to fix it. Someday I want to understand this. 
chvt 2 

# turn on display
/usr/bin/vcgencmd display_power 1

# fbi parms:
#  -T 1   = display on first console
#  -a     = autoscale images to display size
#  -t     = display time each image 
#  -noverbose = do not display status info at bottom of screen
#  -f 'font' = specify font to use for status info
#  -readahead = read ahead images into cache (pre-fetches next image 
#               immediately after showing current image)
#  -blend = image blend ("cross fade") time in milliseconds

fbi -T 1 -a -t $PHOTO_DISPLAY_TIME -f $TITLE_FONT -readahead -blend $BLEND_TIME $IMAGES
