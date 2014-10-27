{{
Pikemanz - Intro
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

    #0, UP, RIGHT, DOWN, LEFT

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    map     :               "LameMap"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

    state   :   "PikeState"
    menu    :   "PikeMenu"
    
    nash        :   "gfx_nash_fetchum"
    
        
PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    Scene
        
PUB Scene
    
    repeat
        View
PRI View

        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)        
        gfx.Sprite(nash.Addr,52,4, 0)
        
        menu.Dialog(@strang)
    
        lcd.DrawScreen
    
DAT

strang   byte    "TEACH: This is the ",10,"BACON",0

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
