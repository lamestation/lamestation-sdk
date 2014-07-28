{{
Ball Bouncing Demo
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}

CON

    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd  :               "LameLCD" 
    gfx  :               "LameGFX"
    ctrl :               "LameControl"
    
    ball :               "ball_16x16"
    map  :               "map"
    tile :               "box_s"

VAR

    long    oldx, oldy
    long    x, y
    long    speedx, speedy
    long    adjust

CON

    w = 16
    h = 16
    maxspeed = 20

PUB TestBoxCollision

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)
    gfx.LoadMap(tile.Addr, map.Addr)

    x := 12
    y := 12
    
    repeat
        oldx := x
        oldy := y
        gfx.ClearScreen(0)
        ctrl.Update

        ' use the joystick to control speed of the ball
        ' instead of position directly
        if ctrl.Left
            if speedx > -maxspeed
                speedx--
        if ctrl.Right
            if speedx < maxspeed
                speedx++

        x += speedx

        ' apply movement adjustments to ensure object stays within bounds
        adjust := gfx.TestMapMoveX(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], x)
        if adjust
            x += adjust
            speedx := -speedx

        ' then up and down
        if ctrl.Up
            if speedy > -maxspeed
                speedy--
        if ctrl.Down
            if speedy < maxspeed
                speedy++

        y += speedy

        ' apply movement adjustments to ensure object stays within bounds
        adjust := gfx.TestMapMoveY(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], y)
        if adjust
            y += adjust
            speedy := -speedy

        gfx.DrawMap(0,0)
        gfx.Sprite(ball.Addr,x, y,0)

        lcd.DrawScreen

    