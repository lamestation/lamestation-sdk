{{
KS0108 Sprite And Tile Graphics Library Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}

'' Why is this necessary?
'' http://en.wikipedia.org/wiki/Flat_memory_model



CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    FRAMES = 1

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES

    FRAMEFLIP = SCREENSIZE_BYTES
    
    SCREENLOCK = 0
    
    COLLIDEBIT = $80
    TILEBYTE = COLLIDEBIT-1    
    
    SPEED = 2
    
    
    
    
    SONGS = 1
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
    BARRESOLUTION = 8
    MAXBARS = 18    


OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX"
        audio   :               "LameAudio"        
        ctrl    :               "LameControl"
        pst     :               "LameSerial"

VAR

    word    prebuffer[TOTALBUFFER_BYTES/2]
    word    translatematrix_src[8]
    byte    translatematrix_dest[16]
    word    destpointer
    word    srcpointer    
    word    sourcegfx

    word    index
    word    index_x
    word    index_y    
    word    index1
    word    index2

    word    rotate
    
    word    screenpointer
    word    screen
    word    anotherpointer
    
    
    long    pos_x
    long    pos_y
    byte    pos_dir
    byte    pos_speed
    byte    pos_speedx
    
    byte    bulletbox_x
    byte    bulletbox_y
    byte    bulletbox
    byte    bulletbox_dir
    byte    bulletbox_speed
    
    
    long    x    
    long    y    
    long    tile
    long    tilecnt
    long    tilecnttemp


    long    xoffset




PUB Graphics_Demo

    dira~
    screenpointer := lcd.Start
    anotherpointer := @prebuffer
    gfx.Start(@anotherpointer)
    ctrl.Start
    audio.Start
    
    audio.SetWaveform(0, 127)
    audio.SetADSR(127, 100, 40, 100)
    audio.LoadSong(@pixel_theme)
    audio.PlaySong
    
    repeat
       { 
        repeat x from 0 to 10000
        gfx.Blit(@gfx_test_checker)        
        gfx.TranslateBuffer(@prebuffer, word[screenpointer])
        lcd.SwitchFrame
   }

            lcd.SwitchFrame
            ctrl.Update

            
            gfx.ClearScreen

            'DRAW TILES TO SCREEN
            tilecnt := 0
            tilecnttemp := 2
                
            repeat y from 0 to 7
                repeat x from 1 to 15
                    tilecnt := tilecnttemp + xoffset/8 + x
                    tile := (byte[@map_supersidescroll][tilecnt] & TILEBYTE) -1 
                    gfx.Box(@gfx_tiles_2b_tuxor + (tile << 4), (x << 3) - (xoffset // 8), (y << 3))

                tilecnttemp += byte[@map_supersidescroll][0]          
            
            
           ' gfx.Box(@gfx_test_box2,32,32)
            
            gfx.Box(@gfx_test_box2,pos_x,pos_y)
            
            if ctrl.Right
                if pos_x < 56
                    pos_x += SPEED
                else
                    'pos_x := 56
                    xoffset += SPEED
                    
                pos_dir := 1

            if ctrl.Left
                if xoffset > 0
                    xoffset -= SPEED
                else
                   'xoffset := 0
                   pos_x -= SPEED
                    
                pos_dir := 3


            if ctrl.Up
                pos_y -= SPEED
                pos_dir := 0

            if ctrl.Down
                pos_y += SPEED
                pos_dir := 2
                {
            pos_y += pos_speed
                
            if pos_y < 50
                pos_speed += 1
            else
                pos_y := 50
                pos_speed := 0
 
                 if ctrl.Up
                    pos_dir := 0            
                    pos_speed := -8
            


            if ctrl.Down
                pos_dir := 2
            }
                
            if ctrl.B or ctrl.A
                bulletbox := 1
                bulletbox_dir := pos_dir
                bulletbox_x := pos_x
                bulletbox_y := pos_y
                bulletbox_speed := 1
                
                
            if bulletbox

                if bulletbox_speed < 5
                    bulletbox_speed += 1
               
                if bulletbox_dir == 0
                    bulletbox_y -= bulletbox_speed                
                if bulletbox_dir == 1
                    bulletbox_x += bulletbox_speed                
                if bulletbox_dir == 2
                    bulletbox_y += bulletbox_speed                
                if bulletbox_dir == 3
                    bulletbox_x -= bulletbox_speed                                    

                if bulletbox_x =< 0 or bulletbox_x => 120 or bulletbox_y =< 0 or bulletbox_y => 56
                    bulletbox := 0
                else              
                    gfx.Box(@gfx_test_box2,bulletbox_x,bulletbox_y)
        
           ' repeat x from 0 to 1000            
            
            gfx.TranslateBuffer(@prebuffer, word[screenpointer])




PUB TranslateBuffer(destbuffer, sourcebuffer)

    srcpointer := 0
    destpointer := 0

    repeat index_y from 0 to 7 step 1
      repeat index_x from 0 to 15
    
        srcpointer  := ((index_y << 7) + index_x)       ' y is the long axis in linear mode; 256 bits/2 (word aligned here)
        destpointer := ((index_y << 4) + index_x) << 4      ' x is long axis in LCD layout




        ' COPY FROM SRC        
        repeat index1 from 0 to 15
            translatematrix_dest[index1] := 0
        
        
        ' TRANSLATION
        repeat index1 from 0 to 7
          translatematrix_src[index1] := word[sourcebuffer][srcpointer + (index1 << 4)] 
        
          rotate := 1
          repeat index2 from 0 to 15
            translatematrix_dest[index2] += ( translatematrix_src[index1] & rotate ) >> index2 << index1
            rotate <<= 1
        
        
        ' COPY TO DEST
        repeat index1 from 0 to 15
          byte[destbuffer][destpointer + index1] := translatematrix_dest[index1]



DAT


gfx_test_box2
word    $5554, $4001, $4dd1, $4dd1, $4dd1, $4dd1, $4001, $5555




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
word    $ffff, $0000, $ffff, $cfcf, $ffff, $ffff, $ffff, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa




map_supersidescroll
byte    100,   8  'width, height
byte      3,  3,  3,  3,  3,  3,  3,  2,  3,  3,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  3,  3,  3,  3,  2,  1,  1,  1, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      3,  3,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  4,  4,  4,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  3,  3,  3,  2,  2,  1,  1,  1, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      3,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1,  1,  1, 10, 10, 10, 10, 10, 10, 10,  1,  1,  1,  1,  1,  2,  3,  4,  4,  4,  5,  5,  5,  5,  5,  5,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  3,  3,  3,  2,  1,  1,  1,  1, 21, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1, 13, 19, 12,  1,  1,  1,  1,  1,  2,  2,  3,  3,  4,  4,  4,  4,  4,  4,  5,  5,  5,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  2,  2,  3,  3,  3,  3,  2,  2,  2,  3,  3,  2,  2,  1,  1,  1,  2, 20, 23,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1, 19,  1,  1, 10,  1, 10,  1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,  1,  5,  5,  5,  5,  4,  4,  4,  4,  4,  4,  4,  4,  7,  7,  7,  2,  2,  3,  3,  2,  2,  3,  3,  3,  3,  2,  1,  1,  1,  2,  2, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      9,  9,  9,  3,  3,  3,  3,  3,  3,  5,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2, 10, 10, 10,  9,  1,  1,  1,  1, 19,  1,  1,  1,  1,  1,  1, 19,  2,  2, 19,  2,  2, 19,  2, 13, 19, 12,  1,  1,  1,  1,  1,  1,  5,  5,  5,  5,  5,  5,  1,  2,  6,  6,  6,  2,  2,  2,  3,  3,  3,  3,  3,  3,  2,  2,  1,  1,  2,  3,  3, 20, 24,  3,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3,  4, 19,  2,  3
byte      9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  3,  3,  3,  3,  3,  3,  3,  3,  3, 19,  1,  1,  9,  9,  9,  1,  1, 19,  1,  1,  1,  1,  1,  1, 19,  2,  2, 19,  2,  2, 19,  1,  1, 19,  1,  1,  1,  1,  1,  1,  2,  7,  7,  7,  7,  7,  7,  7,  7,  6,  6,  6,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7
byte      9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  1,  1, 19,  1,  1,  1,  1,  2,  2, 19,  1,  1, 19,  1,  1, 19,  1,  1, 19,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8







pixel_theme

byte    14     'number of bars
byte    40     'tempo
byte    8      'bar resolution

'MAIN SECTION
byte    0, 26,  26,  26,  38,   26,  26,  39,  26
byte    0, 26,  36,  26,  26,   36,  26,  36,  38
byte    0, 26,  26,  26,  33,   26,  26,  34,  26
byte    0, 31,  26,  33,  26,   29,  26,  31,  28

byte    1, 14, SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    1,SOFF,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP

byte    2, 33,  33,  33,  36,   33,  33,  36,  33
byte    2, 33,  36,  33,  33,   36,  33,  36,  38

byte    1, 14,  14,  14,  17,   14,  14,  17,  14
byte    1, 14,  17,  14,  14,   17,  14,  17,  19

'UPLIFTING
byte    0, 31,  31,  31,  34,   31,  31,  34,  31
byte    0, 31,  34,  31,  31,   34,  31,  34,  36



byte    1, 19,  19,  19,  22,   19,  19,  22,  19
byte    1, 19,  22,  19,  19,   22,  19,  22,  24




'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,6,BAROFF
byte    1,7,BAROFF
byte    2,6,BAROFF
byte    3,7,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

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
