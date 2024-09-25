PhotoFrame
==========

Digital Photo Frame for Raspberry Pi

### Requirements:
- fbi - framebuffer image viewer  
- gawk - gnu awk processor (plain awk does not work)
- nginx - webserver for display of today's list of images (optional)

### Installation
 1. Install default Raspberry Pi OS (although other linux should work with minimal adjustments)
 1. Install git and dependencies:  `apt install git fbi gawk nginx`
 1. Clone this repo: `git clone https://github.com/scottgilbert/PhotoFrame.git`
 1. Make your photos accessible on the pi's filesystem (by copying, or NFS mount, or USB drive, or whatever)
 1. Edit the photo_frame.conf file to meet your needs.  In particular, you will probably need to adjust `PHOTODIR`, and maybe `START_TIME` and `STOP_TIME`
 1. Edit the photo_frame.service file, changing the file paths to match the location on your pi
 1. Copy the photo_frame.service file where systemd expects it:  `cp photo_frame.service /etc/systemd/system/`
 1. Tell systemd to read the new photo_frame.service file: `systemctl daemon-reload`
 1. Start and enable the service: `systemct enable --now photo_frame.service`

### Files:
- `photo_frame.conf` - config file 
- `photo_frame_start.sh`  - script to turn on display, select images and start displaying them. (normally executed by photo_frame_service.sh)
- `photo_frame_stop.sh` - script to stop displaying images and turn off display (normally executed by photo_frame_service.sh)
- `photo_frame_excludes.txt` - list of filepath globs to never show (may include comments preceeded with a "#")  
- `photo_frame.service` - systemd unit file, defining the photo_frame service
- `photo_frame_service.sh` - script which runs as the service.  Loops forever, turning display on and off

### Notes:

The `photo_frame_start.sh script` selects a list of photos and displays them.  It also, optionally generates a simple text list of photos. In the default config, the filename contains the "day of month", so only one month's of log files are kept - with older ones being overwritten by newer ones.  Optionally, an html version of the list of photos may also be produced, suitable for display by any webserver. In the default config, this is a simple "index.html" file, which gets overwritten each day.

I run this as the root user.  IF you prefer to run it as an unpriviged user, that user will need write access to the framebuffer device (`/dev/fb0`), as well as any directory where the "todays list" files are to be written, and of course, read-access to the photos to be displayed.

The script uses the `vcgencmd` command to turn the monitor on/off.  Prior to bookworm, it used `tvservice`. This works for me, at least for now, but I've heard that it may not work properly with all monitors. I'm open to suggestions for a more universal way of handling this.

There are a few things that are not ideal. See the BUGS.txt file for known defects and limitations.
