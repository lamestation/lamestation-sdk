' 03_maps/02_MapScrolling.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd     :   "LameLCD" 
    gfx     :   "LameGFX"
    map     :   "LameMap"

    mp      :   "map_cave"
    tileset :   "gfx_cave"
    ctrl    :   "LameControl"
VAR
    long    xoffset
    long    yoffset
    long    bound_x
    long    bound_y
PUB Main
    lcd.Start(gfx.Start)
    map.Load(tileset.Addr, mp.Addr)
    bound_x := map.GetWidth<<3 - lcd#SCREEN_W
    bound_y := map.GetHeight<<3 - lcd#SCREEN_H
    yoffset := bound_y
    repeat
        gfx.ClearScreen(0)
        ctrl.Update
        if ctrl.Up
            if yoffset > 0
                yoffset--
        if ctrl.Down
            if yoffset < bound_y
                yoffset++
        if ctrl.Left
            if xoffset > 0
                xoffset--
        if ctrl.Right
            if xoffset < bound_x
                xoffset++
        map.Draw(xoffset, yoffset)
        lcd.DrawScreen

