PhotoFrame
==========

Digital Photo Frame for Raspberry Pi

### Requirements:
- fbi - framebuffer image viewer  
- gawk - gnu awk processor (plain awk does not work)
- nginx - webserver for display of today's list of images (optional)

### Files:
- crontab - example crontab implementation  
- photo_frame_start-*.sh  - scripts to turn on display, select images and start displaying them. Variety of scripts with different selection criteria
- photo_frame_start.sh  - symlink to select which of the photo_frame_start-*.sh scripts to currently use (usually executed by a cron job)
- photo_frame_stop.sh - script to stop displaying images and turn off display (usually executed by a cron job) 
- photo_frame_boot_start.sh - script to run at boot time which considers the current time and decides whether or not to run photo_frame_start.sh  (executed by cron "@reboot" job or a system "init" mechanism)
- photo_frame_excludes.txt - list of filepath globs to never show (may include comments preceeded with a "#")  
- photo_frame_phone_photos_only_start.sh  - script to turn on display, select images and start displaying them - but limited to phone photos 

### Notes:
There are different versions of the photo_frame_start.sh start script with different photo selection criteria.  Symlink photo_frame_start.sh to whichever version you wish to use.  Or create a cron job to change the symlink for different photo selection criteria on different days!

The "*_start.sh" scripts select a list of photos and displays them.  It also generates an html version of the list of photos, suitable for display by any webserver. The default location to write this file is /usr/share/nginx/www/index.html. It also produces a simple text list of photos, written to /var/log/photo_frame_image_list-$(date +%d).log. Note that this file contains the "day of month", so only about one month's of log files are kept - with older ones being overwritten by newer ones.

There are a lot of things that are "hard coded", which really should be defined in a config file of some sort. Maybe someday, I'll tidy this up.  See the BUGS.txt file for more details.
