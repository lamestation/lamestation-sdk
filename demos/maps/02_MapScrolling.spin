{{
Map Scrolling
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

    lcd     :   "LameLCD" 
    gfx     :   "LameGFX"
    ctrl    :   "LameControl"

    map     :   "map_cave"
    tileset :   "gfx_cave"

VAR
    long    xoffset
    long    yoffset
    long    bound_x
    long    bound_y

PUB Main

    lcd.Start(gfx.Start)

    gfx.LoadMap(tileset.Addr, map.Addr)
    bound_x := gfx.GetMapWidth<<3 - lcd#SCREEN_W
    bound_y := gfx.GetMapHeight<<3 - lcd#SCREEN_H
    
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
                  
        gfx.DrawMap(xoffset, yoffset)
        lcd.DrawScreen
DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT