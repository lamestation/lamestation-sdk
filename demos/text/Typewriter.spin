{{
Typewriter Text Demo
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

    lcd      : "LameLCD"
    gfx      : "LameGFX"
    fn       : "LameFunctions"
    audio    : "LameAudio"
    
    font_6x8 : "font6x8_normal_w"
    famus    : "gfx_spacegirl"
    blehtrd  : "song_blehtroid"
        
PUB TypewriterTextDemo | count

    lcd.Start(gfx.Start)

    audio.Start
    audio.SetWaveform(1)
    audio.SetADSR(110, 90, 30, 100) 
    audio.LoadSong(blehtrd.Addr)
    audio.LoopSong

    gfx.ClearScreen(0)

    gfx.Sprite(famus.Addr,38,0,0)

    lcd.DrawScreen
    fn.Sleep(2000)

    count := 0
    repeat
        Typewriter(string("I FIRST BATTLED THE",10,"DURPEES ON THE PLANET",10,"PHEEBES. IT WAS THERE",10,"THAT I FOILED MY",10,"DINNER AND HAD TO",10,"ASK FOR THE CHECK..."),0,0,128,64, 6, 8, count)
        count++
        fn.Sleep(80)

        lcd.DrawScreen
    while count < 160


PUB Typewriter(stringvar, origin_x, origin_y, w, h, tilesize_x, tilesize_y, countmax) | char, x, y, count

    x := origin_x
    y := origin_y
    
    count := 0
    repeat strsize(stringvar)
        count++
        char := byte[stringvar++]
        if char == 10 or char == 13
            y += tilesize_y
            x := origin_x          
        elseif char == " "
            x += tilesize_x
        else   
            gfx.Sprite(font_6x8.Addr, x, y, char - " ")
            if x+tilesize_x => origin_x+w      
                y += tilesize_y
                x := origin_x
            else
                x += tilesize_x
        if count > countmax
            return

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