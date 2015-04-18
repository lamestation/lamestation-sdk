---
layout: learnpage
title: fn.TestBoxCollision
--- 

Test if two rectangular regions of the screen overlap.

## Syntax

    TestBoxCollision(x1, y1, w1, h1, x2, y2, w2, h2)

-   **x1** - Horizontal position of first region.
-   **y1** - Vertical position of first region.
-   **w1** - Width of first region.
-   **h1** - Height of first region.
-   **x2** - Horizontal position of second region.
-   **y2** - Vertical position of second region.
-   **w2** - Width of second region.
-   **h2** - Height of second region

## Description

## Example

The following demo highlights both boxes if they are overlapping on the
screen.

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ
        lcd  :               "LameLCD" 
        gfx  :               "LameGFX"
        ctrl :               "LameControl"
        fn   :               "LameFunctions"
        
        box  :               "gfx_box"
        boxo :               "gfx_box_o"

    VAR
        byte    x1, y1, x2, y2

    CON
        w = 24
        h = 24

    PUB TestBoxCollision
        lcd.Start(gfx.Start)
        x2 := 52
        y2 := 20
        
        repeat
            gfx.ClearScreen(0)
            ' move the box with the joystick
            ctrl.Update
            if ctrl.Left
                if x1 > 0
                    x1--
            if ctrl.Right
                if x1 < gfx#res_x-24
                    x1++
            if ctrl.Up
                if y1 > 0
                    y1--
            if ctrl.Down
                if y1 < gfx#res_y-24
                    y1++

            ' invert colors if the boxes are overlapping
            if fn.TestBoxCollision(x1, y1, w, h, x2, y2, w, h)
                gfx.InvertColor(True)
            gfx.Sprite(boxo.Addr,x1,y1,0)
            gfx.Sprite(boxo.Addr,x2,y2,0)
            gfx.Sprite(box.Addr,x1,y1,0)
            gfx.InvertColor(False)
            lcd.DrawScreen

See also: link.


