---
layout: learnpage
title: gfx.Sprite
--- 

Draw an image of any size to the screen.

## Syntax

    Sprite(source, x, y, frame)

-   **source** - The memory address of the source image.
-   **x** - The horizontal position of the sprite on the screen.
-   **y** - The vertical position of the sprite on the screen.
-   **frame** - The frame index of the displayed sprite (zero based).

This command returns no values.

## Description

## Example

Draw an image to the screen.

    OBJ
        gfx : "LameGFX"
        lcd : "LameLCD"
     
        ball : "gfx_ball"
     
    PUB Main
        lcd.Start(gfx.Start)
     
        gfx.Sprite(ball.Addr, 10, 10, 0)
        lcd.DrawScreen
        
        repeat

Draw a sprite with different frames for different directions.

    OBJ
        gfx  : "LameGFX"
        lcd  : "LameLCD"
        ctrl : "LameControl"
     
        ball : "gfx_ball"
     
    CON
        #0, UP, RIGHT, LEFT, DOWN
     
    VAR
        byte    direction
     
    PUB Main
        lcd.Start(gfx.Start)
     
        repeat
            ctrl.Update
     
            if ctrl.Up
                direction := Up
            if ctrl.Right
                direction := RIGHT
            if ctrl.Down
                direction := DOWN
            if ctrl.Left
                direction := LEFT
     
            case direction
                UP:     gfx.Sprite(ball.Addr, 10, 10, 0)
                RIGHT:  gfx.Sprite(ball.Addr, 10, 10, 1)
                DOWN:   gfx.Sprite(ball.Addr, 10, 10, 2)
                LEFT:   gfx.Sprite(ball.Addr, 10, 10, 3)
     
            gfx.DrawScreen

See also: [Sprites](Sprites.html) .


