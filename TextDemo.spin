{{
LameGFX Text-Drawing Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               "LameLCD"
        gfx     :               "LameGFX"
        fn      :               "LameFunctions"
        audio   :               "LameAudio"
        
VAR

    word    buffer[1024]
        
PUB TextDemo | x, ran, y

    gfx.Start(@buffer,lcd.Start)    

    audio.Start
    audio.SetWaveform(0, 127)
    audio.SetADSR(120, 80, 40, 110) 

    

    repeat
        LSLogo
        ThisIsATest
    
        RandomEverywhere
        ZoomToCenter
        HouseOfLeaves     

        audio.LoadSong(@iBelieve)
        audio.PlaySong
    
        StarWarsReel(@inaworld,120)
        Lame
        StarWarsReel(@imagine,120)
        StarWarsReel(@takeyour,120)
        StarWarsReel(@somuch,120)
        Image
    
        audio.StopSong
        
PUB LSLogo
    gfx.ClearScreen
    gfx.Sprite(@gfx_ls_seal_0032,48,16,0)
    gfx.DrawScreen
        
    fn.Sleep(200000)
        
PUB ThisIsATest
    gfx.LoadFont(@font_CGA8x8thin, " ", 8, 8)
    gfx.ClearScreen
    gfx.PutString(string("THIS IS A TEST"),4,28)
    gfx.DrawScreen
    fn.Sleep(200000)


    gfx.ClearScreen
    gfx.PutString(string("DO NOT ADJUST"),10,24)
    gfx.PutString(string("YOUR BRAIN"),15,32)
    gfx.DrawScreen
    fn.Sleep(200000)    


PUB Lame
    gfx.LoadFont(@font_CGA8x8thin, " ", 8, 8)
    gfx.ClearScreen
    'gfx.PutString(string("LAME"), 48, 28)
    gfx.Blit(@gfx_lame)
    gfx.DrawScreen
    fn.Sleep(500000)
    gfx.ClearScreen
    gfx.DrawScreen
    fn.Sleep(100000)
    
PUB Image
    gfx.LoadFont(@font_Font6x8, " ", 6, 8)
    gfx.ClearScreen
    gfx.PutString(string("Yes, the LameStation"),3,28)
    gfx.DrawScreen
    fn.Sleep(300000)

    gfx.ClearScreen
    gfx.Sprite(@gfx_ls_front_s, 16,0,0)
    gfx.DrawScreen
    fn.Sleep(1000000)

PUB HouseOfLeaves
        
    gfx.LoadFont(@font_4x4, " ", 4, 4)        
        
    gfx.PutChar("c", 120, 0)
       
    gfx.PutString(string("Super Texty Fun-Time?"), 0, 0)
    gfx.PutString(string("Wow, this isn't legible at all!"), 0, 40)
    gfx.PutString(string("Well, kind of, actually."), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)        
        
    gfx.TextBox(string("Lorem ipsum dolor chicken bacon inspector cats and more"), 52, 32, 5, 32)                 
    gfx.DrawScreen
    fn.Sleep(200000)
    
    gfx.ClearScreen        
    gfx.TextBox(string("I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn't make sense anymore. PutChar and PutString work by simply using the Box command. I'm working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don't waste space."),1,1,120,56)
    gfx.DrawScreen
    fn.Sleep(200000) 
        
    gfx.LoadFont(@font_CGA8x8thin, " ", 8, 8)
    gfx.PutString(string("A LOT OF TEXT"), 6, 32)
    gfx.DrawScreen
    fn.Sleep(200000) 
        
    gfx.ClearScreen
    gfx.DrawScreen
    fn.Sleep(100000) 


PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(@font_CGA8x8thin, " ", 8, 8)
    gfx.ClearScreen
    
    centerx := 64
    centery := 32
    vx := 10
    vy := 0
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        repeat count2 from 1 to 200
            gfx.ClearScreen
            
            ax := (centerx - x)/20
            ay := (centery - y)/20
            
            vx += ax
            vy += ay
            
            x += vx
            y += vy
           
            gfx.PutString(string("BUY ME!!"), x-16, y-4)
            gfx.PutString(string("SUBLIMINAL"), 12, 32)
            gfx.DrawScreen   
    
        
PUB RandomEverywhere | x, y, char, ran, count
    gfx.LoadFont(@font_CGA8x8thin, " ", 8, 8)
    gfx.ClearScreen
    repeat count from 1 to 200
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        char := ran? & %11111
        gfx.PutChar("A" + char, x-8, y-8)
        gfx.DrawScreen

PUB StarWarsReel(text,reeltime) | x
    gfx.LoadFont(@font_Font6x8, " ", 6, 8)
    
    repeat x from 0 to reeltime
        gfx.ClearScreen
        gfx.TextBox(text, 16, 64-x, 96, 64) 
    
        gfx.DrawScreen
        fn.Sleep(10000)


DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0

inaworld    byte    "In a world",10,"of awesome game",10,"consoles...",10,10,10,"One console",10,"dares to be...",0
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


gfx_ls_front_s
word    1536  'frameboost
word    96, 64   'width, height

word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5735, $5555, $55d5, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $ff55, $ffff, $ffff, $57d5, $5555, $5555, $5755, $5555, $5555, $5555, $5555, $5555, $d5fd, $ffff
word    $ffff, $ffff, $ffff, $ffff, $f3ff, $57ff, $5555, $5555, $5555, $d555, $f957, $ffff, $ffff, $ffff, $ffff, $ffff
word    $ffff, $fd5f, $5555, $5555, $5555, $dd55, $ff5f, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $557f, $555f, $5555
word    $5555, $d5d5, $ff7f, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $f5ff, $55fd, $5555, $5555, $d575, $ffff, $ffff
word    $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $7fc3, $5555, $5555, $555d, $fffd, $ffff, $ffff, $ffcf, $ffff, $ffff
word    $ffff, $3fff, $c000, $5555, $5555, $5557, $ffff, $fc3f, $f3bf, $fccf, $ffff, $ffff, $ffff, $03f0, $0000, $5557
word    $d555, $fd55, $ffff, $c00f, $3fff, $0000, $0000, $ffff, $ff0c, $0033, $0000, $555c, $7555, $fff5, $ffff, $c00f
word    $ffff, $0000, $0000, $ffff, $c003, $003f, $0000, $5550, $7555, $ffff, $ffff, $c0f0, $ffff, $cf3f, $c30f, $ffff
word    $c00f, $003f, $0000, $5570, $dd55, $ffff, $fcff, $c0f0, $ffff, $0fc3, $cfcf, $ffff, $0fbf, $000f, $0000, $5570
word    $dd55, $ffff, $ffff, $f0f0, $ffff, $3fcf, $ffc3, $fff3, $0fff, $000c, $0000, $5570, $ff55, $ffe3, $ffff, $ffff
word    $ffff, $3fff, $bfff, $3fc3, $0fff, $000c, $0000, $5540, $ff55, $ffc3, $fc0f, $5557, $5555, $d955, $f77d, $d57d
word    $f5dd, $000f, $0000, $55f0, $ff55, $fff3, $f00f, $5557, $5555, $5555, $5555, $5555, $d555, $000f, $0000, $55f0
word    $ff55, $f0c3, $7003, $5555, $5555, $5555, $5555, $5555, $5555, $000d, $000c, $55f0, $ffd5, $fff0, $7003, $5555
word    $5555, $5555, $5555, $5555, $5555, $000d, $0000, $55f0, $ffd5, $08c0, $7000, $fff5, $ffff, $ffff, $ffff, $ffff
word    $5fff, $003d, $0000, $55f0, $ffd5, $0000, $7000, $fe35, $ffff, $ffff, $ffff, $ffff, $53ff, $00cd, $0000, $57f0
word    $ffd5, $00f0, $7c00, $0035, $0000, $0000, $0000, $0000, $5000, $038d, $c000, $57ff, $8fd5, $3ff0, $7c00, $0035
word    $0000, $0000, $0000, $0000, $5000, $0c0d, $3000, $57c0, $0fd5, $d55e, $7000, $0035, $0000, $0000, $0000, $0000
word    $5000, $f00d, $03ff, $57c0, $0fd5, $ffff, $7003, $0035, $0000, $0000, $0000, $0000, $5000, $000d, $0000, $57c0
word    $3fd5, $0f00, $7000, $0035, $0000, $0000, $0000, $0000, $6000, $000d, $0000, $57c0, $3fd5, $0000, $7c00, $0035
word    $0000, $0000, $0000, $0000, $5000, $000d, $0000, $57c0, $3fd5, $0000, $7c00, $0035, $0000, $0000, $0000, $0000
word    $7000, $ff0d, $0003, $57c0, $3fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000, $7000, $ff0d, $0003, $57c0
word    $3fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000, $7000, $f00d, $0000, $57c0, $3fd5, $0000, $7000, $0035
word    $0000, $0000, $0000, $0000, $7000, $000d, $0000, $57f0, $0fd5, $0000, $7c00, $0035, $0000, $0000, $0000, $0000
word    $5000, $000d, $0000, $57f0, $0fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000, $5000, $000d, $0000, $57fc
word    $3fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000, $5000, $000d, $3c00, $57fc, $3fd5, $0000, $7f00, $0035
word    $0000, $0000, $0000, $0000, $5000, $000d, $0c00, $57fc, $0fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000
word    $7000, $00cd, $0c00, $57fc, $0fd5, $0000, $7000, $0035, $0000, $0000, $0000, $0000, $7000, $00cd, $0000, $57fc
word    $0bd5, $ffc0, $5300, $0035, $0000, $0000, $0000, $0000, $7000, $000d, $0000, $57fe, $03d5, $0000, $5300, $0035
word    $0000, $0000, $0000, $0000, $7000, $000d, $0000, $57ff, $03d5, $0000, $5000, $0035, $0000, $0000, $0000, $0000
word    $7000, $c00d, $0000, $57ff, $01d5, $0000, $5000, $0005, $0000, $0000, $0000, $0000, $7000, $2005, $c000, $55ff
word    $0fd5, $0000, $5300, $0005, $0000, $0000, $0000, $0000, $7000, $0005, $f000, $55ff, $3755, $0000, $5000, $0005
word    $0000, $0000, $0000, $0000, $7000, $0005, $fc00, $55df, $d755, $0000, $5000, $0005, $0000, $0000, $0000, $0000
word    $7000, $0005, $ff00, $55df, $5d55, $000f, $5000, $0005, $0000, $0000, $0000, $0000, $7000, $0005, $ffc0, $5576
word    $5d55, $0bf5, $5000, $0005, $0000, $0000, $0000, $0000, $7000, $0035, $7ff0, $5575, $7555, $3555, $5000, $3f35
word    $fc00, $fc0f, $ffff, $fff0, $70ff, $0005, $57fe, $555d, $f555, $d555, $5000, $7d55, $5555, $f555, $ffff, $ffff
word    $5fff, $0005, $5557, $5557, $d555, $5557, $5003, $5555, $5555, $5555, $5555, $5555, $5555, $e005, $5555, $5557
word    $5555, $f55f, $500f, $5555, $5555, $5555, $5555, $5555, $5555, $7f05, $d555, $5555, $5555, $fd7d, $5c37, $5555
word    $5555, $5555, $5555, $5555, $5555, $5f05, $7555, $5555, $5555, $d5f5, $f0d5, $fd55, $ffff, $ffff, $ffff, $5557
word    $5555, $d7f7, $5f57, $5555, $5555, $5f55, $5f55, $7d55, $f7df, $df5d, $7df7, $5557, $5555, $55f7, $57d5, $5555
word    $5555, $f955, $7d56, $fffd, $ffff, $ffff, $59e5, $ffff, $5fff, $557d, $557d, $5555, $5555, $5555, $ffff, $ffff
word    $ffff, $ffff, $ffff, $ffff, $7fff, $f55f, $5557, $5555, $5555, $5555, $d555, $ffff, $ffff, $ffff, $ffff, $ffff
word    $ffff, $5fff, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555




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





CON

    'SONG PLAYER
    ENDOFSONG = 0
    TIMEWAIT = 1
    NOTEON = 2
    NOTEOFF = 3
    
    SONGS = 2
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
DAT

iBelieve
byte    12     'number of bars
byte    55    'tempo
byte    16    'bar resolution

'main
byte    0,  50, 46, 53, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    0,  55, 51, 46, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    0,  58, SNOP, SNOP, SNOP, 57, SNOP, SNOP, SNOP, 55, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP
byte    0,  50, 46, 41, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

'low harmony
byte    1,  46, 41, 50, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    1,  51, 46, 39, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    1,  55, SNOP, SNOP, SNOP, 53, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP, 48, SNOP, SNOP, SNOP
byte    1,  46, 41, 38, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

'low part
byte    2,  22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    2,  27, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    2,  31, SNOP, SNOP, SNOP, 29, SNOP, SNOP, SNOP, 27, SNOP, SNOP, SNOP, 24, SNOP, SNOP, SNOP
byte    2,  22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF

byte    0,4,BAROFF
byte    1,5,BAROFF
byte    2,6,BAROFF
byte    3,7,BAROFF

byte    0,4,8,BAROFF
byte    1,5,9,BAROFF
byte    2,6,10,BAROFF
byte    3,7,11,BAROFF

byte    SONGOFF



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
