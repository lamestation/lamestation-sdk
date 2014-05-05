{{
KS0108 Sprite And Tile Graphics Library Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
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
        ctrl    :               "LameControl"


VAR

    word    buffer[1024]
    word    screen

    byte    slide
    byte    clicked
    long    positionx


PUB GraphicsDemo | x

    screen := lcd.Start
    gfx.Start(@buffer)
    gfx.LoadMap(@gfx_tiles_2b_tuxor,@map_gradient)

    slide := 0
   
    repeat
        'The LCD and graphics libraries enforce flipping between
        'two pages in memory to prevent screen flicker, but this
        'functionality is hidden from the user.
        
        'To update the screen, you call gfx.TranslateBuffer.
        
        ctrl.Update
        gfx.TranslateBuffer(@buffer, screen)
        gfx.ClearScreen
        
'        case slide
 '           0: gfx.ClearScreen
  '          1: gfx.Sprite(@gfx_krakken,0,0,0)
   '         2: gfx.Blit(@gfx_test_checker)
    '        3: gfx.DrawMap(0,0,1,1,14,6)
        gfx.DrawMap(positionx,0,0,0,16,8)

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
            
'        positionx &= $7F
            
          
 '       repeat x from 0 to 5000

DAT


gfx_krakken
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $af5f, $aaaa, $aaaa, $4114, $aaab, $57aa, $5104, $aab0, $757a, $d7f5, $aa14, $c0de, $7555, $af0d, $c006
word    $5555, $c575, $4047, $555d, $d1d7, $500d, $57d5, $1755, $557d, $dd75, $4545, $5d55, $555f, $5545, $d57f, $1554
word    $0dcd, $ff02, $1554, $0305, $3556, $1554, $a80c, $000a, $555d, $aa8c, $2aaa, $75dd, $aaa8, $aaaa, $01d0, $aaaa

          
gfx_test_checker
word    2048  'frameboost
word    128, 64   'width, height

word    $0001, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $5554, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1555
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $5554, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $0000, $5555, $1000
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $0004, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, $1fff
word    $5554, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1555
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000



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





{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │                                             
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
