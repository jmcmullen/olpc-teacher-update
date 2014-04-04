\ Automagically Install XO Operating System
\ Author: Jay McMullen - @jmcmullen

\ File names by XO model
: path0$  " u:\fs0.img"  ;
: path1$  " u:\fs1.zd"  ;
: path2$  " u:\fs2.zd"  ;
: path4$  " u:\fs4.zd"  ;
 
\ Returns the XO model component of the firmware version
: xo-version  ( -- n )  ofw-version$ drop 1+ c@ [char] 0 -  ;

\ Detects the XO model
: xo-1?     ( -- flag )  xo-version 2 =  ;
: xo-1.5?   ( -- flag )  xo-version 3 =  ;
: xo-1.75?  ( -- flag )  xo-version 4 =  ;
: xo-4?     ( -- flag )  xo-version 7 =  ;

\ Installs with the operating system proper OS image
: do-os-install
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
."                                XO System 1b Update " cr
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
."  WARNING: Updating this OS (Operating System) image will erase all data on " cr
."  this XO. Please ensure you back-up any important files before proceeding. " cr
."  It is also recomended you connect the charger for this update." cr cr
 
."  If you do not wish to update the XO OS image right now you should: " cr
."   1.  Remove the USB stick from the XO laptop." cr
."   2.  Hold down the power button until the XO laptop turns off." cr
."   3.  Press the power button to restart the laptop." cr cr
 
."  The OS image update process should take no more than 10 minutes to complete." cr
."  If you still wish to proceed, please press the 'y' key." cr
."  " cr
 
\ Wait for user confirmation before starting
begin  key  [char] y  =  until
page

."   System Update: Updating Your Software Now... " cr
."  =============================================================================" cr
." " cr
do-os-install
page
 
\ Let the user know the process is complete
."   System Update: Update Complete! " cr
."  =============================================================================" cr
."                                                                            " cr
."                                                            _____           " cr
."   Your OS image  was successfully updated!              .-'     '-.        " cr
."                                                       .'           `.      " cr
."                                                      /   .      .    \     " cr
."    To start using your laptop, you should:          :                 :    " cr
."     1. Remove the USB stick from the XO laptop.     |                 |    " cr
."     2. Hold down the power button until the XO      :   \        /    :    " cr
."        laptop is completly turned off.               \   `.____.'    /     " cr
."     3. Press the power button to restart the laptop.  `.           .'      " cr
."                                                         `-._____.-'        " cr
."                                                                            " cr 
."                                                                            " cr 
."  " cr
begin halt again
