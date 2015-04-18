---
layout: learnpage
title: gfx.ClearScreen
--- 

Fill the screen with a repeating word of color data specified by
`        color       ` .

## Syntax

    ClearScreen(color)

-   **color** - A word of pixel data to fill the screen with.

This command returns no value.

## Description

LameGFX defines constants for a single color.

-   BLACK - \$0000
-   WHITE - \$5555
-   GRAY - \$FFFF

Any word-size value may be used, however.

## Example

    OBJ
        gfx : "LameGFX"
        lcd : "LameLCD"
        fn  : "LameFunctions"
     
    PUB Main
        lcd.Start(gfx.Start)
     
        gfx.ClearScreen(gfx#BLACK)
        lcd.DrawScreen
        fn.Sleep(1000)
        
        gfx.ClearScreen(gfx#WHITE)
        lcd.DrawScreen
        fn.Sleep(1000)
     
        gfx.ClearScreen(gfx#GRAY)
        lcd.DrawScreen
        fn.Sleep(1000)

        gfx.ClearScreen($1367)
        lcd.DrawScreen
        
        repeat


