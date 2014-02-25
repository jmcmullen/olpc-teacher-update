OLPC: Easy OS image Update 
===================

Purpose
-------
This script is designed to be a simple and easy method for teachers needing to automatically upgrade their XO devices OS image. Once a USB is correctly configured, it can update the OS image on boot.

How To Use
----------
 1. Name the new OS image according to the naming convention, then place it on the root directory of a USB device.
 2. Name this script **olpc.fth**, then place it inside a directory located at **/boot/** on the USB device.
 3. Plug the usb into your XO device, power it on then follow the on screen instructions.

Naming Convention
-----------------
 * For a XO-1 name it **fs0.img**.
 * For a XO-1.5 name it **fs1.zd**.
 * For a XO-1.75 name it **fs2.zd**.
 * For a XO-4 name it **fs4.zd**.
