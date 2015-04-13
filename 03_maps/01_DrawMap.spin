' 03_maps/01_DrawMap.spin
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

    cavemap :   "map_cave"
    tileset :   "gfx_cave"

PUB Main
    lcd.Start(gfx.Start)
    map.Load(tileset.Addr, cavemap.Addr)
    map.Draw(0,64)
    lcd.DrawScreen

