\ Automagically Install XO Firmware Operating System
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

\ Installs the operating system image
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

\ Checks that there is enough battery to proceed.
: bat-safe?
   bat-status@ dup 1 and        ( status present )
   swap 4 and 0=                ( present not-critical-low )
   bat-soc@  d# 50  >           ( present not-critical-low less-than-half )
   and and                      ( safe? )
;

: .bat-unsafe
   page
   red-letters
   ."  " cr cr cr cr cr cr
   ."                                 .----------------.  " cr
   ."                                | .--------------. | " cr
   ."                               || |           |||| | " cr
   ."                                | '--------------' | " cr
   ."                                 '----------------'  " cr cr cr
   ."       For laptop safety reasons, the battery must be at least 50% full. " cr
   ."        Please charge your battery, or use a different one and try again. " cr cr
   ."         Please remove your USB drive then press any key to shut-down." cr cr cr cr cr cr cr cr cr cr cr cr cr
   key
   power-off begin again
;

: ?bat-safe
   bat-safe?  not  if  .bat-unsafe  then
;

\ Pretty splash screen (XO-SYS 1b)
visible
green-letters
page
."  " cr cr cr cr cr cr cr cr cr cr cr
."                             XO System 1b Update " cr
."                                 Please Wait... " cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr
2000 MS
?bat-safe
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
."                              | |     |_|      | | " cr
."                              | |              | | " cr
."                              | '--------------' | " cr
."                               '----------------'  " cr
."                                                   " cr 
."                                                   " cr 
."  WARNING: Updating this OS (Operating System) image will erase all data on " cr
."  this XO. Please ensure you back-up any important files before proceeding. " cr
."  It is also recommended you connect the charger for this update." cr cr
 
."  If you do not wish to update the XO OS image right now you should: " cr
."   1.  Remove the USB drive from the XO device." cr
."   2.  Hold down the power button until the XO device turns off." cr
."   3.  Press the power button to restart your device." cr cr
 
."  The OS image update process should take no more than 10 minutes to complete." cr
."  If you still wish to proceed, please press the 'y' key." cr cr cr
 
\ Wait for user confirmation before starting
begin  key  [char] y  =  until
page
then
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
."   Your XO was successfully updated!                     .-'     '-.        " cr
."                                                       .'           `.      " cr
."                                                      /   .      .    \     " cr
."    To start using your laptop, you should:          :                 :    " cr
."     1. Remove the USB drive from the XO device.     |                 |    " cr
."     2. Hold down the power button until the XO      :   \        /    :    " cr
."        laptop is completely turned off.              \   `.____.'    /     " cr
."     3. Press the power button to restart the laptop.  `.           .'      " cr
."                                                         `-._____.-'        " cr
."                                                                            " cr 
."                                                                            " cr 
."  " cr
begin halt again
