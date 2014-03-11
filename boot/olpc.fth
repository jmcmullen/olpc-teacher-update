\ Automagically Upgrade XO Firmware
\ Author: Jay McMullen - @jmcmullen

\ Locations per XO model
: path0$  " u:\fs0.img"  ;
: path1$  " u:\fs1.zd"  ;
: path2$  " u:\fs2.zd"  ;
: path4$  " u:\fs4.zd"  ;
 
\ Returns the XO model component of the firmware version
: xo-version  ( -- n )  ofw-version$ drop 1+ c@ [char] 0 -  ;

\ Detects the XO model
: xo-1?  ( -- flag )  xo-version 2 =  ;
: xo-1.5?  ( -- flag )  xo-version 3 =  ;
: xo-1.75?  ( -- flag )  xo-version 4 =  ;
: xo-4?  ( -- flag )  xo-version 7 =  ;

\ Updates with the proper OS image
: do-os-update
   xo-1? if
      path0$ $copy-nand 
   then
   xo-1.5? if
      path1$ $fs-update
   then
   xo-1.75? if
      path2$ $fs-update
   then
   xo-4? if
      path4$ $fs-update
   then
;
 
\ Pretty splash screen (XO-SYS 1b)
visible
page
."  " cr
."  " cr
."  " cr
."  " cr
."  " cr
."              __   __  _______             _______  __   __  _______ " cr
50 MS
."             |  |_|  ||       |           |       ||  | |  ||       |" cr
50 MS
."             |       ||   _   |   ____    |  _____||  |_|  ||  _____|" cr
50 MS
."             |       ||  | |  |  |____|   | |_____ |       || |_____ " cr
50 MS
."              |     | |  |_|  |           |_____  ||_     _||_____  |" cr
50 MS
."             |   _   ||       |            _____| |  |   |   _____| |" cr
50 MS
."             |__| |__||_______|           |_______|  |___|  |_______|" cr
50 MS
."                                  ____   _______                       " cr
50 MS
."                                 |    | |  _    |                      " cr
50 MS
."                                  |   | | |_|   |                      " cr
50 MS
."                                  |   | |       |                      " cr
50 MS
."                                  |   | |  _   |                       " cr
50 MS
."                                  |   | | |_|   |                      " cr
50 MS
."                                  |___| |_______|                      " cr
50 MS
."  " cr
50 MS
."                       One Laptop Per Child: Software Update " cr
50 MS
."                                   Please Wait... " cr
2000 MS


\ Warn the user before they delete everything
page
."   System Update: Are You Sure? " cr
."  =============================================================================" cr
." " cr
."                               .----------------.  " cr
."                              | .--------------. | " cr
."                              | |      _       | | " cr
."                              | |     | |      | | " cr
."                              | |     | |      | | " cr
."                              | |     |_|      | | " cr
."                              | |      _       | | " cr
."                              | |     (_)      | | " cr
."                              | |              | | " cr
."                              | '--------------' | " cr
."                               '----------------'  " cr
."                                                   " cr 
."                                                   " cr 
."  WARNING: Updating this OS image will erase all data on this XO. " cr
."  Please ensure you back-up any important files before proceeding. " cr cr
 
."  If you do not wish to update your XO OS image right now you should: " cr
."   -  Remove the USB stick from the XO device." cr
."   -  Hold down the power button until the XO device turns off." cr
."   -  Press the power button to restart your device." cr cr
 
."  The OS image update process should take no more than 10 minutes to complete." cr
."  If you still wish to proceed, please press the 'j' key." cr
."  " cr
 
\ Wait for user confirmation before starting
begin  key  [char] j  =  until
page

."   System Update: Updating Your Software Now... " cr
."  =============================================================================" cr
." " cr
do-os-update
page
 
\ Let the user know the process is complete
."   System Update: Update Complete! " cr
."  =============================================================================" cr
."                                                                            " cr
."                                                            _____           " cr
."                                                         .-'     '-.        " cr
."   Your OS image  was successfully updated!            .'           `.      " cr
."                                                      /   .      .    \     " cr
."                                                     :                 :    " cr
."   To start using your device, you should:           |                 |    " cr
."     - Remove the USB stick from the XO device.      :   \        /    :    " cr
."     - Hold down the power button until the XO        \   `.____.'    /     " cr
."       device turns off.                               `.           .'      " cr
."     - Press the power button to restart the device.     `-._____.-'        " cr
."                                                                            " cr 
."                                                                            " cr 
."  " cr
begin halt again
