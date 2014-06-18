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
        
        font_8x8    :           "Font8x8"
        font_6x8    :           "Font6x8"
        font_4x4    :           "Font4x4"

        famus   :               "spacegirl"
        
VAR

    word    buffer[1024]
        
PUB TextDemo | x, ran, y

    gfx.Start(@buffer,lcd.Start)    

    audio.Start


    

    repeat
        LSLogo
        gfx.ClearScreen


        ThisIsATest

        Derrtroid
    
        RandomEverywhere
        ZoomToCenter
        HouseOfLeaves     

        audio.SetWaveform(0)
        audio.SetADSR(120, 80, 40, 110) 
        audio.LoadSong(@iBelieve)
        audio.LoopSong
    
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
        
    fn.Sleep(1000)


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

PUB Derrtroid | count

    audio.SetWaveform(1)
    audio.SetADSR(110, 90, 30, 100) 
    audio.LoadSong(@blehTroid)
    audio.LoopSong

    gfx.ClearScreen

    count := 0
    repeat
        gfx.Sprite(famus.Addr,38,0,0)
        Typewriter(string("I FIRST BATTLED THE",10,"DURPEES ON THE PLANET",10,"PHEEBES. IT WAS THERE",10,"THAT I FOILED MY",10,"DINNER AND HAD TO",10,"ASK FOR THE CHECK..."),0,0,128,64, 6, 9, count)
        count++
        fn.Sleep(80)

        gfx.DrawScreen
    while count < 160
    

    audio.StopSong


PUB ThisIsATest
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen
    gfx.PutString(string("THIS IS A TEST"),4,28)
    gfx.DrawScreen
    fn.Sleep(1000)


    gfx.ClearScreen
    gfx.PutString(string("DO NOT ADJUST"),10,24)
    gfx.PutString(string("YOUR BRAIN"),15,32)
    gfx.DrawScreen
    fn.Sleep(1000)    


PUB Lame
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen
    'gfx.PutString(string("LAME"), 48, 28)
    gfx.Blit(@gfx_lame)
    gfx.DrawScreen
    fn.Sleep(1000)
    gfx.ClearScreen
    gfx.DrawScreen
    fn.Sleep(1000)
    
PUB Image
    gfx.LoadFont(font_6x8.Addr, " ", 6, 8)
    gfx.ClearScreen
    gfx.PutString(string("Yes, the LameStation"),3,28)
    gfx.DrawScreen
    fn.Sleep(3000)

    gfx.ClearScreen
    gfx.Sprite(@gfx_ls_front_s, 16,0,0)
    gfx.DrawScreen
    fn.Sleep(10000)

PUB HouseOfLeaves
        
    gfx.LoadFont(font_4x4.Addr, " ", 4, 4)        
        
    gfx.PutChar("c", 120, 0)
       
    gfx.PutString(string("Super Texty Fun-Time?"), 0, 0)
    gfx.PutString(string("Wow, this isn't legible at all!"), 0, 40)
    gfx.PutString(string("Well, kind of, actually."), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)        
        
    gfx.TextBox(string("Lorem ipsum dolor chicken bacon inspector cats and more"), 52, 32, 5, 32)                 
    gfx.DrawScreen
    fn.Sleep(2000)
    
    gfx.ClearScreen        
    gfx.TextBox(string("I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn't make sense anymore. PutChar and PutString work by simply using the Box command. I'm working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don't waste space."),1,1,120,56)
    gfx.DrawScreen
    fn.Sleep(2000) 
        
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.PutString(string("A LOT OF TEXT"), 6, 32)
    gfx.DrawScreen
    fn.Sleep(2000) 
        
    gfx.ClearScreen
    gfx.DrawScreen
    fn.Sleep(1000) 


PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
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
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen
    repeat count from 1 to 1000
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        char := ran? & %11111
        gfx.PutChar("A" + char, x-8, y-8)
        gfx.DrawScreen
        fn.Sleep(2)

PUB StarWarsReel(text,reeltime) | x
    gfx.LoadFont(font_6x8.Addr, " ", 6, 8)
    
    repeat x from 0 to reeltime
        gfx.ClearScreen
        gfx.TextBox(text, 16, 64-x, 96, 64) 
    
        gfx.DrawScreen
        fn.Sleep(20)


DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0

inaworld    byte    "In a world",10,"of awesome game",10,"consoles...",10,10,10,"One console",10,"dares to be...",0
imagine     byte    "Imagine...",10,10,"A game console",10,"where the rules",10,"of business do",10,"not apply.",0
takeyour    byte    "Take your memory",10,10,"Take your specs!",10,10,"Don't need 'em!",0
somuch      byte    "The most action-packed 32 kilo-",10,"bytes you'll",10,"ever have!",0






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
byte    80    'tempo
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


blehTroid
byte    2     'number of bars
byte    110    'tempo
byte    16    'bar resolution

'main
'byte    0,  53, 53, 55, 55, 58, 58, 57, 57, 60, 60, 58, 58, 63, 63, 62, 62
byte    0,  33, 33, 35, 35, 38, 38, 37, 37, 40, 40, 38, 38, 43, 43, 42, 42
byte    1,  SNOP, SNOP, 23, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF

'SONG ------

byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF

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
