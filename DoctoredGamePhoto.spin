{{
KS0108 Sprite And Tile Graphics Library Demo
-------------------------------------------------
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}



CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX" 
        ctrl    :               "LameControl"


VAR
    word    screen

    byte    slide
    byte    clicked
    long    positionx


PUB GraphicsDemo | x

    gfx.Start(lcd.Start)
    gfx.LoadMap(@gfx_tiles_2b_tuxor,@map_gradient)

    slide := 0
   
    repeat
        'The LCD and graphics libraries enforce flipping between
        'two pages in memory to prevent screen flicker, but this
        'functionality is hidden from the user.
        gfx.DrawScreen
        
        ctrl.Update
        gfx.ClearScreen
        
'        case slide
 '           0: gfx.ClearScreen
  '          1: gfx.Sprite(@gfx_krakken,0,0,0)
   '         2: gfx.Blit(@gfx_test_checker)
    '        3: gfx.DrawMap(0,0,1,1,14,6)
        gfx.DrawMap(positionx,0)

        if ctrl.A or ctrl.B
          if not clicked
            clicked := 1
            slide++
            if slide > 3
              slide := 0
        else
          clicked := 0
          
        if ctrl.Right
            positionx += 8
            
        if ctrl.Left
            positionx -= 8
            
        gfx.Blit(@gfx_doctoredgamephoto)
            
'        positionx &= $7F
            
          
 '       repeat x from 0 to 5000

DAT


gfx_krakken
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $af5f, $aaaa, $aaaa, $4114, $aaab, $57aa, $5104, $aab0, $757a, $d7f5, $aa14, $c0de, $7555, $af0d, $c006
word    $5555, $c575, $4047, $555d, $d1d7, $500d, $57d5, $1755, $557d, $dd75, $4545, $5d55, $555f, $5545, $d57f, $1554
word    $0dcd, $ff02, $1554, $0305, $3556, $1554, $a80c, $000a, $555d, $aa8c, $2aaa, $75dd, $aaa8, $aaaa, $01d0, $aaaa

          
gfx_doctoredgamephoto
word    2048  'frameboost
word    128, 64   'width, height

word    $0000, $cd73, $f55f, $05ff, $030f, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $c003, $557f, $c3ff, $000f, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $300c, $557c, $fcfd, $0030, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $cc33, $fff0, $3fff, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $c043, $fc30, $f0ff, $0000, $0000, $0003, $0000, $0000, $0000, $0000, $00c0, $0000, $0000, $0000, $0000
word    $0000, $c103, $0f00, $0c0c, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $00c0, $cc33, $0000, $3003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $300c, $0000, $0000, $0000, $0000, $0000, $0000, $000c, $0000, $0000, $0000, $0000, $0000, $5f00, $003d
word    $0000, $cd73, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5054, $4015, $0355
word    $0000, $c003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $7154, $4415, $0d54
word    $0000, $300c, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $f5f0, $0000, $0000, $0300, $c3fc, $4415, $3d43
word    $0000, $cc33, $0000, $0000, $0000, $0000, $3000, $0000, $0000, $555c, $0003, $0000, $0000, $0000, $4447, $350d
word    $0000, $c043, $0030, $0000, $0000, $0000, $0000, $0000, $0000, $f5f0, $0000, $0000, $c000, $0fff, $444f, $343d
word    $0000, $c103, $0000, $0000, $0000, $0fdc, $0000, $0000, $0000, $0000, $0000, $fff0, $5557, $3555, $4440, $f4fd
word    $0000, $cc33, $0000, $0000, $0000, $013c, $0000, $0000, $0000, $0000, $0000, $555c, $5555, $d555, $410f, $d0f5
word    $0000, $300c, $0000, $0000, $0000, $013c, $0000, $0000, $0000, $0000, $0000, $5557, $57f5, $57d5, $503d, $d435
word    $0000, $cd73, $0000, $0000, $0000, $0ff0, $0000, $0000, $0000, $0000, $4000, $5555, $5555, $5555, $50ff, $d501
word    $0000, $c003, $0000, $0000, $0c00, $0001, $0000, $0000, $0000, $0000, $7000, $5fd5, $5555, $d555, $54ff, $5553
word    $0000, $300c, $0000, $0000, $c400, $03c7, $0000, $7c00, $003d, $0000, $f000, $5555, $d400, $f557, $543f, $555c
word    $0000, $cc33, $0000, $0000, $0400, $0dc0, $0000, $5700, $00d5, $0000, $0000, $d55f, $5054, $fd55, $d50f, $f554
word    $0000, $c043, $0000, $0000, $cc00, $000d, $0000, $7c00, $003d, $0000, $0000, $d5f0, $5154, $ffd5, $0d43, $3f55
word    $0000, $c103, $0000, $0000, $cc00, $55f1, $000d, $0000, $0000, $0000, $0000, $5700, $5153, $fff5, $7010, $03f5
word    $0000, $cc33, $0000, $000c, $cc00, $5d51, $0007, $0000, $0000, $0000, $c000, $5c3f, $454d, $3ffd, $550c, $5435
word    $0000, $300c, $0000, $0000, $0000, $d773, $0005, $0000, $0000, $0000, $7000, $70d5, $1505, $c3fc, $5550, $05cd
word    $0000, $cd73, $0000, $0000, $0030, $c300, $0000, $0000, $0000, $0000, $7000, $f355, $5535, $30c1, $d554, $0543
word    $0000, $c003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $f000, $f15f, $5535, $0005, $d555, $0573
word    $0000, $300c, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $cd50, $5437, $5005, $f555, $3553
word    $0c00, $cc33, $0000, $0000, $0000, $30fc, $0003, $0000, $0000, $0000, $5000, $3350, $5cff, $5555, $ff15, $1573
word    $0000, $c043, $0000, $0000, $c000, $c0d5, $000d, $0000, $3000, $0000, $0000, $3c54, $5cfc, $5555, $0001, $d570
word    $0000, $c103, $0000, $0000, $7000, $c0f5, $000d, $0000, $0000, $0000, $7000, $ccd5, $5cf0, $5555, $c040, $5547
word    $0000, $cc33, $0000, $0000, $5000, $703d, $003d, $0000, $0000, $c000, $0000, $f310, $5cf3, $3555, $f450, $55c7
word    $0000, $300c, $0000, $0000, $c300, $700f, $0031, $0000, $0000, $0000, $c000, $54c5, $5c0f, $0155, $d0c0, $5505
word    $0000, $cd73, $0000, $0000, $0700, $f003, $0003, $0000, $0000, $0000, $c000, $54f1, $5c0f, $50d5, $4400, $5715
word    $5555, $5555, $5555, $0000, $1fc0, $0000, $0000, $3000, $0000, $0000, $0000, $553c, $570f, $5435, $00c1, $7c14
word    $7777, $7777, $7777, $0000, $1f00, $0000, $0007, $0000, $0000, $0000, $0000, $d54f, $5703, $d50d, $f0cc, $c003
word    $4444, $4444, $4444, $0000, $0300, $c000, $001f, $0000, $0000, $0000, $f000, $f553, $5530, $3c41, $5010, $00fd
word    $cccc, $cccc, $cccc, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3c00, $f554, $5f3c, $03c0, $541d, $fd55
word    $cccc, $cccc, $cccc, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $4f00, $3d55, $df37, $43f0, $5517, $5541
word    $cccc, $cccc, $cccc, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $f000, $cf55, $3735, $c040, $5517, $5551
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $fc00, $53d5, $3735, $f005, $55c5, $5550
word    $0f00, $0f00, $0f00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $f000, $53d5, $f735, $f0f5, $55c5, $555c
word    $ffff, $c003, $55ff, $0000, $0000, $0000, $5555, $5555, $0000, $0000, $f000, $54f7, $0f05, $7c3d, $55c5, $557c
word    $ffff, $300c, $fff5, $0000, $0000, $0000, $7777, $7777, $0000, $c000, $c000, $553f, $f303, $704c, $55c5, $557c
word    $ffff, $cc33, $0c05, $0000, $0000, $0000, $4444, $4444, $0000, $0000, $0000, $d50f, $4043, $0047, $5f05, $55f0
word    $ffff, $c043, $030d, $0000, $0000, $0000, $cccc, $cccc, $0000, $0000, $0000, $fd73, $7d54, $0104, $ff00, $ffc0
word    $ffff, $c103, $00c7, $0000, $0000, $0000, $cccc, $cccc, $0000, $0000, $0000, $07dc, $f554, $0545, $0000, $0000
word    $ffff, $cc33, $003f, $0000, $0000, $0000, $cccc, $cccc, $0000, $0000, $0000, $f37f, $d555, $0001, $0000, $0000
word    $ffff, $300c, $0007, $0000, $0300, $0000, $0000, $0000, $0000, $0000, $0000, $fcff, $fd55, $fffc, $043f, $54d4
word    $ffff, $cd73, $0007, $0000, $0000, $0000, $0f00, $0f00, $fc00, $0000, $f000, $ff0f, $35d5, $555f, $00f5, $547c
word    $ffff, $c003, $3333, $3333, $0000, $0000, $0000, $0000, $5c00, $003f, $0000, $7fc0, $05f1, $0007, $50d0, $30f0
word    $ffff, $300c, $cccc, $cccc, $0000, $0000, $0000, $0000, $5c00, $ffd5, $ffff, $4ff3, $05c1, $fff0, $d00f, $f3c3
word    $ffff, $cc33, $3333, $3333, $0000, $0000, $0000, $0000, $5c00, $5555, $5555, $57f3, $0555, $5554, $f015, $7307
word    $ffff, $c043, $cccc, $cccc, $0000, $0000, $0000, $0000, $7000, $0015, $5550, $75f0, $0555, $5557, $70d5, $7305
word    $ffff, $c103, $3333, $3333, $0000, $0000, $0000, $0000, $7000, $5555, $d555, $55f0, $05f7, $555f, $50f5, $7015
word    $ffff, $cc33, $cccc, $cccc, $0000, $0000, $0000, $0000, $c000, $541f, $f155, $d5c0, $05df, $fffc, $503f, $30fd
word    $ffff, $300c, $3333, $3333, $0000, $0000, $0000, $0000, $c000, $50ff, $fc15, $d5c0, $07d7, $00c0, $5000, $f03d
word    $f4df, $f4df, $f4dc, $cccc, $03f0, $0000, $0000, $0000, $0000, $03fc, $ff15, $f7c0, $07cd, $550c, $1540, $0550
word    $d7d4, $d7d4, $d7d4, $3333, $505c, $3305, $0000, $0000, $0000, $fff0, $ff54, $f7c0, $07c3, $4147, $5051, $1414
word    $5757, $5757, $5757, $cccc, $537c, $ccc5, $0000, $0000, $0000, $f000, $3f17, $17c0, $07c0, $4007, $5001, $1514
word    $d557, $d557, $d557, $3333, $01f0, $3300, $0000, $0000, $0003, $c000, $0fff, $3fc0, $07c0, $540f, $1500, $1554
word    $f55c, $f55c, $f55c, $cccc, $543f, $cc3d, $0000, $0000, $0000, $0000, $3ff0, $3c00, $07c0, $050f, $5000, $1454
word    $cd73, $cd73, $cd73, $f333, $5455, $333d, $0000, $0000, $0000, $0000, $0c00, $3c00, $0fc0, $414c, $5051, $1414
word    $f3cf, $c3c3, $f3cf, $cccc, $00ff, $c000, $0000, $0000, $0000, $0000, $0000, $f000, $0f40, $5540, $1541, $0550
word    $fc3f, $300c, $fc3f, $f333, $fc55, $33ff, $0000, $0000, $0000, $0000, $0000, $c000, $0f00, $000c, $0000, $0000





gfx_tiles_2b_tuxor

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3333, $cccc, $3333, $cccc, $3333, $cccc, $3333, $cccc
word    $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $dddd, $7777, $dddd, $7777, $dddd, $7777, $dddd, $7777
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $3033, $0f30, $30cc, $f3c3, $3cf0, $f3cc, $3033, $030c
word    $df77, $5555, $d75d, $d5dd, $f7f5, $7f4f, $f4f3, $330c, $3033, $0f30, $30cc, $c303, $0030, $cc00, $000c, $0000
word    $557c, $ddf3, $77cc, $dff0, $d5cc, $77f0, $d7c0, $0f00, $5555, $7777, $4444, $cccc, $cccc, $cccc, $0000, $0f00
word    $d57f, $4c31, $700d, $4001, $4003, $c003, $c003, $c003, $55ff, $fff5, $0c05, $030d, $00c7, $003f, $0007, $0007
word    $f555, $5fff, $5030, $70c0, $f300, $7c00, $7000, $f000, $000f, $0007, $0005, $0007, $0004, $000f, $0004, $000c
word    $7000, $f000, $7000, $4000, $7000, $f000, $4000, $4000, $5555, $5555, $5555, $5555, $7575, $7575, $f1f1, $d1d1
word    $0000, $0000, $0000, $0000, $3030, $1010, $d0d0, $d0d0, $4001, $1554, $0054, $1454, $0054, $1554, $0054, $4001
word    $c003, $300c, $cc33, $c043, $c103, $cc33, $300c, $cd73, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3
word    $fff3, $fcf3, $ffcf, $ff3f, $3cff, $f3ff, $cfff, $3fff, $fffc, $fcf3, $ffcf, $ff3f, $3cff, $f3ff, $cfff, $3fff
word    $fffc, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3
word    $ffff, $0fff, $f3ff, $fcff, $cf3f, $ffcf, $fff3, $ff33, $3fff, $cfff, $f3ff, $fcff, $cf3f, $ffcf, $fff3, $ff3c
word    $ffff, $0000, $ffff, $cfcf, $ffff, $ffff, $ffff, $ffff


map_gradient
byte     16,   8  'width, height
byte      2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3
byte      3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4
byte      4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5
byte      5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4
byte      4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3
byte      3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1,  2
byte      2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2,  1
byte      1,  2,  3,  4,  5,  4,  3,  2,  1,  2,  3,  4,  5,  4,  3,  2

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