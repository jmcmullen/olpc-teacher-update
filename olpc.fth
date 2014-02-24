\ Automagically Upgrade XO Firmware
\ Author: Jay McMullen
 
\ Location to look for the new firmware
: path$  " u:\fs.zd"  ;
 
\ Warn the user before they delete everything
visible
."  " cr
."  WARNING: Updating this firmware will erase all data on this XO. " cr
."  Please ensure you back-up any important files before proceeding. " cr cr
 
."  If you do not wish to update your XO firmware right now you should: " cr
."   -  Remove the USB stick from the XO device." cr
."   -  Hold down the power button until the XO device turns off." cr
."   -  Press the power button to restart your device." cr cr
 
."  The firmware update process should take no more than 10 minutes to complete." cr
."  If you still wish to proceed, please press the 'j' key." cr
 
\ Wait for user confirmation before starting
begin  key  [char] j  =  until
page
 
path$ $fs-update
page
 
\ Let the user know the process is complete
." " cr
."  Your firmware was successfully updated!" cr
."  To start using your device, you should:" cr
."   - Remove the USB stick from the XO device." cr
."   - Hold down the power button until the XO device turns off" cr
."   - Press the power button to restart the device"
begin halt again
