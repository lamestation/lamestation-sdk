{{
TestMapMoveX/Y Demo
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
    map  :               "LameMap"
    ctrl :               "LameControl"
    
    box  :               "gfx_box"

    map1  :               "map_map"
    tile :               "gfx_box_s"

VAR

    long    oldx, oldy
    long    x, y
    long    adjust

CON

    w = 24
    h = 24

PUB Main

    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12
    
    repeat
        oldx := x
        oldy := y
        gfx.ClearScreen(0)

        ' move the box with the joystick
        ' first, move left and right
        ctrl.Update
        if ctrl.Left
            if x > 0
                x--
        if ctrl.Right
            if x < gfx#res_x
                x++

        ' apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveX(oldx, oldy, word[box.Addr][1], word[box.Addr][2], x)
        if adjust
            x += adjust
            gfx.InvertColor(True)


        ' then up and down
        if ctrl.Up
            if y > 0
                y--
        if ctrl.Down
            if y < gfx#res_y
                y++

        ' apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveY(oldx, oldy, word[box.Addr][1], word[box.Addr][2], y)
        if adjust
            y += adjust
            gfx.InvertColor(True)


        map.Draw(0,0)
        gfx.Sprite(box.Addr,x, y,0)

        gfx.InvertColor(False)

        lcd.DrawScreen

    
