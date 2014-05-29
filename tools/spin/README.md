Development support
===============

The following objects can be used as drop-in replacements for their primary versions. This is to aid development without using the actual hardware (e.g. using a DemoBoard or a QuickStart).

### LameLCD

Redirects screen output to a VGA monitor. The pin group defaults to 2 (pins 16..23) but can be changed in the driver (constant vgrp).

### LameControl

Reads its input from a serial driver (keys A, B, L, R, U, D). This defaults to the PC download link so may interfere with LameSerial.
