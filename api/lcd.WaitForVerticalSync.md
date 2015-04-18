---
layout: learnpage
title: lcd.WaitForVerticalSync
--- 

Wait until the start of the next LCD frame before continuing.

## Syntax

    WaitForVerticalSync

This command takes no parameters and returns no values.

## Description

[lcd.DrawScreen](lcd.DrawScreen.html) can be called at any time to copy
the drawing buffer to the display buffer. This is likely to happen when
LameLCD is already updating the physical screen, which will cause the
screen to flicker.

INSERT IMAGE EXPLAINING THIS.

However, there is a brief period at the start of every LCD cycle where
there is no activity. Calling WaitForVerticalSync will force your
application to wait until this period before continuing with execution.
By calling it before [lcd.DrawScreen](lcd.DrawScreen.html) , you can
achieve a flicker-free display.

If frame limiting is enabled with
[lcd.SetFrameLimit](lcd.SetFrameLimit.html) , this command has no
effect.

## Example

    PUB Main
        lcd.Start(gfx.Start)
     
        repeat
            ' draw lots of stuff!!
            lcd.WaitForVerticalSync
            lcd.DrawScreen

See also: [lcd.Start](lcd.Start.html) ,
[lcd.DrawScreen](lcd.DrawScreen.html) ,
[lcd.SetFrameLimit](lcd.SetFrameLimit.html) .


