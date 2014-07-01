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
            
        gfx.Blit(@gfx_rpgtowncrop)
            
'        positionx &= $7F
            
          
 '       repeat x from 0 to 5000

DAT


gfx_krakken
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $af5f, $aaaa, $aaaa, $4114, $aaab, $57aa, $5104, $aab0, $757a, $d7f5, $aa14, $c0de, $7555, $af0d, $c006
word    $5555, $c575, $4047, $555d, $d1d7, $500d, $57d5, $1755, $557d, $dd75, $4545, $5d55, $555f, $5545, $d57f, $1554
word    $0dcd, $ff02, $1554, $0305, $3556, $1554, $a80c, $000a, $555d, $aa8c, $2aaa, $75dd, $aaa8, $aaaa, $01d0, $aaaa

          
gfx_rpgtowncrop
word    2048  'frameboost
word    128, 64   'width, height

word    $43c4, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $575c, $31f0, $43c4, $d7c0, $d7c3, $c3d7, $d7c3, $d7c3, $d7c3
word    $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5515, $0000, $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c
word    $f55c, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $5d57, $4c7c, $f55c, $c3d4, $c3d7, $d7c3, $c3d7, $c3d7, $c3d7
word    $3554, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $fc3d, $d555, $4000, $3554, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $7c3d
word    $f554, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $45d5, $31f1, $f554, $d7c0, $d7c3, $c3d7, $d7c3, $d7c3, $d7c3
word    $3554, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5557, $0000, $3554, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c
word    $0ff4, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $7551, $4c7c, $0ff4, $c3d4, $c3d7, $d7c3, $c3d7, $c3d7, $c3d7
word    $50c1, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $fc3d, $5d55, $4000, $50c1, $7c3f, $7c3d, $7c3d, $7c3d, $7c3d, $7c3d
word    $43c4, $d7c0, $d7c3, $d7c3, $c3d7, $c3d7, $03d7, $575c, $31f0, $575c, $d7c0, $03c3, $c3c0, $d7c3, $d7c3, $03c3
word    $1551, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $3d7c, $5515, $0000, $5515, $3d7c, $003c, $3c00, $3d7c, $3d7c, $003c
word    $f55c, $c3d4, $c3d7, $c3d7, $d7c3, $d7c3, $17c3, $5d57, $4c7c, $5d57, $c3d4, $1143, $c144, $c3d7, $c3d7, $1143
word    $3554, $7c3f, $7c3d, $3c3d, $7c3c, $7c3d, $fc3d, $d555, $4000, $d555, $3c3f, $1154, $7c04, $7c3d, $3c3d, $1154
word    $f554, $d7c0, $d7c3, $43c3, $c3c1, $c3d7, $03d7, $45d5, $31f1, $45d5, $43c0, $1155, $d7c0, $d7c3, $43c3, $1155
word    $3554, $3d7c, $3d7c, $543c, $3c15, $3d7c, $3d7c, $5557, $0000, $5557, $543c, $1155, $3d7c, $3d7c, $543c, $1155
word    $0ff4, $c3d4, $c3d7, $0003, $c000, $d7c3, $17c3, $7551, $4c7c, $7551, $0000, $1000, $c3d4, $c3d7, $0003, $1000
word    $50c1, $7c3f, $7c3d, $fffc, $3fff, $7c3d, $fc3d, $5d55, $4000, $5d55, $fffc, $03ff, $7c3f, $7c3d, $fffc, $03ff
word    $575c, $d7c0, $03c3, $0000, $0000, $c3c0, $03d7, $575c, $31f0, $575c, $0000, $0000, $d7c0, $03c3, $0000, $0000
word    $5515, $3d7c, $003c, $5555, $5555, $3c00, $3d7c, $5515, $0000, $5515, $0000, $0000, $3d7c, $003c, $5555, $5555
word    $5d57, $c3d4, $1143, $5555, $5555, $c144, $17c3, $5d57, $4c7c, $5d57, $4444, $4444, $c3d4, $1143, $5555, $5555
word    $d555, $3c3f, $1154, $5555, $5555, $1544, $fc3c, $d555, $4000, $d555, $4444, $4444, $3c3f, $1154, $5555, $5555
word    $45d5, $43c0, $1155, $5555, $5555, $5544, $03c1, $45d5, $31f1, $45d5, $0000, $0000, $43c0, $1155, $5555, $5555
word    $5557, $543c, $1155, $5555, $5555, $5544, $3c15, $5557, $0000, $5557, $0000, $0000, $543c, $1155, $5555, $5555
word    $7551, $0000, $1000, $0000, $0000, $0004, $0000, $7551, $4c7c, $7551, $1554, $1554, $0000, $1000, $0000, $0000
word    $5d55, $fffc, $03ff, $ffff, $ffff, $ffc0, $3fff, $5d55, $4000, $5d55, $0000, $0000, $fffc, $03ff, $ffff, $ffff
word    $575c, $0000, $0000, $0000, $0000, $0000, $0000, $575c, $31f0, $575c, $575c, $43c4, $0000, $0000, $0000, $0000
word    $5515, $0000, $0000, $3ffc, $3ffc, $0000, $0000, $5515, $0000, $5515, $5515, $1551, $0000, $0000, $3ffc, $0000
word    $5d57, $4444, $4444, $355c, $355c, $4444, $4444, $5d57, $4c7c, $5d57, $5d57, $f55c, $4444, $4444, $355c, $4444
word    $d555, $4444, $4444, $355c, $355c, $4444, $4444, $d555, $4000, $d555, $d555, $3554, $4444, $4444, $355c, $4444
word    $45d5, $0000, $0000, $03fc, $3fc0, $0000, $0000, $45d5, $31f1, $45d5, $45d5, $f554, $0000, $0000, $03fc, $0000
word    $5557, $0000, $0000, $355c, $355c, $0000, $0000, $5557, $0000, $5557, $5557, $3554, $0000, $0000, $355c, $0000
word    $7551, $1554, $1554, $3ffc, $3ffc, $1554, $1554, $7551, $4c7c, $7551, $7551, $0ff4, $1554, $1554, $3ffc, $1554
word    $5d55, $0000, $0000, $0000, $0000, $0000, $0000, $5d55, $4000, $5d55, $5d55, $50c1, $0000, $0000, $0000, $0000
word    $5554, $575c, $575c, $575c, $31f0, $4000, $575c, $575c, $31f0, $575c, $575c, $575c, $575c, $575c, $31f0, $4000
word    $5005, $5515, $5515, $5515, $0000, $3ffc, $5515, $5515, $0000, $5515, $5515, $5515, $5515, $5515, $0000, $3ffc
word    $4711, $5d57, $5d57, $5d57, $4c7c, $30cc, $5d57, $5d57, $4c7c, $5d57, $5d57, $5d57, $5d57, $5d57, $4c7c, $30cc
word    $0df0, $d555, $d555, $d555, $4000, $3ffc, $d555, $d555, $4000, $d555, $d555, $d555, $d555, $d555, $4000, $3ffc
word    $1cdc, $45d5, $45d5, $45d5, $31f1, $4001, $45d5, $45d5, $31f1, $45d5, $45d5, $45d5, $45d5, $45d5, $31f1, $4001
word    $11c0, $5557, $5557, $5557, $0000, $5415, $5557, $5557, $0000, $5557, $5557, $5557, $5557, $5557, $0000, $5415
word    $0f10, $7551, $7551, $7551, $4c7c, $5714, $7551, $7551, $4c7c, $7551, $7551, $7551, $7551, $7551, $4c7c, $5714
word    $11c0, $5d55, $5d55, $5d55, $4000, $1575, $5d55, $5d55, $4000, $5d55, $5d55, $5d55, $5d55, $5d55, $4000, $1575
word    $3300, $575c, $575c, $575c, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0, $f1f0
word    $0000, $5515, $5515, $5515, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001
word    $4001, $5d57, $5d57, $5d57, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c
word    $5c15, $d555, $d555, $d555, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $54dd, $45d5, $45d5, $45d5, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1, $f1f1
word    $7715, $5557, $5557, $5557, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001
word    $4cf1, $7551, $7551, $7551, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c, $7c7c
word    $5555, $5d55, $5d55, $5d55, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $575c, $575c, $43c4, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c, $575c
word    $5515, $5515, $1551, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515, $5515
word    $5d57, $5d57, $f55c, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57, $5d57
word    $d555, $d555, $3554, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555, $d555
word    $45d5, $45d5, $f554, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5, $45d5
word    $5557, $5557, $3554, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557, $5557
word    $7551, $7551, $0ff4, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551, $7551
word    $5d55, $5d55, $50c1, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55, $5d55
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $575c
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5515
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5d57
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $d555
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $45d5
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $5557
word    $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $4444, $7551
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5d55




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