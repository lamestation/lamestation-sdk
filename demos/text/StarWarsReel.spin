{{
Star Wars Reel
-------------------------------------------------
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}

CON

    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ

    lcd      : "LameLCD"
    gfx      : "LameGFX"
    audio    : "LameAudio"
    music    : "LameMusic"
    
    font_6x8 : "gfx_font6x8_normal_w"
    song     : "sng_ibelieve"

        
PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)

    gfx.LoadFont(font_6x8.Addr, " ", 0, 0)

    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop

    repeat
        StarWarsReel(@inaworld,120)
        StarWarsReel(@imagine,120)
        StarWarsReel(@takeyour,120)
        StarWarsReel(@somuch,120)

PUB StarWarsReel(text,reeltime) | x
    
    repeat x from 0 to reeltime
        gfx.ClearScreen(0)
        gfx.TextBox(text, 16, 64-x, 96, 64) 
        lcd.DrawScreen

DAT

inaworld    byte    "In a world",10,"of awesome game",10,"consoles...",10,10,10,"One console",10,"dares to be...",0
imagine     byte    "Imagine...",10,10,"A game console",10,"where the rules",10,"of business do",10,"not apply.",0
takeyour    byte    "Take your memory",10,10,"Take your specs!",10,10,"Don't need 'em!",0
somuch      byte    "The most action-packed 32 kilo-",10,"bytes you'll",10,"ever have!",0


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
