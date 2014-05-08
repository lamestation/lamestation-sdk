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
        fn      :               "LameFunctions"
        
VAR

    word    buffer[1024]
        
PUB TextDemo | x, ran, y

    gfx.Start(@buffer,lcd.Start)
   

    '' The LCD and graphics libraries enforce flipping between
    '' two pages in memory to prevent screen flicker, but this
    '' functionality is hidden from the user.
    '' 
    '' To update the screen, you simply call switchFrame.
    'repeat
        gfx.DrawScreen

        '' Clears the screen to black.
        '' Nuffin' special.

        gfx.ClearScreen
        gfx.Sprite(@gfx_ls_seal_0032,48,16,0)
        gfx.DrawScreen
        
        fn.Sleep(100000)
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
        
        'repeat x from 1 to 26
         '   ran
        

        gfx.LoadFont(@font_4x4, " ", 4, 4)        
        
        gfx.PutChar("c", 120, 0)
        
        gfx.PutString(string("Super Texty Fun-Time?"), 0, 0)
        gfx.PutString(string("Wow, this isn't legible at all!"), 0, 40)
        gfx.PutString(string("Well, kind of, actually."), 0, 44)
        gfx.PutString(@allcharacters, 0, 5)        
        
        gfx.TextBox(string("Lorem ipsum dolor chicken bacon inspector cats and more"), 52, 32, 5, 32) 
        
        
        
        gfx.DrawScreen
        fn.Sleep(600000)
        gfx.ClearScreen
        fn.Sleep(100000) 
        
        gfx.LoadFont(@font_Font6x8, " ", 6, 8)
        
        StarWarsReel(@inaworld,150)
        StarWarsReel(@imagine,120)
        StarWarsReel(@takeyour,120)
        StarWarsReel(@somuch,120)

PUB StarWarsReel(text,reeltime) | x
    repeat x from 0 to reeltime
        gfx.ClearScreen
        gfx.TextBox(text, 16, 64-x, 96, 64) 
    
        gfx.DrawScreen
        fn.Sleep(10000)


DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0

inaworld    byte    "In a world",10,"of awesome game",10,"consoles...",10,10,10,"One console",10,"dares to be...",10,10,10,10,"LAME!",0
imagine     byte    "Imagine...",10,10,"A game console",10,"where the rules",10,"of business do",10,"not apply.",0
takeyour    byte    "Take your memory",10,10,"Take your specs!",10,10,"Don't need 'em!",0
somuch      byte    "The most action-packed 32 kilo-",10,"bytes you'll",10,"ever have!",0

font_4x4

word    $aa00, $aa00, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa04, $aa00, $aa04, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa11, $aa00, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa05, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa11, $aa04, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa14, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa04, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa10, $aa04, $aa10, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa10, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa15, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa15, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa00, $aa04, $aa04, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa15, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa00, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa10, $aa04, $aa01, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa11, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa05, $aa04, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa04, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa14, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa14, $aa15, $aa10, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa14, $aa04, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa01, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa10, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa15, $aa10, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa04, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa00, $aa04, $aa01, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa10, $aa04, $aa10, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa00, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa10, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa14, $aa00, $aa04, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa15, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa15, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa01, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa11, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa05, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa05, $aa01, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa05, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa11, $aa15, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa04, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa10, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa11, $aa05, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa01, $aa01, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa15, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa11, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa15, $aa01, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa15, $aa11, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa05, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa14, $aa04, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa15, $aa04, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa11, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa11, $aa11, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa11, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa11, $aa04, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa11, $aa15, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa04, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa14, $aa04, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa01, $aa04, $aa10, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa05, $aa04, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa11, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa00, $aa00, $aa55, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa14, $aa05, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa14, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa01, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa01, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa10, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa15, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa14, $aa14, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa15, $aa14, $aa05, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa01, $aa05, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa04, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa10, $aa11, $aa04, $aaaa, $aaaa, $aaaa, $aaaa, $aa01, $aa15, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa04, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa15, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa05, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa11, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa05, $aa11, $aa05, $aa01, $aaaa, $aaaa, $aaaa, $aaaa, $aa04, $aa11, $aa14, $aa10, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa01, $aa01, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa14, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa15, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa11, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa11, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa11, $aa15, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa15, $aa11, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa11, $aa14, $aa05, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa00, $aa05, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa14, $aa05, $aa14, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa04, $aa04, $aa04, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa05, $aa14, $aa05, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa14, $aa05, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa, $aa00, $aa00, $aa00, $aa00, $aaaa, $aaaa, $aaaa, $aaaa
  



font_CGA8x8thin

word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aa6a, $a95a, $a95a, $aa6a, $aa6a, $aaaa, $aa6a, $aaaa
word    $a69a, $a69a, $a69a, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $a69a, $a69a, $9556, $a69a, $9556, $a69a, $a69a, $aaaa
word    $a96a, $955a, $aaa6, $a55a, $9aaa, $a556, $a96a, $aaaa, $aaaa, $9a96, $a696, $a9aa, $aa6a, $969a, $96a6, $aaaa
word    $aa5a, $a9a6, $aa5a, $9666, $a9a9, $a9a9, $9656, $aaaa, $aa6a, $aa6a, $aa9a, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aa6a, $aa9a, $aaa6, $aaa6, $aaa6, $aa9a, $aa6a, $aaaa, $aa9a, $aa6a, $a9aa, $a9aa, $a9aa, $aa6a, $aa9a, $aaaa
word    $aaaa, $a6a6, $a95a, $9555, $a95a, $a6a6, $aaaa, $aaaa, $aaaa, $aa6a, $aa6a, $a556, $aa6a, $aa6a, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aa6a, $aa6a, $aa9a, $aaaa, $aaaa, $aaaa, $9556, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aa6a, $aa6a, $aaaa, $aaaa, $9aaa, $a6aa, $a9aa, $aa6a, $aa9a, $aaa6, $aaaa
word    $a55a, $9aa6, $96a6, $99a6, $9a66, $9a96, $a55a, $aaaa, $aa6a, $aa5a, $aa66, $aa6a, $aa6a, $aa6a, $a556, $aaaa
word    $a55a, $9aa6, $9aaa, $a5aa, $aa5a, $9aa6, $9556, $aaaa, $a55a, $9aa6, $9aaa, $a56a, $9aaa, $9aa6, $a55a, $aaaa
word    $a9aa, $a96a, $a99a, $a9a6, $9555, $a9aa, $a56a, $aaaa, $9556, $aaa6, $a556, $9aaa, $9aaa, $9aa6, $a55a, $aaaa
word    $a56a, $aa9a, $aaa6, $a556, $9aa6, $9aa6, $a55a, $aaaa, $9556, $9aa6, $a6aa, $a9aa, $aa6a, $aa6a, $aa6a, $aaaa
word    $a55a, $9aa6, $9aa6, $a55a, $9aa6, $9aa6, $a55a, $aaaa, $a55a, $9aa6, $9aa6, $955a, $9aaa, $a6aa, $a95a, $aaaa
word    $aaaa, $aa6a, $aa6a, $aaaa, $aaaa, $aa6a, $aa6a, $aaaa, $aaaa, $aa6a, $aa6a, $aaaa, $aaaa, $aa6a, $aa6a, $aa9a
word    $a9aa, $aa6a, $aa9a, $aaa6, $aa9a, $aa6a, $a9aa, $aaaa, $aaaa, $aaaa, $9556, $aaaa, $aaaa, $9556, $aaaa, $aaaa
word    $aa6a, $a9aa, $a6aa, $9aaa, $a6aa, $a9aa, $aa6a, $aaaa, $a55a, $9aa6, $9aaa, $a6aa, $a9aa, $aaaa, $a9aa, $aaaa
word    $a55a, $9aa6, $9566, $9a66, $9566, $aaa6, $a55a, $aaaa, $a96a, $a69a, $9aa6, $9aa6, $9556, $9aa6, $9aa6, $aaaa
word    $a556, $9a9a, $9a9a, $a55a, $9a9a, $9a9a, $a556, $aaaa, $a56a, $9a9a, $aaa6, $aaa6, $aaa6, $9a9a, $a56a, $aaaa
word    $a956, $a69a, $9a9a, $9a9a, $9a9a, $a69a, $a956, $aaaa, $9556, $9a9a, $a99a, $a95a, $a99a, $9a9a, $9556, $aaaa
word    $9556, $9a9a, $a99a, $a95a, $a99a, $aa9a, $aa56, $aaaa, $a56a, $9a9a, $aaa6, $aaa6, $95a6, $9a9a, $956a, $aaaa
word    $9aa6, $9aa6, $9aa6, $9556, $9aa6, $9aa6, $9aa6, $aaaa, $a95a, $aa6a, $aa6a, $aa6a, $aa6a, $aa6a, $a95a, $aaaa
word    $95aa, $a6aa, $a6aa, $a6aa, $a6a6, $a6a6, $a95a, $aaaa, $9a96, $a69a, $a99a, $aa5a, $a99a, $a69a, $5a96, $aaaa
word    $aa56, $aa9a, $aa9a, $aa9a, $aa9a, $9a9a, $9556, $aaaa, $5a96, $6666, $69a6, $6aa6, $6aa6, $6aa6, $6aa6, $aaaa
word    $9a96, $9a66, $99a6, $96a6, $9aa6, $9aa6, $9aa6, $aaaa, $a96a, $a69a, $9aa6, $9aa6, $9aa6, $a69a, $a96a, $aaaa
word    $a556, $9a9a, $9a9a, $a55a, $aa9a, $aa9a, $aa56, $aaaa, $a55a, $9aa6, $9aa6, $9aa6, $99a6, $a55a, $5aaa, $aaaa
word    $a556, $9a9a, $9a9a, $a55a, $a99a, $a69a, $9a56, $aaaa, $a55a, $9aa6, $aaa6, $a55a, $9aaa, $9aa6, $a55a, $aaaa
word    $5556, $69a6, $a9aa, $a9aa, $a9aa, $a9aa, $a56a, $aaaa, $9aa6, $9aa6, $9aa6, $9aa6, $9aa6, $9aa6, $a55a, $aaaa
word    $6aa6, $6aa6, $6aa6, $6aa6, $9a9a, $a66a, $a9aa, $aaaa, $6aa6, $6aa6, $6aa6, $69a6, $69a6, $69a6, $965a, $aaaa
word    $6aa6, $9a9a, $a66a, $a9aa, $a66a, $9a9a, $6aa6, $aaaa, $6aa6, $9a9a, $a66a, $a9aa, $a9aa, $a9aa, $a56a, $aaaa
word    $5556, $9aa6, $a6aa, $a9aa, $aa6a, $6a9a, $5556, $aaaa, $a956, $aaa6, $aaa6, $aaa6, $aaa6, $aaa6, $a956, $aaaa
word    $aaa9, $aaa6, $aa9a, $aa6a, $a9aa, $a6aa, $9aaa, $aaaa, $a956, $a9aa, $a9aa, $a9aa, $a9aa, $a9aa, $a956, $aaaa
word    $aa6a, $a99a, $a6a6, $9aa9, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $5555
word    $aa6a, $aa6a, $a9aa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $a55a, $9aaa, $955a, $9aa6, $555a, $aaaa
word    $aa96, $aa9a, $aa9a, $959a, $6a5a, $6a5a, $959a, $aaaa, $aaaa, $aaaa, $a55a, $9aa6, $aaa6, $9aa6, $a55a, $aaaa
word    $96aa, $9aaa, $9aaa, $995a, $96a6, $96a6, $595a, $aaaa, $aaaa, $aaaa, $a55a, $9aa6, $9556, $aaa6, $a55a, $aaaa
word    $a5aa, $9a6a, $aa6a, $a95a, $aa6a, $aa6a, $a95a, $aaaa, $aaaa, $aaaa, $655a, $9aa6, $9aa6, $955a, $9aaa, $a556
word    $aa96, $aa9a, $a59a, $9a5a, $9a9a, $9a9a, $9a96, $aaaa, $aa6a, $aaaa, $aa5a, $aa6a, $aa6a, $aa6a, $a95a, $aaaa
word    $9aaa, $aaaa, $96aa, $9aaa, $9aaa, $9aa6, $9aa6, $a55a, $aa96, $aa9a, $a69a, $a99a, $aa5a, $a99a, $969a, $aaaa
word    $aa5a, $aa6a, $aa6a, $aa6a, $aa6a, $aa6a, $a95a, $aaaa, $aaaa, $aaaa, $9656, $69a6, $69a6, $69a6, $69a6, $aaaa
word    $aaaa, $aaaa, $a566, $9a96, $9aa6, $9aa6, $9aa6, $aaaa, $aaaa, $aaaa, $a55a, $9aa6, $9aa6, $9aa6, $a55a, $aaaa
word    $aaaa, $aaaa, $a596, $9a5a, $9a5a, $a59a, $aa9a, $aa56, $aaaa, $aaaa, $965a, $a5a6, $a5a6, $a65a, $a6aa, $95aa
word    $aaaa, $aaaa, $a596, $9a5a, $9a9a, $aa9a, $aa56, $aaaa, $aaaa, $aaaa, $955a, $aaa6, $a55a, $9aaa, $a556, $aaaa
word    $aa6a, $aa6a, $a556, $aa6a, $aa6a, $9a6a, $a5aa, $aaaa, $aaaa, $aaaa, $9aa6, $9aa6, $9aa6, $96a6, $995a, $aaaa
word    $aaaa, $aaaa, $6aa6, $6aa6, $9a9a, $a66a, $a9aa, $aaaa, $aaaa, $aaaa, $6aa6, $69a6, $69a6, $69a6, $965a, $aaaa
word    $aaaa, $aaaa, $a6a6, $a99a, $aa6a, $a99a, $a6a6, $aaaa, $aaaa, $aaaa, $9aa6, $9aa6, $9aa6, $955a, $9aaa, $a556
word    $aaaa, $aaaa, $a556, $a9aa, $aa6a, $aa9a, $a556, $aaaa, $a5aa, $aa6a, $aa6a, $aa96, $aa6a, $aa6a, $a5aa, $aaaa
word    $aa6a, $aa6a, $aa6a, $aaaa, $aa6a, $aa6a, $aa6a, $aaaa, $aa5a, $a9aa, $a9aa, $96aa, $a9aa, $a9aa, $aa5a, $aaaa
word    $9a5a, $a5a6, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $a9aa, $a66a, $9a9a, $6aa6, $6aa6, $5556, $aaaa


font_Font6x8

word    $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a040, $a150, $a150, $a040, $a040, $a000, $a040, $a000
word    $a514, $a514, $a104, $a000, $a000, $a000, $a000, $a000, $a000, $a110, $a554, $a110, $a110, $a554, $a110, $a000
word    $a010, $a150, $a004, $a050, $a100, $a054, $a040, $a000, $a414, $a414, $a100, $a040, $a010, $a504, $a504, $a000
word    $a010, $a044, $a044, $a010, $a444, $a104, $a450, $a000, $a050, $a050, $a010, $a000, $a000, $a000, $a000, $a000
word    $a040, $a010, $a010, $a010, $a010, $a010, $a040, $a000, $a010, $a040, $a040, $a040, $a040, $a040, $a010, $a000
word    $a000, $a110, $a150, $a554, $a150, $a110, $a000, $a000, $a000, $a040, $a040, $a554, $a040, $a040, $a000, $a000
word    $a000, $a000, $a000, $a000, $a000, $a050, $a050, $a010, $a000, $a000, $a000, $a554, $a000, $a000, $a000, $a000
word    $a000, $a000, $a000, $a000, $a000, $a050, $a050, $a000, $a000, $a400, $a100, $a040, $a010, $a004, $a000, $a000
word    $a150, $a404, $a504, $a444, $a414, $a404, $a150, $a000, $a040, $a050, $a040, $a040, $a040, $a040, $a150, $a000
word    $a150, $a404, $a400, $a140, $a010, $a004, $a554, $a000, $a150, $a404, $a400, $a150, $a400, $a404, $a150, $a000
word    $a100, $a140, $a110, $a104, $a554, $a100, $a100, $a000, $a554, $a004, $a004, $a154, $a400, $a404, $a150, $a000
word    $a140, $a010, $a004, $a154, $a404, $a404, $a150, $a000, $a554, $a400, $a100, $a040, $a010, $a010, $a010, $a000
word    $a150, $a404, $a404, $a150, $a404, $a404, $a150, $a000, $a150, $a404, $a404, $a550, $a400, $a100, $a050, $a000
word    $a000, $a000, $a050, $a050, $a000, $a050, $a050, $a000, $a000, $a000, $a050, $a050, $a000, $a050, $a050, $a010
word    $a100, $a040, $a010, $a004, $a010, $a040, $a100, $a000, $a000, $a000, $a554, $a000, $a000, $a554, $a000, $a000
word    $a010, $a040, $a100, $a400, $a100, $a040, $a010, $a000, $a150, $a404, $a400, $a140, $a040, $a000, $a040, $a000
word    $a150, $a404, $a544, $a444, $a544, $a004, $a150, $a000, $a150, $a404, $a404, $a404, $a554, $a404, $a404, $a000
word    $a154, $a404, $a404, $a154, $a404, $a404, $a154, $a000, $a150, $a404, $a004, $a004, $a004, $a404, $a150, $a000
word    $a154, $a404, $a404, $a404, $a404, $a404, $a154, $a000, $a554, $a004, $a004, $a154, $a004, $a004, $a554, $a000
word    $a554, $a004, $a004, $a154, $a004, $a004, $a004, $a000, $a150, $a404, $a004, $a544, $a404, $a404, $a550, $a000
word    $a404, $a404, $a404, $a554, $a404, $a404, $a404, $a000, $a150, $a040, $a040, $a040, $a040, $a040, $a150, $a000
word    $a400, $a400, $a400, $a400, $a404, $a404, $a150, $a000, $a404, $a104, $a044, $a014, $a044, $a104, $a404, $a000
word    $a004, $a004, $a004, $a004, $a004, $a004, $a554, $a000, $a404, $a514, $a444, $a404, $a404, $a404, $a404, $a000
word    $a404, $a414, $a444, $a504, $a404, $a404, $a404, $a000, $a150, $a404, $a404, $a404, $a404, $a404, $a150, $a000
word    $a154, $a404, $a404, $a154, $a004, $a004, $a004, $a000, $a150, $a404, $a404, $a404, $a444, $a104, $a450, $a000
word    $a154, $a404, $a404, $a154, $a104, $a404, $a404, $a000, $a150, $a404, $a004, $a150, $a400, $a404, $a150, $a000
word    $a554, $a040, $a040, $a040, $a040, $a040, $a040, $a000, $a404, $a404, $a404, $a404, $a404, $a404, $a150, $a000
word    $a404, $a404, $a404, $a404, $a404, $a110, $a040, $a000, $a404, $a404, $a444, $a444, $a444, $a444, $a110, $a000
word    $a404, $a404, $a110, $a040, $a110, $a404, $a404, $a000, $a404, $a404, $a404, $a110, $a040, $a040, $a040, $a000
word    $a154, $a100, $a040, $a010, $a004, $a004, $a154, $a000, $a150, $a010, $a010, $a010, $a010, $a010, $a150, $a000
word    $a000, $a004, $a010, $a040, $a100, $a400, $a000, $a000, $a150, $a100, $a100, $a100, $a100, $a100, $a150, $a000
word    $a040, $a110, $a404, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a555
word    $a050, $a050, $a040, $a000, $a000, $a000, $a000, $a000, $a000, $a000, $a150, $a400, $a550, $a404, $a550, $a000
word    $a004, $a004, $a154, $a404, $a404, $a404, $a154, $a000, $a000, $a000, $a150, $a404, $a004, $a404, $a150, $a000
word    $a400, $a400, $a550, $a404, $a404, $a404, $a550, $a000, $a000, $a000, $a150, $a404, $a154, $a004, $a150, $a000
word    $a140, $a010, $a010, $a154, $a010, $a010, $a010, $a000, $a000, $a000, $a550, $a404, $a404, $a550, $a400, $a150
word    $a004, $a004, $a054, $a104, $a104, $a104, $a104, $a000, $a040, $a000, $a040, $a040, $a040, $a040, $a140, $a000
word    $a100, $a000, $a140, $a100, $a100, $a100, $a104, $a050, $a004, $a004, $a104, $a044, $a014, $a044, $a104, $a000
word    $a040, $a040, $a040, $a040, $a040, $a040, $a140, $a000, $a000, $a000, $a114, $a444, $a444, $a404, $a404, $a000
word    $a000, $a000, $a054, $a104, $a104, $a104, $a104, $a000, $a000, $a000, $a150, $a404, $a404, $a404, $a150, $a000
word    $a000, $a000, $a154, $a404, $a404, $a404, $a154, $a004, $a000, $a000, $a550, $a404, $a404, $a404, $a550, $a400
word    $a000, $a000, $a144, $a410, $a010, $a010, $a054, $a000, $a000, $a000, $a150, $a004, $a150, $a400, $a150, $a000
word    $a000, $a010, $a154, $a010, $a010, $a110, $a040, $a000, $a000, $a000, $a104, $a104, $a104, $a144, $a110, $a000
word    $a000, $a000, $a404, $a404, $a404, $a110, $a040, $a000, $a000, $a000, $a404, $a404, $a444, $a554, $a110, $a000
word    $a000, $a000, $a104, $a104, $a050, $a104, $a104, $a000, $a000, $a000, $a104, $a104, $a104, $a150, $a040, $a014
word    $a000, $a000, $a154, $a100, $a050, $a004, $a154, $a000, $a140, $a010, $a010, $a014, $a010, $a010, $a140, $a000
word    $a040, $a040, $a040, $a000, $a040, $a040, $a040, $a000, $a050, $a100, $a100, $a500, $a100, $a100, $a050, $a000
word    $a110, $a044, $a000, $a000, $a000, $a000, $a000, $a000, $a040, $a150, $a514, $a404, $a404, $a554, $a000, $a000


gfx_ls_seal_0032
word    256  'frameboost
word    32, 32   'width, height

word    $aaaa, $0ffa, $aff0, $aaaa, $aaaa, $000f, $f000, $aaaa, $faaa, $0000, $0000, $aaaf, $3eaa, $0000, $0000, $aabc
word    $03aa, $55c0, $0005, $aac0, $00ea, $55c0, $0005, $ab00, $00fa, $55c0, $0005, $af00, $003a, $55c0, $0005, $ac00
word    $000e, $55c0, $0005, $b000, $000e, $55c0, $0005, $b000, $0003, $55c0, $0005, $c000, $0003, $55c0, $0005, $c000
word    $0003, $55c0, $0005, $c000, $0003, $55c0, $0005, $c000, $0000, $55c0, $0005, $0000, $0000, $55c0, $0005, $0000
word    $ffff, $55ff, $fff5, $ffff, $ffff, $55ff, $fff5, $ffff, $ffff, $55ff, $fff5, $ffff, $ffff, $55ff, $fff5, $ffff
word    $ffff, $55ff, $fff5, $ffff, $ffff, $55ff, $fff5, $ffff, $fffe, $55ff, $fff5, $bfff, $fffe, $55ff, $fff5, $bfff
word    $fffa, $55ff, $5555, $a555, $fffa, $55ff, $5555, $ad55, $ffea, $55ff, $5555, $ab55, $ffaa, $ffff, $ffff, $aaff
word    $feaa, $ffff, $ffff, $aabf, $faaa, $ffff, $ffff, $aaaf, $aaaa, $ffff, $ffff, $aaaa, $aaaa, $fffa, $afff, $aaaa


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
