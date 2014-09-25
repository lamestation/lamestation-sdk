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
    
'OBJ
 '   cap :   "ScreenCapture"
    
VAR
    
    word    buffer    

OBJ
    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    audio   :   "LameAudio"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    pk      :   "PikeCore"
    
    pk2     :   "pk_mootoo"
    pk_back   :   "pk_pakechu_back"
    font_text :   "font6x6_b"
    font_num  :   "font4x6_b"
    font_tny  :   "font4x4_b"
    
        
PUB Main
    buffer := gfx.Start
    lcd.Start(buffer)

    ctrl.Start

    repeat
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)

        gfx.Sprite(pk2.Addr, 78, 0, 0)
        gfx.Sprite(pk_back.Addr, 20, 20, 0)

        StatusBox(pk2.Name,120,120, 1, 1, 1)    
        StatusBox(string("PAKECHU"),85,85, 76, 40,0)
            
        Dialog(string("JAKE wants",10,"to FIGHT"))
        
        if ctrl.B
            lcd.InvertScreen(True)
        else
            lcd.InvertScreen(False)
        
        lcd.DrawScreen

OBJ
    dia     :   "gfx_dialog"
    bar     :   "gfx_bar"
    
    hp      :   "gfx_healthbar"
    hp_box  :   "gfx_health"

PUB StatusBox(name, health, maxhealth, x, y, opposing)
    ' pikemanz name
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    gfx.PutString(name,x, y+1)
    y += 7
    
    ' health bar
    gfx.LoadFont(font_tny.Addr, " ", 0, 0)
    gfx.PutString(string("HP:"),x,y)
        
    gfx.Sprite(hp_box.Addr, x+9, y, 0)
    gfx.Sprite(hp.Addr, x+10, y+1, 0)
    y += 6
    
    ' actual health count
    if not opposing    
        gfx.LoadFont(font_num.Addr, " ", 0, 0)
        gfx.PutString(string(" 19/ 19"),x+24,y)
        y += 7
        x += 11
    
    gfx.Sprite(bar.Addr, x, y, 0)        '
    gfx.Sprite(bar.Addr, x+16, y, 0)
    

PUB YesNo(str)
    
PUB Dialog(str)
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    DialogBox(str,1,40,72,24,6,6)
    
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
