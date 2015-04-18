---
layout: learnpage
title: lcd.DrawScreen
--- 

Show the contents of the drawing buffer on the screen.

## Syntax

    DrawScreen

This command takes no parameters and returns no values.

## Description

LameLCD supports frame rate limiting using the
[lcd.SetFrameLimit](lcd.SetFrameLimit.html) command. If enabled, a call
to DrawScreen will cause a delay until the next vertical syncing
period. Frame rate limiting is disabled by default.

## Example

    PUB Main
        lcd.Start(gfx.Start)
        ' ...
     
        repeat
            ' draw some stuff
            lcd.DrawScreen

See also: [lcd.WaitForVerticalSync](lcd.WaitForVerticalSync.html) ,
[lcd.Start](lcd.Start.html) ,
[lcd.SetFrameLimit](lcd.SetFrameLimit.html) .


