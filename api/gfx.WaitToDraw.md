---
layout: learnpage
title: gfx.WaitToDraw
--- 

Wait until the last drawing operation has completed before continuing.

## Syntax

    WaitToDraw

This command takes no arguments, and returns no values.

## Description

LameGFX function calls are generally **non-blocking\*** ; that is, after
starting a graphics drawing operation, your program is allowed to
continue execution before the call has finished. Sometimes, the user may
want to create a custom drawing command for an application. For drawing
to begin, he or she must be certain that the frame buffer is available
for drawing.

`        WaitToDraw       ` forces your program to wait until drawing is
complete before continuing, so you can safely begin a drawing operation.

<sub>\*It does take time for drawing to finish, so multiple back-to-back drawing calls will start to see a blocking effect.</sub>

## Example

Create a custom drawing operation for your game.

    VAR
        word   buffer
     
    PUB HighFalootingDrawingOperation(buffer)
        ' some amazing drawing operation
     
    PUB Main
        buffer := gfx.Start
        lcd.Start(buffer)
     
        gfx.WaitToDraw
        HighFalootingDrawingOperation(buffer)
     
        lcd.DrawScreen


