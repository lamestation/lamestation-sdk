---
layout: learnpage
title: gfx.Blit
--- 

Copy a screen-sized (128x64) image to the screen.

## Syntax

    Blit(address)

-   **address** - The address of the image you wish to include. Should
    only be used with a single-frame image, as that's the only one
    accessible.

This command returns no value.

## Description

Sometimes it is desirable to paste a screen-sized image to the screen,
for testing, backdrops, slideshows, etc. This command is the fastest way
to perform those operations. For any other image size, the Sprite
command should be used.

## Example

    PUB Main
        lcd.Start(gfx.Start)
     
        gfx.Blit(starbackdrop.Addr)
        lcd.DrawScreen
        
        repeat

See also: [gfx.Sprite](gfx.Sprite.html) .


