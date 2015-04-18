---
layout: learnpage
title: lcd.InvertScreen
--- 

Invert black and white pixels on the entire screen.

## Syntax

    InvertScreen(enabled)

-   **enabled** - A boolean expression (non/zero). A non-zero value is
    considered **TRUE** (colors inverted). Default setting is zero (no
    inversion).

## Description

This method will affect the entire screen in that - if enabled - black
colored pixels are replaced by white ones and vice versa. Gray and
transparent pixels remain unchanged.

This method has an immediate effect on the output.

## Example

    CON
        _clkmode = XTAL1|PLL16X
        _xinfreq = 5_000_000

    OBJ
        gfx  : "LameGFX"
        lcd  : "LameLCD"

    PUB Main

        lcd.Start(gfx.Start)                    ' init screen and graphics
      
        gfx.ClearScreen(gfx#BLACK)              ' clear screen
        gfx.Sprite(@gfx_rpgtowncrop, 0, 0, 0)   ' draw full screen sprite

        lcd.WaitForverticalSync                 ' |
        lcd.DrawScreen                          ' display sprite when ready

        repeat 4                                ' repeat 4 times
            lcd.InvertScreen(TRUE)              ' inverted screen
            repeat 10                           ' |
                lcd.WaitForverticalSync         ' delay 10 frames
            lcd.InvertScreen(FALSE)             ' normal screen
            repeat 10                           ' |
                lcd.WaitForverticalSync         ' delay 10 frames

    DAT

    gfx_rpgtowncrop

    word    2048      'frameboost
    word    128, 64   'width, height

    word    $43c4, ...

See also: [gfx.InvertColor](gfx.InvertColor.html) .


