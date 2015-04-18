---
layout: learnpage
title: gfx.Start
--- 

Initialize the LameGFX drawing library.

## Syntax

    Start

This command takes no parameters.

Returns a long-aligned buffer address.

## Description

This command must be called before any drawing operations can be
performed. When initialized, it returns the address of a screen-sized
buffer that LameLCD can copy from to draw to the screen. Thus, this
command must be called before [lcd.Start](lcd.Start.html) .

## Example

    PUB Main
        lcd.Start(gfx.Start)

See also: [lcd.Start](lcd.Start.html) .


