---
layout: learnpage
title: gfx.InvertColor
--- 

Invert black and white pixels sprite drawing.

## Syntax

    InvertColor(enabled)

-   **enabled** - A boolean expression (non/zero). A non-zero value is
    considered **TRUE** (colors inverted). Default setting is zero (no
    inversion).

## Description

This method will affect all subsequent (sprite based) drawing operations
in that - if enabled - black colored pixels are replaced by white ones
and vice versa. Gray and transparent pixels remain unchanged.

Using this method will allow for example a Panda (black ears) to appear
as a Danpa (white ears) and you only need one set of sprites.

## Example

    OBJ
        gfx  : "LameGFX"
        lcd  : "LameLCD"
        img  : "Panda"

    PUB Main
        lcd.Start(gfx.Start)

        ' more init code
     
        gfx.InvertColor(not Panda)
        gfx.Sprite(img.Addr, x, y, 0)
        lcd.DrawScreen

See also: [lcd.InvertScreen](lcd.InvertScreen.html) .


