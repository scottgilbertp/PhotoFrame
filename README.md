PhotoFrame
==========

Digital Photo Frame for Raspberry Pi

### Requirements:
- fbi - framebuffer image viewer  
- gawk - gnu awk processor (plain awk does not work)
- nginx - webserver for display of today's list of images (optional)

### Installation
 1. Install default Raspbian (although other OS's should work with minimal adjustments)
 1. Install git and dependencies:  `apt install git fbi gawk nginx`
 1. Clone this repo: `git clone https://github.com/scottgilbert/PhotoFrame.git`
 1. Make your photos accessible on the pi's filesystem (by copying, or NFS mount, or USB drive, or whatever)
 1. Edit the photo_frame.conf file to meet your needs.  In particular, you will probably need to adjust `PHOTODIR`
 1. You should now be able to execute photo_frame_start.sh to test. Photos will not display immediately, as photo selection must complete before displaying any photos.  For me, this takes about a minute, but depending on the number of photos in the collection and the speed of the storage, this could take much longer.
 1. Once verified, create cronjobs to start/stop the photo_frame. (example provided in `crontab.sample` file)
    Note that if you change the start/stop timing, you will also need to modify the photo_frame_boot_start.sh script.

### Files:
- `crontab.sample` - example crontab implementation  
- `photo_frame.conf` - config file 
- `photo_frame_start.sh`  - script to turn on display, select images and start displaying them. (usually executed by a cron job)
- `photo_frame_stop.sh` - script to stop displaying images and turn off display (usually executed by a cron job) 
- `photo_frame_boot_start.sh` - script to run at boot time which considers the current time and decides whether or not to run photo_frame_start.sh  (executed by cron "@reboot" job or a system "init" mechanism)
- `photo_frame_excludes.txt` - list of filepath globs to never show (may include comments preceeded with a "#")  

### Notes:
`photo_frame_start.sh` will accept a single parameter of a config file.  If no config file is specified, then the default (`photo_frame.conf`) is used.  Multiple config files could be created to provide different photo selections on different days.

The `photo_frame_start.sh script` selects a list of photos and displays them.  It also, optionally generates a simple text list of photos. In the default config, the filename contains the "day of month", so only one month's of log files are kept - with older ones being overwritten by newer ones.  Optionally, an html version of the list of photos may also be produced, suitable for display by any webserver. In the default config, this is a simple "index.html" file, which gets overwritten each day.

I run this as the root user.  IF you prefer to run it as an unpriviged user, that user will need write access to the framebuffer device (`/dev/fb0`), as well as any directory where the "todays list" files are to be written, and of course, read-access to the photos to be displayed.

The script uses the `tvservice` command to turn the monitor on/off.  This works for me, but I've heard that it may not work properly with all monitors. I'm open to suggestions for a more universal way of handling this.

There are still a few things that are "hard coded". See the BUGS.txt file for other defects and limitations.
