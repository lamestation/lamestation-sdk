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

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES
    
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
        ctrl    :               "LameControl"

VAR

    word    prebuffer[TOTALBUFFER_BYTES/2]
    
    word    screen
    
    
    long    pos_x
    long    pos_y
    byte    pos_dir
    long    pos_speed
    long    pos_speedx
    
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
    
    screen := lcd.Start
    gfx.Start(@prebuffer) 
    
    ctrl.Start
    
'    dira[24]~~
        
    repeat
    {{
            outa[24]~
        
            repeat x from 0 to 1000
        
            outa[24]~~
            
            repeat x from 0 to 1000
            }}
            ctrl.Update

            
            gfx.ClearScreen

            gfx.DrawMap(@gfx_tiles_2b_tuxor, @map_supersidescroll, xoffset, 0, 15, 7)
                       
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

            pos_speed += 1
            pos_y += pos_speed
            
            if pos_y > 50
               pos_y := 50
               pos_speed := 0
 
               if ctrl.Up
                  pos_dir := 0            
                  pos_speed := -10
            


            if ctrl.Down
                pos_dir := 2
            
                
            if ctrl.B
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
            
            gfx.TranslateBuffer(@prebuffer, screen)

DAT

gfx_test_box2
word    $5554, $4001, $4dd1, $4dd1, $4dd1, $4dd1, $4001, $5555





gfx_player
word    576  'frameboost
word    48, 48   'width, height

word    $0aaa, $aa80, $0aaa, $aa80, $0aaa, $aa80, $72aa, $aa3f, $72aa, $aa3f, $72aa, $aa3f, $f2aa, $aa04, $f2aa, $aa04
word    $f2aa, $aa04, $f2aa, $aa04, $f2aa, $aa04, $f2aa, $aa04, $c0aa, $aa3f, $c0aa, $aa3f, $c0aa, $aa3f, $043a, $aa00
word    $043a, $aa00, $043a, $aa00, $1f12, $aa8f, $1f12, $aa8f, $1f12, $aa8f, $0012, $aa37, $0012, $aa37, $0012, $aa37
word    $3732, $0000, $3732, $0000, $3732, $0000, $c732, $3557, $c732, $3557, $c732, $3557, $4732, $1d75, $4732, $1d75
word    $4732, $1d75, $cc02, $175d, $cc02, $175d, $cc02, $175d, $000a, $830c, $000a, $830c, $000a, $830c, $02aa, $a000
word    $02aa, $a000, $02aa, $a000, $0aaa, $a000, $0aaa, $a000, $0aaa, $a800, $c2aa, $a333, $f0aa, $8cc3, $02aa, $a8f0
word    $70aa, $adc1, $572a, $b703, $00aa, $a35c, $5caa, $adc3, $d5c2, $b703, $3c2a, $ad70, $5f2a, $a170, $f542, $f5c8
word    $372a, $8d70, $57ca, $a170, $3f0c, $c5ca, $fc2a, $8df0, $df0a, $a3fc, $8c1c, $0fea, $300a, $43c0, $002a, $a002
word    $a07f, $802a, $03ca, $d00a, $05ca, $a70a, $aa7e, $9c2a, $a7ca, $3f2a, $9ffa, $9fca, $aa0e, $7f2a, $8c2a, $ac2a
word    $02aa, $aaa0, $02aa, $aaa0, $02aa, $aaa0, $fcaa, $aa8d, $fcaa, $aa8d, $fcaa, $aa8d, $10aa, $aa8f, $10aa, $aa8f
word    $10aa, $aa8f, $10aa, $aa8f, $10aa, $aa8f, $10aa, $aa8f, $fcaa, $aa03, $fcaa, $aa03, $fcaa, $aa03, $00aa, $ac10
word    $00aa, $ac10, $00aa, $ac10, $f2aa, $84f4, $f2aa, $84f4, $f2aa, $84f4, $dcaa, $8400, $dcaa, $8400, $dcaa, $8400
word    $0000, $8cdc, $0000, $8cdc, $0000, $8cdc, $d55c, $8cd3, $d55c, $8cd3, $d55c, $8cd3, $5d74, $8cd1, $5d74, $8cd1
word    $5d74, $8cd1, $75d4, $8033, $75d4, $8033, $75d4, $8033, $30c2, $a000, $30c2, $a000, $30c2, $a000, $000a, $aa80
word    $000a, $aa80, $000a, $aa80, $000a, $aaa0, $000a, $aaa0, $002a, $aaa0, $ccca, $aa83, $c332, $aa0f, $0f2a, $aa80
word    $437a, $aa0d, $c0de, $a8d5, $35ca, $aa00, $c37a, $aa35, $c0de, $8357, $0d7a, $a83c, $0d4a, $a8f5, $235f, $815f
word    $0d72, $a8dc, $0d4a, $a3d5, $a353, $30fc, $0f72, $a83f, $3fca, $a0f7, $abf0, $3432, $03c1, $a00c, $800a, $a800
word    $a802, $fd0a, $a007, $a3c0, $a0da, $a350, $a836, $bdaa, $a8fc, $a3da, $a3f6, $aff6, $a8fd, $b0aa, $a83a, $a832







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
