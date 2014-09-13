{{
Pikemanz Battle Engine
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    #0, RIGHT, UP, LEFT, DOWN        

OBJ
    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    pk      :   "PikeCore"
    
    pike2   :   "pk_jarzzard"
    pk_back :   "pk_pakechu_back"
    font_lg :   "font8x8_b"
    font_sm :   "font4x6_b"
    
    dia     :   "gfx_dialog"
    bar     :   "gfx_bar"

PUB Main
    lcd.Start(gfx.Start)

    ctrl.Start

    repeat
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)

        gfx.Sprite(pike2.Addr, 80, -2, 0)
        gfx.Sprite(pk_back.Addr, 20, 20, 0)

        StatusBox(string("JARZZARD"),120,120, 0, 0)    
        StatusBox(string("PAKECHU"),85,85, 64, 40)
        
        DialogBox(string("CRAP wants",10,"to FIGHT"),1,40,64,24,6,6)
        
            
        lcd.DrawScreen

PUB StatusBox(name, health, maxhealth, x, y)
    gfx.LoadFont(font_lg.Addr, " ", 7, 0)        
    gfx.PutString(name,x,y+1)
    gfx.LoadFont(font_sm.Addr, " ", 0, 0)
    gfx.PutString(string(" 19/ 19"),x+30,y+9)
    
    gfx.Sprite(bar.Addr, x+4, y+15, 0)
    gfx.Sprite(bar.Addr, x+4+16, y+15, 0)
    gfx.Sprite(bar.Addr, x+4+30, y+15, 0)
        
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
