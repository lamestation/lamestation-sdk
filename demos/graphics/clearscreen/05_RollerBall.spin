{{
RollerBall
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

    lcd     :               "LameLCD" 
    gfx     :               "LameGFX"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"
    
    ball    :               "gfx_rollerball"
    font    :               "gfx_font6x8"
    
VAR
    byte    ball_frame
    byte    ball_count
    long    ball_x, ball_y
    byte    blinktimeout
    byte    blinktoggle
    word    failtimeout
PUB Blit | val

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, " ", 6, 8)
    ctrl.Start
    
    ball_x := 64
    ball_y := 24
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)

    
        if ball_x < -16
            failtimeout++
            gfx.PutString(string("YOU FAILED"),30,29)
            if failtimeout > 128
                ball_x := 64
                ball_y := 24
                failtimeout := 0
            
        else 
            ctrl.Update
            if ctrl.Up
                if ball_y > 0
                    ball_y--
            if ctrl.Down
                if ball_y < 48
                    ball_y++
            if ctrl.Left
                ball_x--
                ball_count--
            if ctrl.Right
                ball_x++
                ball_count++
            ball_count++
            if ball_count > 3
                ball_count := 0
                ball_frame++
                ball_x--
                if ball_frame > 4
                    ball_frame := 0
                
            gfx.Sprite(ball.Addr, ball_x, ball_y, 4-ball_frame)
        
            if ball_x < 30
                blinktimeout++
                if blinktimeout > 24
                    blinktimeout := 0
                    if blinktoggle
                        blinktoggle := 0
                    else
                        blinktoggle := 1
            else    
                blinktoggle := 0
                       

            if blinktoggle
                gfx.InvertColor(True)
                gfx.PutString(string("OH NO GO RIGHT!"),0,0)
                gfx.InvertColor(False)
            
        lcd.DrawScreen
        val ->= 2

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
