purpose: Inject additional keys into manufacturing data in the field
\ See license at end of file
\ Search for !!! for things that may need to change for different deployments

\ Leading space is required.
\ new-key-list$  ( -- )  " o1 s1 t1 w1 a1 d1"  ;
: new-key-list$  ( -- )  " o2 s2 w2"  ;

\ Different versions of software.
: teacher$  " u:\teacher.zd"  ;
: student$  " u:\student.zd"  ;

\ for debugging
\ visible

\ degrees of temperature rise in C for temp-rise2
d# 8 constant temperature-threshold

: fail-log-file$  ( -- name$ )  " int:\runin\fail.log"   ;
: stock-boot-file$  ( -- name$ )  " int:\runin\final.fth"   ;

: do-rename
   2>r  2dup  2r>  $copy  $delete
;

: $safe-delete   ( $name -- )
    2dup $file-exists?  if
       2dup $delete
    then
    2drop
;

: format-date  ( s m h d m y -- adr len )
   push-decimal
   >r >r >r >r >r >r
   <#
   [char] Z hold
   r> u# u# drop
   r> u# u# drop
   r> u# u# drop
   [char] T hold
   r> u# u# drop
   r> u# u# drop
   r> u# u# u# u#
   u#>
   pop-base
;

: fail-backup-file$  ( -- name$ )
   time&date format-date " int:\%runin\%fail-%s.log" sprintf
;

: do-wait 
   cr
   ." Remove USB drive and press any key to shutdown" cr
   key
   power-off
;

: down-xo
   ." Nothing else to do" cr 
   ." power down in 5 sec" cr
   d# 5000 ms  power-off
;

: set-path-name  ( -- )
   button-o game-key?  if  " \boot-alt"  else  " \boot"  then  pn-buf place ;

: set-device-name  ( -- )
   " /chosen" find-package  if                       ( phandle )
      " bootpath" rot  get-package-property  0=  if  ( propval$ )
         get-encoded-string                          ( bootpath$ )
         [char] \ left-parse-string  2nip            ( dn$ )
         dn-buf place                                ( )
      then
   then
;

: set-macros ( -- )
  set-device-name
  set-path-name
;

\ returns internal size
: internal-SD ( -- n ) 
  internal-disk-size bebc200. d+ h# 3b9aca00 um/mod nip .d 
;

\ Returns a number identifying the XO version - 2 for XO-1, 3 for XO-1.5
: xo-version  ( -- n )  ofw-version$ drop 1+ c@ [char] 0 -  ;

\ To pass hardware specific arguments we define the xo-1? and xo-1.5? flags   
\ Returns true if the machine is XO-1
: xo-1?  ( -- flag )  xo-version 2 =  ;
\ Returns true if the machine is XO-1.5
: xo-1.5?  ( -- flag )  xo-version 3 =  ;
\ Returns true if the machine is XO-1.75
: xo-1.75?  ( -- flag )  xo-version 4 =  ;
\ Returns true if the machine is XO-4
: xo-4?  ( -- flag )  xo-version 7 =  ;

: temp-fail ( -- )
   visible
   show-fail
   cr cr ." Please e-mail OLPC Australia at support@laptop.org.au with the phrase:" cr
   ." 'Heat spreader test failed - "
   " SN" find-tag  if
      ?-null
   type 
   then
   ."  in the subject line." cr
   do-wait
;

: .temp-rise2  ( -- fail? )
   ." Testing heat spreader... "
   " temp-rise" eval                               ( delta-degrees )
   ." temperature rose " dup .d ." degrees C" cr   ( delta-degrees )
   temperature-threshold >=                        ( fail? )
   dup  if                                         ( fail? )
      temp-fail                                    ( fail? )
   then
;

: check-temp-rise
  " select /switches" eval
  " .temp-rise2" eval
  " unselect" eval
;

: menu-mod ( -- )
  rp0 @ rp! 0 handler ! ['] menu to user-interface (menu) do-wait
  ['] quit to user-interface quit 
;

: xo1-boot
  " console=ttyS0,115200 console=tty0 fbcon=font:SUN12x22 selinux=0" expand$ to boot-file
  " ${DN}${PN}\10\vmlinuz"    expand$ to boot-device
  " ${DN}${PN}\10\initrd.img" expand$ to ramdisk
  boot
;

: xo15-boot
  " console=ttyS0,115200 console=tty0 fbcon=font:SUN12x22 selinux=0" expand$ to boot-file
  " ${DN}${PN}\15\vmlinuz"    expand$ to boot-device
  " ${DN}${PN}\15\initrd.img" expand$ to ramdisk
  boot
;

: xo175-boot
  " console=ttyS2,115200 console=tty0 fbcon=font:SUN12x22 selinux=0" expand$ to boot-file
  " ${DN}${PN}\17\vmlinuz"    expand$ to boot-device
  " ${DN}${PN}\17\initrd.img" expand$ to ramdisk
  boot
;

: xo4-boot
  " console=ttyS2,115200 console=tty0 fbcon=font:SUN12x22 selinux=0" expand$ to boot-file
  " ${DN}${PN}\40\vmlinuz"    expand$ to boot-device
  " ${DN}${PN}\40\initrd.img" expand$ to ramdisk
  dcon-unfreeze
  boot
;

: do-boot
   xo-1? if
      ." booting XO-1" cr
      xo1-boot
   then
   xo-1.5? if
      ." booting XO-1.5" cr
      xo15-boot
   then
   xo-1.75? if
      ." booting XO-1.75" cr
      xo175-boot
   then
   xo-4? if
      ." booting XO-4" cr
      xo4-boot 
   then
;

: is-compatible?
  xo-4? if
      true
  else
      page
        red-letters
        ."  " cr cr cr cr cr cr cr cr
        ."                                    :(       " cr cr cr cr cr
        ."       This device is not compatible with this new software update. " cr
        ."        Please make sure you only try to update XO-4 model laptops. " cr cr
        ."          Remove your usb drive and press any key to shut-down." cr cr cr cr cr cr cr cr cr cr cr cr cr
        key
        power-off
        false
   then
;

: no-file
   ." not found" cr cr
   red-screen
   do-wait
;

: .exists ( str len -- ) 
    2dup $file-exists? if true
      else false 
    then
;

: do-nand-update
   xo-1? if
      s" u:\fs0.img" .exists if
         " copy-nand u:\fs0.img" eval
      else 
         ." u:\fs0.img " no-file
      then    
   then
   xo-1.5? if
      s" u:\fs1.zd" .exists if
         " fs-update u:\fs1.zd" eval
      else 
         ." u:\fs1.zd " no-file
      then
   then  
   xo-1.75? if
      s" u:\fs2.zd" .exists if
         " fs-update u:\fs2.zd" eval
      else 
         ." u:\fs2.zd " no-file
      then
   then
   xo-4? if
      s" u:\fs4.zd" .exists if
            " fs-update u:\fs4.zd" eval
      else 
         ." u:\fs4.zd " no-file
      then
   then
;

d# 128 buffer: dirname$
d# 128 buffer: file$
: $bundles-pattern  ( pattern$ -- )  \ add a set of files to the tar file
   2dup canonical-path                                  ( pattern$ canonical$ )
   file&dir 2nip dirname$ place  \ note source dir      ( pattern$ )
   begin-search
   begin
      another-match?
   while                                                ( 8attributes name$ )
      dirname$ count file$ place                        ( name$ )
      file$ $cat                                        ( )
      exit true
      drop-attributes
   repeat
;

: bundles-list ( -- flag )
   " u:\bundles\*" $bundles-pattern if
      true
   else
      false
   then
;

: check-bundles? ( -- flag )
   " u:\bundles" is-dir? if
      true
   else
      false
   then
;

: check-custom?  ( -- flag )
   s" u:\scripts\yum.cmd" .exists if exit true
   then
   s" u:\scripts\asroot" .exists if exit true
   then
   s" u:\scripts\asolpc" .exists if exit true
   then
   check-bundles? if
      bundles-list if
         true
      else
         false
      then
   else
      false   
   then
;

: check-boot?  ( -- flag )
   xo-1? if
      s" u:\boot\10\vmlinuz" .exists if
         s" u:\boot\10\initrd.img" .exists if
            true exit
         then
      then
   then
   xo-1.5? if
      s" u:\boot\15\vmlinuz" .exists if
         s" u:\boot\15\initrd.img" .exists if
            true exit
         then
      then
   then
   xo-1.75? if
      s" u:\boot\17\vmlinuz" .exists if
         s" u:\boot\17\initrd.img" .exists if
            true exit
         then
      then
   then
   xo-4? if
      s" u:\boot\40\vmlinuz" .exists if
         s" u:\boot\40\initrd.img" .exists if
            true exit
         then
      then
   then
   false
;

: do-boot?
   check-boot? if
      check-custom? if
         dcon-freeze 
         do-boot
      else
         show-fail
         cr cr ." You requested customisation routine but addon files were NOT found." cr
      then
   else
      show-fail
      cr cr ." You do not have the required vmlinuz or initrd.img to preform this operation." cr
   then
   do-wait
;

: do-boot-after?
   check-boot? if
      check-custom? if
         do-nand-update dcon-freeze do-boot
      else
         do-nand-update
         cr cr ." Operating system installation: " 
         green-letters ."  Successful. " black-letters
         cr cr ." No add-ons found. " cr
      then
   else
      do-nand-update
      cr cr ." Operating system installation: " 
      green-letters ."  Successful. " black-letters
      cr cr ." NOTE: vmlinuz or initrd.img NOT found" cr
   then
   do-wait 
;

[ifndef] put-ascii-tag ( value$ name$ -- )
: put-ascii-tag ( value$ name$ -- )
   2swap dup if add-null then 2swap ( value$' key$ )  
   ($add-tag)                          ( )
;

[then]

[ifndef] close-audio  ( -- )
: close-audio  ( -- )
   audio-ih  if
      audio-ih close-dev
      0 to audio-ih
   then
;

[then] 

[ifndef] free-wav ( --- )
: free-wav ( --- )
   pcm-base if
      pcm-base /pcm-output " dma-free" $call-audio 0 is pcm-base
   then
;

[then] 

[ifndef] stop-sound ( -- )
: stop-sound ( -- )
   " stop-sound" ['] $call-audio catch  if  2drop  then
   free-wav close-audio
;

[then]

[ifndef] bat-safe?
: bat-safe?
   bat-soc@ h# 32 >  if
        true 
   else
        visible
        page
        red-letters
          ."  " cr cr cr cr cr cr
          ."                                 .----------------.  " cr
          ."                                | .--------------. | " cr
          ."                               || |           |||| | " cr
          ."                                | '--------------' | " cr
          ."                                 '----------------'  " cr cr cr
        ."       For safety reasons, we require a battery that is at least 50% full. " cr
        ."        Please charge your battery, or use a different one and try again. " cr cr
        ."         Please remove your usb drive then press any key to shut-down." cr cr cr cr cr cr cr cr cr cr cr cr cr
        key
        power-off
        false
   then
;

[then]

[ifndef] bat-test
: bat-test
   ['] ?enough-power  catch  ?dup  if  
      ." checking battery... " cr
      bat-safe?
   else
      ." XO is on AC " cr
   then
;

[then]


[ifndef] do-firmware-update2 ( img$ -- )
: do-firmware-update2  ( img$ -- )

\ Keep .error from printing an input sream position report
\ which makes a buffer@<address> show up in the error message
  ['] noop to show-error

  visible

   tuck flash-buf  swap move   ( len )

   ['] ?image-valid  catch  ?dup  if    ( )
      visible
      red-letters
      ." Bad firmware image file - "  .error
      ." Continuing with old firmware" cr
      black-letters
      exit
   then

   true to file-loaded?

   d# 12,000 wait-until   \ Wait for EC to notice the battery

\   ['] ?enough-power  catch  ?dup  if
\      visible
\      red-letters
\      ." Unsafe to update firmware now - " .error
\      ."  Continuing with old firmware" cr
\      black-letters
\      exit
\   then

   " Updating firmware" ?lease-debug-cr sec-trg?

\  Older code with no pretty covering
   ec-indexed-io-off?  if
     visible
     ." Restarting to enable SPI FLASH writing."  cr
     d# 3000 ms
     ec-ixio-reboot
     " update-ec-flash" eval     
     security-failure
   then

\  Newer code with pretty covering
\   if
\     visible jots 
\      ." Restarting to enable SPI FLASH writing."  cr
\      h# bb8 ms
\      " update-ec-flash" eval     
\      ec-power-cycle
\      security-failure
\   then

   \ Latch alternate? flag for next startup
   alternate?  if  [char] A h# 82 cmos!  then
\   jots ['] jot to spi-progress 
   reflash      \ Should power-off and reboot
   show-x
   ." Reflash returned, unexpectedly" \ .security-failure
;

[then]

[ifndef] tmp-fw-test? ( img$ -- )
: tmp-fw-test? ( img$ -- )
   /flash <>  if  show-x  ." Invalid Firmware image" security-failure then
   (fw-version)          ( file-version# )
   rom-pa (fw-version)   ( file-version# rom-version# )
\   signature-offset + 7 + ((fw-version))
\   ofw-version-int
   u<
;
 
[then]

[ifndef] down-fw? 
: down-fw? ( -- flag )
   ." Checking for downgrade firmware" cr
   xo-1? if
      " ${DN}${PN}\10\downfw.zip" expand$
   then
   xo-1.5? if
      " ${DN}${PN}\15\downfw1.zip" expand$
   then
   xo-1.75? if
      " ${DN}${PN}\17\downfw2.zip" expand$
   then
   xo-4? if
      " ${DN}${PN}\40\downfw4.zip" expand$
   then
   ['] (boot-read) catch  if  2drop exit  then
   img$  tmp-fw-test?  if
     green-letters ." downfw on usb is > version running  " cr  black-letters
     exit
   then
   red-letters ." downfw on usb is < version running  " cr  black-letters
   img$ do-firmware-update2
;

[then]

[ifndef] start-nb ( -- )
: start-nb  " nb-secure" eval ;

[then]

[ifndef] do-tests ( -- )
: do-tests xo-1? if 
     " test-all" eval
  else
     " menu-mod" eval  
  then
;

[then]

[ifndef] do-memtest ( -- )
: do-memtest  " memtest" eval ;

[then]

[ifndef] do-mfg-data ( -- )
: do-mfg-data  " .mfg-data" eval ;

[then]

[ifndef] key-location-template  ( -- adr len ) " u:\keys%\%s.pub"
: key-location-template  ( -- adr len )  " u:\keys%\%s.pub"  ;

[then]

[ifndef] find-key-file  ( basename$ -- false | adr len true ) 
: find-key-file  ( basename$ -- false | adr len true )
   key-location-template sprintf               ( filename$ )
   open-dev dup  if                            ( ih )
      >r                                       ( )
      " size" r@ $call-method drop  ?dup  if   ( len )
         dup alloc-mem  swap                   ( adr len )
         2dup " read" r@ $call-method          ( adr len actual )
         over <>  if                           ( adr len )
            free-mem                           ( )
            ." Key file short read" cr         ( )
            false                              ( false )
         else                                  ( adr len )
            true                               ( adr len true )
         then                                  ( false | adr len true )
      else                                     ( )
         ." Empty key file" cr                 ( )
         false                                 ( false )
      then                                     ( false | adr len true )
      r> close-dev                             ( false | adr len true )
   then                                        ( false | adr len true )
;

[then]

[ifndef] inject-key  ( keyname$ -- )
: inject-key  ( keyname$ -- )

;

[then]

[ifndef] inject-keys  ( -- )
: inject-keys  ( -- )
   
;

[then]

[ifndef] put-tag ( value$ key$ -- )
: put-tag ( value$ key$ -- )
   put-ascii-tag
;

[then]

[ifndef] do-lock
: do-lock
   " int:\boot" is-dir? if
      " u:\boot\locked.fth" " int:\boot\locked.fth" $copy 
   then
   get-mfg-data
   " BD"  ($delete-tag)
   " u:\boot\mfgdata.fth int:\boot\locked.fth"   " BD" put-tag
   flash-write-enable
   (put-mfg-data)
\   kbc-off
   d# 100 ms
   no-kbc-reboot
   kbc-on
   do-wait
;

[then]

[ifndef] lock-xo ( -- )
: lock-xo ( -- )
   visible
   show-fail
   cr cr ." Manufacturing data missing " cr cr
   ." Some important information is missing from your XO's hardware. " cr
   ." This is normal if you have changed your motherboard. Please e-mail " cr
   ." OLPC Australia at support@laptop.org.au with the phrase: " cr
   ." 'Manufacturing data missing' in the subject line. We will be happy to assist. " cr cr

   " int:\boot\locked.fth" $read-file  0=  if  ( adr len )
      " int:\boot\locked.fth.save" $safe-delete
\      ." saving locked.fth as locked.fth.save" cr
      " int:\boot\locked.fth" " int:\boot\locked.fth.save" do-rename
   then
   do-lock
;

[then]

[ifndef] check-sg-status  ( -- )
: check-sg-status  ( -- )
   " SG" find-tag  if  
      ." SG tag present. " cr
   else
      ." SG tag missing. " cr cr
      lock-xo
   then
;

[then]

[ifndef] check-smt-status  ( -- )
: check-smt-status  ( -- )
   " SS" find-tag  if 
      ." SS tag present. " cr
   else                                                
      ." SS tag missing. " cr cr
      lock-xo            
   then
;

[then]

[ifndef] get-mb-tags  ( -- )
: get-mb-tags  ( -- )
   " B#" find-tag  if
      ." B# tag present. " cr
   else
      ." Missing B# tag !!!" cr cr
      lock-xo
   then
   ." PASS board number: " type cr
;

[then]

[ifndef] get-sn-value  ( -- )
: get-sn-value  ( -- )
   " SN" find-tag  if
      ?-null
   else
      ." Missing SN tag !!!" cr cr
      lock-xo
   then
   ." PASS serial number: " type cr
;

[then]

[ifndef] check-mfgdata  ( -- )
: check-mfgdata  ( -- )
   check-sg-status
   check-smt-status
   get-mb-tags
   get-sn-value
;

[then]

[ifndef] set-ts-value  ( -- )
: set-ts-value  ( -- )
   " TS"          ($delete-tag)
   " SHIP"        " TS"  put-tag
;

[then]

[ifndef] end-runin ( -- )
: end-runin ( -- )
   ." clearing runin" cr
   " int:\runin\repass.fth" $safe-delete
   " int:\runin\final.fth.sav" $safe-delete
   " int:\runin\final.fth" $safe-delete
   get-mfg-data
   " BD"  ($delete-tag)
   set-ts-value
   flash-write-enable
   (put-mfg-data)
   no-kbc-reboot
   kbc-on
   do-wait
;

[then]

[ifndef] do-runin? ( -- )
: do-runin? ( -- )
   ." Type R to start runin, any other key to skip 4 hour runin test. " cr
   key dup emit cr  upc [char] R =  if
      ." Setting state to start runin." cr
      get-mfg-data
      " BD"  ($delete-tag)
      " RUNIN"        " TS"  put-tag
      " u:\boot\olpc.fth int:\boot\olpc.fth"   " BD" put-tag

      ." Remove usbkey during reboot, replace when booted" cr
      flash-write-enable
      (put-mfg-data)
      no-kbc-reboot
      kbc-on
      do-wait
   then
   ." runin NOT selected" cr
   do-wait
;

[then]

[ifndef] rerunin  ( -- )
: rerunin  ( -- )
   " int:\runin\final.fth" $safe-delete
   fail-log-file$ fail-backup-file$ do-rename
;

[then]

[ifndef] after-runin  ( -- )
: after-runin  ( -- )
   visible
   stock-boot-file$ if
      ." Stock runin boot file found." cr
      fail-log-file$ $read-file  0=  if  ( adr len )
         page
         show-fail
         ." Type a key to see the failure log"
         key drop  cr cr
         list
         ." Type R to restart runin, any other key to power off "
         key dup emit cr  upc [char] R =  if
            ." Resetting state to restart runin." cr
            ." The old failure log is in " fail-backup-file$ type cr
            rerunin
            reboot
         else
            power-off
         then
      else
         ." No log file present should of passed." cr
         end-runin
      then
   then
   ." Stock runin boot file NOT found." cr
   ." Should never get here" cr
   red-screen
   do-wait
;

[then]

[ifndef] check-BD  ( -- )
 : check-BD  ( -- )
   " BD" find-tag  if 
      ." Boot override present. " cr
      after-runin
   else                                                
      ." No boot override. " cr
   then
;

[then]

[ifndef] olpcau-menu ( -- )
: olpcau-menu ( -- )
\ Pretty splash screen (XO-SYS 2 Beta)
visible
green-letters
page
."  " cr cr cr cr cr cr cr cr cr cr cr
."                       XO-system 2 (Android Beta) Update " cr
."                                 Please Wait... " cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr cr
2000 MS
bat-safe? if
is-compatible? if
\ Warn the user before they delete everything
page
."   XO-system 2 Update (Android Beta) " cr
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
."  It is also recommended you connect your charger for this update." cr cr
 
."  If you do not wish to update your XO OS image right now you should: " cr
."   1.  Remove the USB stick from the XO device." cr
."   2.  Hold down the power button until the XO device turns off." cr
."   3.  Press the power button to restart your device." cr cr
 
."  The OS image update process should take no more than 5 minutes to complete." cr
."  If you still wish to proceed, please press the 'y' key." cr cr cr
 
\ Wait for user confirmation before starting
begin  key  [char] y  =  until
page
then
then
."   Please select which edition you wish to install. " cr
."  =============================================================================" cr
." " cr
." " cr
." Press 1 for:" cr
."    Student Edition (No Play Store)" cr
." " cr
." " cr
." Press 2 for:" cr
."    Unlocked Edition (Play Store for Teachers/Adults)" cr
." " cr
." " cr
." " cr
." " cr
." " cr
key case
  [char] 1 of
    student$ $fs-update
  endof
  [char] 2 of
    teacher$ $fs-update
  endof
endcase 
page
 
\ Let the user know the process is complete
."   System Update: Update Complete! " cr
."  =============================================================================" cr
."                                                                            " cr
."                                                            _____           " cr
."   Your XO was successfully updated!                     .-'     '-.        " cr
."                                                       .'           `.      " cr
."                                                      /   .      .    \     " cr
."    To start using your device, you should:          :                 :    " cr
."     1. Remove the USB stick from the XO device.     |                 |    " cr
."     2. Hold down the power button until the XO      :   \        /    :    " cr
."        device is completely turned off.              \   `.____.'    /     " cr
."     3. Press the power button to restart the device.  `.           .'      " cr
."     4. Be patient. First start up can take upwards of   `-._____.-'        " cr
."        5 minutes. This is normal.                                          " cr
."                                                                            " cr 
."                                                                            " cr 
."  " cr
begin halt again
;
[then]

[ifndef] ?ofw-reflash2
\ Check for new firmware.
: ?ofw-reflash2  ( -- )
   ." Checking for firmware" cr
   xo-1? if
      ." found XO-1 " cr
      " ${DN}${PN}\10\bootfw.zip" expand$
   then
   xo-1.5? if
      ." found XO-1.5 " cr 
      " ${DN}${PN}\15\bootfw.zip" expand$
   then
   xo-1.75? if
      ." found XO-1.75 " cr 
      " ${DN}${PN}\17\bootfw.zip" expand$
   then
   xo-4? if
      ." found XO-4 " cr 
      " ${DN}${PN}\40\bootfw4.zip" expand$
   then
   ['] (boot-read) catch  if  2drop exit  then
   img$  firmware-up-to-date?  if
      green-letters ." firmware on usb is =< version running  " cr  black-letters
   exit
   then
   img$ do-firmware-update2
;

[then]

[ifndef] keyject-error  ( msg$ -- )
: keyject-error  ( msg$ -- )
   red-letters  ." Not injecting because:   "  type  cr  black-letters
   ?ofw-reflash2
   visible
   update-ec-flash
   cr olpcau-menu
;

[then]

[ifndef] already-injected?  ( -- flag )
\ True if the all the requested tags are already present.
\ This prevents endless looping.
: already-injected?  ( -- flag )
   new-key-list$  begin  dup  while  ( $ )
      bl left-parse-string           ( $' name$ )
      find-tag  if                   ( $ value$ )
         2drop                       ( $ )
      else                           ( $ )
         2drop  false exit
      then                           ( $ )
   repeat                            ( $ )
   2drop true
;

[then]

[ifndef] do-keyject?  ( -- flag )
: do-keyject?  ( -- flag )
   already-injected?   if
      " Keys Already Present" keyject-error
      false exit
   then
   true
;

[then]

[ifndef] ?keyject  ( -- )
: ?keyject  ( -- )
   green-letters ." Security Key Injector" cr cr  black-letters
   do-keyject?  if
      down-fw?
      flash-write-enable
      inject-keys
      flash-write-disable
   then
;

: olpc-fth-boot-me
   stop-sound
   set-macros
   bat-test
   check-mfgdata
   check-BD
   ?keyject
;
olpc-fth-boot-me

\ LICENSE_BEGIN
\ Copyright (c) 2011 One Laptop per Child Australia
\ Copyright (c) 2007 FirmWorks
\ 
\ Permission is hereby granted, free of charge, to any person obtaining
\ a copy of this software and associated documentation files (the
\ "Software"), to deal in the Software without restriction, including
\ without limitation the rights to use, copy, modify, merge, publish,
\ distribute, sublicense, and/or sell copies of the Software, and to
\ permit persons to whom the Software is furnished to do so, subject to
\ the following conditions:
\ 
\ The above copyright notice and this permission notice shall be
\ included in all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
\ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
\ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
\ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
\ LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
\ OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
\ WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\
\ LICENSE_END