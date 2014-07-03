PhotoFrame
==========

Digital Photo Frame for Raspberry Pi

###Requirements:
- fbi - framebuffer image viewer  

###Files:
- crontab - example crontab implementation  
- photo_frame_start.sh  - script to turn on display, select images and start displaying them  
- photo_frame_stop.sh - script to stop displaying images and turn off display  
- photo_frame_boot_start.sh - script to run at boot time which considers the current time and decides whether or not to run photo_frame_start.sh   
- photo_frame_excludes.txt - list of filepath globs to never show (may include comments preceeded with a "#")  
