PhotoFrame
==========

Digital Photo Frame for Raspberry Pi

#####Requirements:
- fbi - framebuffer image viewer  
- gawk - gnu awk processor (plain awk does not work)

#####Files:
- crontab - example crontab implementation  
- photo_frame_start-*.sh  - scripts to turn on display, select images and start displaying them. Variety of scripts with different selection criteria
- photo_frame_start.sh  - symlink to select which of the photo_frame_start-*.sh scripts to currently use
- photo_frame_stop.sh - script to stop displaying images and turn off display  
- photo_frame_boot_start.sh - script to run at boot time which considers the current time and decides whether or not to run photo_frame_start.sh   
- photo_frame_excludes.txt - list of filepath globs to never show (may include comments preceeded with a "#")  
- photo_frame_phone_photos_only_start.sh  - script to turn on display, select images and start displaying them - but limited to phone photos 

There are different versions of the photo_frame_start.sh start script with different photo selection criteria.  Symlink photo_frame_start.sh to whichever version you wish to use.  Or create a cron job to change the symlink for different photo selection criteria on different days!
