---
layout: learnpage
title: gfx.PutChar
--- 

Draws a single character onto the screen at position (x, y).

## Syntax

    PutChar(char, x, y)

-   **char** - The character to be displayed.
-   **x** - The horizontal position at which the character is displayed.
-   **y** - The vertical position at which the character is displayed.

## Description

This command draws a single character to the screen, and does not accept
strings as an argument. This is useful for drawing special characters
like bullets, arrows, and pointers in menus.

`        PutChar       ` requires a previous call to
[gfx.LoadFont](gfx.LoadFont.html) .

## Example

This example draws LOTS AND LOTS of characters onto the screen at
random.

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        font    :   "gfx_font8x8"
            
    PUB PutChar | x, ran, y, count, char
        lcd.Start(gfx.Start)
        gfx.LoadFont(font.Addr, " ", 0, 0)
        repeat
            gfx.ClearScreen(0)
            repeat count from 1 to 1000
                ran := cnt
                x := ran? & $7F
                y := ran? & $3F
                char := ran? & %11111
                gfx.PutChar("A" + char, x-8, y-8)
                lcd.DrawScreen


