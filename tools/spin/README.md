Development support
===============

The following objects can be used as drop-in replacements for their primary versions. This is to aid development without using the actual hardware.

## LameLCD

Redirects screen output to a VGA monitor. Pin group is set to 2 (16..23) but can be changed in the driver (constant vgrp).

##LameControl

Reads its input from a serial driver. This defaults to the PC download link so may interfere with LameSerial.
