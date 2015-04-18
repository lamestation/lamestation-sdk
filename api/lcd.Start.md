---
layout: learnpage
title: lcd.Start
--- 

Initialize the LameLCD library.

## Syntax

    Start(buffer)

-   **buffer** - The address of a draw buffer to be copied to the
    screen. The buffer is a long-aligned contiguous region of memory
    that is 2048 bytes in size.

## Description

Before LameLCD can be used, it must be initialized. During this
initialization, it must be passed an address to a drawing
surface. Normally this is provided by LameGFX, but it can also be a
user-defined buffer provided that size and alignment match (2048 bytes,
long-aligned).

## Example

Initialize LameLCD directly with the buffer provided by LameGFX.

    OBJ
     
    PUB Main
        lcd.Start(gfx.Start)

Save the buffer provided by LameGFX to be used for custom drawing
operations, then pass that address to LameLCD.

    VAR
        long    buffer
     
    PUB Main
        buffer := gfx.Start
        lcd.Start(buffer)

Before any object can be used, it must be declared in an OBJ block. It
is good practice to always call declare your objects with the same name.

    OBJ
        lcd :   "LameLCD"
        gfx :   "LameGFX"


