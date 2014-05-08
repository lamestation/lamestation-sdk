{{
KS0108 Text-Drawing Library Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2011 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}



CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
        lcd     :               "LameLCD"
        gfx     :               "LameGFX" 
        
PUB TextDemo | x, ran

    gfx.Start(lcd.Start)

    '' The LCD and graphics libraries enforce flipping between
    '' two pages in memory to prevent screen flicker, but this
    '' functionality is hidden from the user.
    '' 
    '' To update the screen, you simply call switchFrame.
    repeat
        lcd.SwitchFrame

        '' Clears the screen to black.
        '' Nuffin' special.

        gfx.ClearScreen
        
        '' First argument is the string.
        '' string() for sending text on the fly.
        '' Or pass the address of a null-terminated string in a DAT block.
        '' 
        '' The next two arguments are the x and y position of the cursor,
        '' which both have a resolution of 8 pixels.  Be careful not to
        '' allow the cursor to overflow off the screen (bottom-right of
        '' screen), as there is no protection in place yet and you will
        '' probably overwrite something you like.
        '' 
        '' x position is a feature I just added today, so when the cursor
        '' reaches the right side of the screen, it isn't behaving like I
        '' want it to yet, when x is nonzero.  Buyer beware.
        
        repeat x from 1 to 26
            ran
            
        
        gfx.PutString(string("Super Texty Fun-Time?"), 0, 1)
        gfx.PutString(@allcharacters, 0, 3) 

DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0
  

{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
