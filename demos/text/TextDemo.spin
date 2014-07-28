{{
LameGFX Text-Drawing Demo
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
        fn      :               "LameFunctions"
        audio   :               "LameAudio"
        
        font_8x8    :           "font8x8"
        font_6x8    :           "font6x8"
        font_4x4    :           "font4x4"
        
PUB TextDemo | x, ran, y

    lcd.Start(gfx.Start)
    audio.Start

    repeat
        gfx.ClearScreen(0)

        ThisIsATest
    
        RandomEverywhere
        ZoomToCenter
        HouseOfLeaves     
    
        audio.StopSong

PUB ThisIsATest
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen(0)
    gfx.PutString(string("THIS IS A TEST"),4,28)
    lcd.DrawScreen
    fn.Sleep(1000)


    gfx.ClearScreen(0)
    gfx.PutString(string("DO NOT ADJUST"),10,24)
    gfx.PutString(string("YOUR BRAIN"),15,32)
    lcd.DrawScreen
    fn.Sleep(1000)    


PUB HouseOfLeaves
        
    gfx.LoadFont(font_4x4.Addr, " ", 4, 4)        
        
    gfx.PutChar("c", 120, 0)
       
    gfx.PutString(string("Super Texty Fun-Time?"), 0, 0)
    gfx.PutString(string("Wow, this isn't legible at all!"), 0, 40)
    gfx.PutString(string("Well, kind of, actually."), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)        
        
    gfx.TextBox(string("Lorem ipsum dolor chicken bacon inspector cats and more"), 52, 32, 5, 32)                 
    lcd.DrawScreen
    fn.Sleep(2000)
    
    gfx.ClearScreen(0)     
    gfx.TextBox(string("I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn't make sense anymore. PutChar and PutString work by simply using the Box command. I'm working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don't waste space."),1,1,120,56)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.PutString(string("A LOT OF TEXT"), 6, 32)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.ClearScreen(0)
    lcd.DrawScreen
    fn.Sleep(1000) 


PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen(0)
    
    centerx := 64
    centery := 32
    vx := 10
    vy := 0
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        repeat count2 from 1 to 200
            gfx.ClearScreen(0)
            
            ax := (centerx - x)/20
            ay := (centery - y)/20
            
            vx += ax
            vy += ay
            
            x += vx
            y += vy
           
            gfx.PutString(string("BUY ME!!"), x-16, y-4)
            gfx.PutString(string("SUBLIMINAL"), 12, 32)
            lcd.DrawScreen   
    
        
PUB RandomEverywhere | x, y, char, ran, count
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen(0)
    repeat count from 1 to 1000
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        char := ran? & %11111
        gfx.PutChar("A" + char, x-8, y-8)
        lcd.DrawScreen
        fn.Sleep(2)




DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0


gfx_lame
word    2048  'frameboost
word    128, 64   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $5540, $5555, $0000, $0000, $5556, $5555, $0005, $5540, $5555, $0055, $5540, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $0000, $5555, $5555, $0005, $5540, $5555, $0055, $5540, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $0000, $5555, $5555, $0025, $5540, $5555, $0055, $5540, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $c000, $5555, $5555, $0035, $5540, $5555, $0355, $5570, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $c000, $5555, $5555, $0035, $5540, $5555, $0355, $5570, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $c000, $5555, $5555, $0035, $5540, $5555, $0355, $5570, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $c000, $5555, $5555, $0035, $5540, $5555, $0355, $5570, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $4000, $5555, $5555, $0015, $5540, $5555, $0155, $5550, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $4000, $5555, $5555, $0015, $5540, $5555, $0155, $5550, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $4000, $5555, $5555, $00d5, $5540, $5555, $0d55, $555c, $5555, $4015, $5555, $5555, $0155
word    $5540, $5555, $0000, $7000, $5555, $5555, $00d5, $5540, $5555, $0d55, $555c, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $7000, $5555, $555d, $00d5, $5540, $5555, $0d55, $555c, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $7000, $5555, $555d, $00d5, $5540, $5555, $0d55, $555c, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $7000, $5555, $555d, $0055, $5540, $5555, $0555, $5554, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5000, $5555, $5551, $0055, $5540, $5555, $0555, $5554, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5000, $5555, $5551, $0355, $5540, $5555, $3555, $5557, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5000, $5555, $5551, $0355, $5540, $5555, $3555, $5557, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5c00, $5555, $5573, $0355, $5540, $7555, $3555, $d557, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5c00, $5555, $5573, $0355, $5540, $7555, $3555, $d557, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5c00, $5555, $5573, $0155, $5540, $7555, $1555, $d555, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5c00, $5555, $5573, $0155, $5540, $7555, $1555, $d555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5400, $5555, $5573, $0d55, $5540, $f555, $d555, $f555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5400, $5555, $5573, $0d55, $5540, $f555, $d555, $f555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5400, $5555, $5540, $0d55, $5540, $f555, $5555, $f555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5700, $5555, $5540, $0d55, $5540, $f555, $5555, $f555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5700, $5555, $5540, $0555, $5540, $f555, $5555, $f555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5700, $d555, $55c0, $0555, $5540, $3555, $5555, $c555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5700, $d555, $55c0, $3555, $5540, $3555, $5555, $c555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5500, $d555, $55c0, $3555, $5540, $3555, $5555, $c555, $5555, $4015, $5555, $5555, $0055
word    $5540, $5555, $0000, $5500, $d555, $55c0, $3555, $5540, $3555, $5557, $cd55, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $55c0, $d555, $55c0, $3555, $5540, $3555, $5557, $cd55, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $55c0, $d555, $55c0, $1555, $5540, $3555, $5557, $cd55, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $55c0, $5555, $5555, $1555, $5540, $3555, $5557, $cd55, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $55c0, $5555, $5555, $d555, $5540, $3555, $5557, $cd55, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $55c0, $5555, $5555, $d555, $5540, $3555, $5554, $c155, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5540, $5555, $5555, $d555, $5540, $3555, $5554, $c155, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5540, $5555, $5555, $d555, $5540, $3555, $555c, $c355, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5570, $5555, $5555, $5555, $5540, $3555, $555c, $c355, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5570, $5555, $5555, $5555, $5540, $3555, $555c, $c355, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $0000, $5570, $5555, $5555, $5555, $5543, $0555, $555c, $0355, $5555, $4015, $5555, $0055, $0000
word    $5540, $5555, $5555, $5570, $5555, $5555, $5555, $5543, $0555, $555c, $0355, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $5570, $0555, $5400, $5555, $5543, $0555, $5550, $0055, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $5550, $0555, $5400, $5555, $5543, $0555, $5550, $0055, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $5550, $0555, $5400, $5555, $5541, $0555, $5550, $0055, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $555c, $0555, $5400, $5555, $5541, $0555, $5570, $00d5, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $555c, $0555, $5400, $5555, $554d, $0555, $5570, $00d5, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $555c, $0555, $5400, $5555, $554d, $0555, $5570, $00d5, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $555c, $0555, $5400, $5555, $554d, $0555, $5570, $00d5, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $555c, $0d55, $5c00, $5555, $554d, $0555, $5570, $00d5, $5555, $4015, $5555, $5555, $0555
word    $5540, $5555, $5555, $5554, $0d55, $5c00, $5555, $5545, $0555, $5540, $0015, $5555, $4015, $5555, $5555, $0555
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

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
