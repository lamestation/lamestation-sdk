{{
My Yearning For Kerning
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               "LameLCD"
        gfx     :               "LameGFX"
        ctrl    :               "LameControl"

        font    :               "gfx_font4x6_b"
        dia     :               "gfx_scroll"
        maptile :               "gfx_lostatsea"
        map     :               "map_lostatsea"
        
PUB Main

    lcd.Start(gfx.Start)

    gfx.ClearScreen(0)
    gfx.LoadFont(font.Addr, " ", 0, 0)

    ' add a map for a cool effect
    gfx.LoadMap(maptile.Addr, map.Addr)
    gfx.DrawMap(0,0)

    ' cool dialog box function with customizable graphics
    DialogBox(@strang,0,32,128,24,6,6)
    lcd.DrawScreen

    repeat
        ctrl.Update
    until ctrl.A

    DialogBox(@strang2,0,32,128,24,6,6)
    lcd.DrawScreen


PUB DialogBox(str, x,y,w,h, tw, th) | dx, dy, x1, y1, w1, h1, frame

    x1 := x/tw
    y1 := y/th

    w1 := w/tw-1
    h1 := h/th-1

    repeat dy from 0 to h1
        repeat dx from 0 to w1
            frame := 0
            case dy
                0:      frame += 0
                h1:     frame += 6
                other:  frame += 3

            case dx
                0:      frame += 0
                w1:     frame += 2
                other:  frame += 1

            gfx.Sprite(dia.Addr,x+dx*tw,y+dy*th,frame)

    gfx.TextBox(str,x+tw, y+th, w-tw, h-th)

DAT

strang   byte    "TOAD: And we were lost at sea",10,"for what felt like years...",0
strang2  byte    "There was no end in sight.",0
