{{
Crazy Happy Face Sprite Demo
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}

CON
  _clkmode        = xtal1|pll16x
  _xinfreq        = 5_000_000

    MAXSPRITES = 256
    BOUND_X = 128-16
    BOUND_Y = 64-16

OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX" 
        ctrl    :               "LameControl"
        
        sprite  :               "happyface.full"
        font    :               "Font6x8"


VAR
    long    x[MAXSPRITES]
    long    y[MAXSPRITES]
    long    speedx[MAXSPRITES]
    long    speedy[MAXSPRITES]
    byte    frame[MAXSPRITES]
    byte    framewait[MAXSPRITES]    
    byte    dir[MAXSPRITES]
    byte    framecounter[MAXSPRITES]
    
    byte    maxsprite
    byte    ctrllag
    
    byte    intarray[4]

PUB SpriteDemo | s, ran

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, " ", 6, 8)
    
    gfx.ClearScreen
    gfx.TextBox(string("Sprite Demo!",10,"A/B changes the",10,"number of sprites"), 0, 0, 128, 64)
    gfx.Sprite(sprite.Addr, 56, 28, 1)
    gfx.TextBox(string("Press A to begin"), 0, 56, 128, 64)
    lcd.DrawScreen
    
    repeat
        ctrl.Update
    until ctrl.A or ctrl.B

    maxsprite := 1
    repeat s from 0 to MAXSPRITES-1
        ran := cnt
        x[s] := (ran? & $FF) // (lcd#SCREEN_W - 16)
        y[s] := (ran? & $FF) // (lcd#SCREEN_H - 16)
        speedx[s] := ((ran? & $FF // 9) - 4)
        speedy[s] := ((ran? & $FF // 9) - 4)
        frame[s] := (ran? & $FF) // 2
        framewait[s] := (ran? & $FF) // 80
        dir[s] := (ran? & $FF) // 4
    
    repeat
        gfx.ClearScreen
        
        ctrl.Update
        
        if ctrl.A or ctrl.B
                ctrllag := 0
                if ctrl.A
                    if maxsprite > 1
                        maxsprite--
                if ctrl.B
                    if maxsprite < MAXSPRITES-1
                        maxsprite++
    
        repeat s from 0 to maxsprite-1
        
            if x[s] => BOUND_X or x[s] < 0
                speedx[s] := -speedx[s]
            if y[s] => BOUND_Y or y[s] < 0
                speedy[s] := -speedy[s]
                
            x[s] += speedx[s]
            y[s] += speedy[s]
            framecounter[s]++
            if framecounter[s] > framewait[s]
                framecounter[s] := 0
                if frame[s]
                    frame[s] := 0
                else
                    frame[s] := 1
                    
                dir[s]++

            
            gfx.Sprite(sprite.Addr, x[s], y[s], (dir[s] & $3)<<1 + frame[s])
        

        Overlay
        lcd.DrawScreen
        
PUB Overlay | tmp
    tmp := maxsprite
    intarray[2] := 48+(tmp // 10)
    tmp /= 10
    intarray[1] := 48+(tmp // 10)
    tmp /= 10
    intarray[0] := 48+(tmp // 10)
    intarray[3] := 0

    gfx.PutString(@intarray, 0, 0)





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