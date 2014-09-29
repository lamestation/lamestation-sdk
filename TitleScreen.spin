{{
Pikemanz - Title Screen
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
                     
OBJ
    lcd         :   "LameLCD"
    gfx         :   "LameGFX"

    title       :   "gfx_title"
    font_text   :   "font4x6_b"
    nash        :   "nash_fetchum"
    
    ctrl        :   "LameControl"

PUB Main
    lcd.Start(gfx.Start)
    Run
    
PUB Run
    gfx.ClearScreen(gfx#WHITE)
    gfx.LoadFont(font_text.Addr, " ", 0, 0)
    
    gfx.Sprite(title.Addr,1,10,0)
    gfx.PutString(string("Eggheadz Version"), 17, 47)
    gfx.Sprite(nash.Addr, 100,18,0)
    
    lcd.DrawScreen

    ctrl.Update    
    repeat until ctrl.A
        ctrl.Update

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