' Pong

CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    lcd     : "LameLCD" 
    gfx     : "LameGFX" 
    ctrl    : "LameControl"   
    
    ball    : "gfx_ball"
    paddle  : "gfx_paddle"

VAR
    long    x
    long    y
    
    long    speed_x
    long    speed_y
    
    long    paddle1_y
    long    paddle2_y
    
PUB Main
    gfx.Start(lcd.Start)
    ctrl.Start
    
    repeat
        ctrl.Update
        gfx.ClearScreen

        
        if ctrl.Right
               x++
        if ctrl.Left
            x--
        if ctrl.Up
               paddle1_y--
        if ctrl.Down
               paddle1_y++
         
        gfx.Sprite(paddle.Addr, 4, paddle1_y, 0)
        gfx.Sprite(paddle.Addr, 116, paddle2_y, 0)
                
        gfx.Sprite(ball.Addr, x, y, 0)
        gfx.DrawScreen

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