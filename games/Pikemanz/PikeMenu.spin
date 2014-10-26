{{
Pikemanz - Core Functions
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
OBJ
    gfx         :   "LameGFX"
    lcd         :   "LameLCD"
    
    dia         :   "gfx_dialog"
    bar         :   "gfx_bar"
    
    hp          :   "gfx_healthbar"
    hp_box      :   "gfx_health"

    font_text   :   "gfx_font6x6_b"    
    
PUB YesNo(str)
    
PUB Dialog(str)
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    MessageBox(str,1,40,72,24,6,6)
    
PUB Box(x, y, w, h, tw, th) | dx, dy, x1, y1, w1, h1, frame

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

PUB MessageBox(str, x, y, w, h, tw, th)
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    Box(x, y, w, h, tw, th) 
    gfx.TextBox(str,x+tw, y+th, w-tw, h-th)
    
    
PUB AttackDialog(attack1, attack2, attack3, attack4)
    Box(1,40,72,24,6,6)
 '   dia.Dialog(string("JAKE wants",10,"to FIGHT"))
    

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