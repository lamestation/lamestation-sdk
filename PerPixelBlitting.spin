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
    byte    pos_frame
    
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
    
    dira[24]~~
        
    repeat
    {{
            outa[24]~
        
            repeat x from 0 to 1000
        
            outa[24]~~
            
            repeat x from 0 to 1000
      }}      
            ctrl.Update

            
            gfx.ClearScreen

            gfx.DrawMap(@gfx_tiles_2b_tuxor, @map_supersidescroll, xoffset, 0, 0,0, 16, 8)
                       
'            gfx.Box(@gfx_test_box2,pos_x,pos_y)
            gfx.Sprite(@gfx_test_box3,pos_x,30, 0, 0, 0)      

            'if pos_dir == 3
            '    gfx.Sprite(@gfx_player,pos_x,pos_y, 3+pos_frame//3, 0, 0)
            'if pos_dir == 1
            gfx.Sprite(@gfx_tank1,pos_x,pos_y, 0, 0, 0)
            
'            gfx.Sprite(@gfx_player,8,0, 0, 0, 0)
 '           gfx.Sprite(@gfx_player,60,30, 0, 0, 0)
      
            {{
            if ctrl.Right
                pos_x += SPEED

            if ctrl.Left
                pos_x -= SPEED

            if ctrl.Down
                pos_y += SPEED

            if ctrl.Up
                pos_y -= SPEED
                
                }}
                    
            if ctrl.Left or ctrl.Right
                if ctrl.Right
                    if pos_x < 56
                        pos_x += SPEED
                    else
                        'pos_x := 56
                        xoffset += SPEED
                        
                    pos_frame++
                    if pos_frame => 15
                       pos_frame := 0
                        
                    pos_dir := 1
    
                if ctrl.Left
    
                    pos_frame++
                    if pos_frame => 15
                       pos_frame := 0
                
                    if xoffset > 0
                        xoffset -= SPEED
                    else
                       'xoffset := 0
                       pos_x -= SPEED
                        
                    pos_dir := 3
                    
            else
                pos_frame := 0
                

            pos_speed += 1
            pos_y += pos_speed
            
            if pos_y > 40
               pos_y := 40
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

gfx_test_box3
word    16  'frameboost
word    8, 8   'width, height
word    $5554, $4001, $4dd1, $4dd1, $4dd1, $4dd1, $4001, $5555




gfx_player
word    96  'frameboost
word    16, 24   'width, height

word    $0aaa, $aa80, $72aa, $aa3f, $f2aa, $aa04, $f2aa, $aa04, $c0aa, $aa3f, $043a, $aa00, $1f12, $aa8f, $0012, $aa37
word    $3732, $0000, $c732, $3557, $4732, $1d75, $cc02, $175d, $000a, $830c, $02aa, $a000, $0aaa, $a000, $c2aa, $a333
word    $70aa, $adc1, $5caa, $adc3, $5f2a, $a170, $57ca, $a170, $df0a, $a3fc, $002a, $a002, $05ca, $a70a, $9ffa, $9fca
word    $0aaa, $aa80, $72aa, $aa3f, $f2aa, $aa04, $f2aa, $aa04, $c0aa, $aa3f, $043a, $aa00, $1f12, $aa8f, $0012, $aa37
word    $3732, $0000, $c732, $3557, $4732, $1d75, $cc02, $175d, $000a, $830c, $02aa, $a000, $0aaa, $a000, $f0aa, $8cc3
word    $572a, $b703, $d5c2, $b703, $f542, $f5c8, $3f0c, $c5ca, $8c1c, $0fea, $a07f, $802a, $aa7e, $9c2a, $aa0e, $7f2a
word    $0aaa, $aa80, $72aa, $aa3f, $f2aa, $aa04, $f2aa, $aa04, $c0aa, $aa3f, $043a, $aa00, $1f12, $aa8f, $0012, $aa37
word    $3732, $0000, $c732, $3557, $4732, $1d75, $cc02, $175d, $000a, $830c, $02aa, $a000, $0aaa, $a800, $02aa, $a8f0
word    $00aa, $a35c, $3c2a, $ad70, $372a, $8d70, $fc2a, $8df0, $300a, $43c0, $03ca, $d00a, $a7ca, $3f2a, $8c2a, $ac2a
word    $02aa, $aaa0, $fcaa, $aa8d, $10aa, $aa8f, $10aa, $aa8f, $fcaa, $aa03, $00aa, $ac10, $f2aa, $84f4, $dcaa, $8400
word    $0000, $8cdc, $d55c, $8cd3, $5d74, $8cd1, $75d4, $8033, $30c2, $a000, $000a, $aa80, $000a, $aaa0, $ccca, $aa83
word    $437a, $aa0d, $c37a, $aa35, $0d4a, $a8f5, $0d4a, $a3d5, $3fca, $a0f7, $800a, $a800, $a0da, $a350, $a3f6, $aff6
word    $02aa, $aaa0, $fcaa, $aa8d, $10aa, $aa8f, $10aa, $aa8f, $fcaa, $aa03, $00aa, $ac10, $f2aa, $84f4, $dcaa, $8400
word    $0000, $8cdc, $d55c, $8cd3, $5d74, $8cd1, $75d4, $8033, $30c2, $a000, $000a, $aa80, $000a, $aaa0, $c332, $aa0f
word    $c0de, $a8d5, $c0de, $8357, $235f, $815f, $a353, $30fc, $abf0, $3432, $a802, $fd0a, $a836, $bdaa, $a8fd, $b0aa
word    $02aa, $aaa0, $fcaa, $aa8d, $10aa, $aa8f, $10aa, $aa8f, $fcaa, $aa03, $00aa, $ac10, $f2aa, $84f4, $dcaa, $8400
word    $0000, $8cdc, $d55c, $8cd3, $5d74, $8cd1, $75d4, $8033, $30c2, $a000, $000a, $aa80, $002a, $aaa0, $0f2a, $aa80
word    $35ca, $aa00, $0d7a, $a83c, $0d72, $a8dc, $0f72, $a83f, $03c1, $a00c, $a007, $a3c0, $a8fc, $a3da, $a83a, $a832



gfx_tank1
word    64  'frameboost
word    16, 16   'width, height

word    $00aa, $a8fc, $552a, $a350, $552a, $a3dc, $000a, $a0f4, $57ca, $bfc1, $57ca, $b551, $0000, $bff0, $fffc, $b553
word    $5554, $8771, $fffc, $b573, $0000, $8ff0, $001a, $8000, $c1ce, $91c1, $0306, $b303, $003a, $a400, $776a, $ab77
word    $3f2a, $aa00, $05ca, $a855, $37ca, $a855, $1f0a, $a000, $43fe, $a3d5, $455e, $a3d5, $0ffe, $0000, $c55e, $3fff
word    $4dd2, $1555, $cd5e, $3fff, $0ff2, $0000, $0002, $a400, $4346, $b343, $c0ce, $90c0, $001a, $ac00, $ddea, $a9dd
word    $52de, $b785, $54dc, $3715, $00dc, $3700, $573c, $3f55, $57d0, $37d5, $5f1c, $d5d5, $fc3c, $df3f, $0010, $f400
word    $c03c, $d403, $f03c, $d40d, $c03c, $3c01, $0000, $0000, $7055, $550d, $c0ff, $ff03, $0855, $5520, $aaff, $ffaa
word    $70aa, $aa0d, $00c2, $9c00, $5c5c, $5435, $545c, $5715, $54f0, $7c15, $507c, $df05, $00f0, $3c30, $f0dc, $3737
word    $c0dc, $3707, $005c, $1700, $f103, $40cf, $c100, $4003, $0300, $c000, $a0c3, $f00a, $a855, $552a, $aaff, $ffaa





gfx_vortex
word    1024  'frameboost
word    64, 64   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $00aa, $0000, $0000, $aa80
word    $aaaa, $aaaa, $aaaa, $aaaa, $002a, $0000, $3d5f, $aa80, $aaaa, $aaaa, $aaaa, $aaaa, $540a, $1550, $5540, $aa03
word    $aaaa, $aaaa, $aaaa, $aaaa, $5402, $1571, $5444, $aa0d, $aaaa, $aaaa, $aaaa, $2aaa, $fc03, $15c3, $4344, $aa3d
word    $aaaa, $aaaa, $aaaa, $00aa, $0000, $4700, $0d44, $a835, $aaaa, $aaaa, $02aa, $0000, $ffc0, $4f0f, $3d44, $a834
word    $aaaa, $aaaa, $f2aa, $57ff, $5555, $4035, $fd44, $a0f4, $aaaa, $aaaa, $5caa, $5555, $5555, $0fd5, $f541, $80d0
word    $aaaa, $aaaa, $570a, $f555, $d557, $3d57, $3550, $03d4, $aaaa, $aaaa, $5542, $5555, $5555, $ff55, $0150, $0fd5
word    $aaaa, $aaaa, $d570, $555f, $5555, $ffd5, $5354, $ff55, $aaaa, $aaaa, $55f2, $0055, $57d4, $3ff5, $5c54, $ff55
word    $aaaa, $aaaa, $5f02, $54d5, $5550, $0ffd, $54d5, $fff5, $aaaa, $aaaa, $f002, $54d5, $d551, $43ff, $550d, $003f
word    $aaaa, $aaaa, $0002, $5357, $f551, $10ff, $f570, $4103, $aaaa, $aaaa, $3fc2, $4d5c, $fd45, $0c3f, $3555, $0054
word    $aaaa, $aaaa, $d570, $0570, $fc15, $50c3, $cd55, $0005, $aaaa, $aaaa, $5570, $35f3, $c155, $5430, $43d5, $0005
word    $aaaa, $aaaa, $5ff2, $35f1, $0555, $5500, $73d5, $0005, $aaaa, $aaaa, $5002, $37cd, $0554, $5550, $53f5, $0035
word    $aaaa, $aaaa, $5052, $ff33, $555c, $1555, $73ff, $0015, $aaaa, $aaaa, $5402, $fc3c, $555c, $0155, $7000, $00d5
word    $aaaa, $aaaa, $d572, $f0cc, $555c, $4055, $47c0, $0355, $aaaa, $aaaa, $100a, $f3f3, $555c, $5035, $c7f4, $3555
word    $aaaa, $aaaa, $c5ca, $0f54, $555c, $c001, $05d0, $1555, $aaaa, $aaaa, $f1ca, $0f54, $d55c, $0050, $1544, $5557
word    $aaaa, $aaaa, $3c02, $0f55, $3557, $c154, $1400, $557c, $aaaa, $aaaa, $4f02, $03d5, $0d57, $ccd5, $03f0, $7fc0
word    $aaaa, $aaaa, $53f2, $30f5, $4155, $103c, $fd50, $0000, $aaaa, $aaaa, $543c, $3cf5, $c05f, $1d03, $5554, $fffd
word    $aaaa, $aaaa, $554f, $373d, $f0df, $1743, $4155, $5455, $aaaa, $aaaa, $55f0, $35cf, $4037, $17c0, $5155, $5455
word    $aaaa, $aaaa, $d5fc, $3553, $0537, $c5f0, $5055, $5455, $aaaa, $aaaa, $d5f2, $3553, $f5f7, $c5f0, $5c55, $5c55
word    $aaaa, $aaaa, $f7f2, $0554, $3d0f, $c57c, $7c55, $5c55, $aaaa, $aaaa, $3fca, $0355, $4cf3, $c570, $7c55, $7c55
word    $aaaa, $aaaa, $0f0a, $43d5, $4740, $0500, $f05f, $7055, $aaaa, $aaaa, $730a, $54fd, $047d, $0001, $c0ff, $f0ff
word    $aaaa, $aaaa, $dc02, $5407, $45f5, $0005, $0000, $0000, $aaaa, $aaaa, $7f02, $55f3, $55d5, $5555, $0000, $0000
word    $a800, $aaaa, $ff00, $55fc, $57fd, $5555, $5555, $5555, $00fc, $0aa8, $0ff0, $d5ff, $55f5, $5555, $5555, $0555
word    $3f5c, $0000, $c000, $f17f, $05f5, $0030, $1000, $fc30, $d55c, $ffff, $f3ff, $c14f, $c7f5, $ffff, $5fff, $fffd
word    $555e, $5555, $f355, $5557, $c3d5, $5517, $5555, $fd7d, $1572, $5000, $f055, $5575, $4dd5, $5555, $5555, $fd77
word    $5572, $5555, $f0d5, $f755, $71d5, $5501, $5555, $ff77, $1fca, $5554, $c0f1, $dfd5, $f1d5, $5501, $5555, $c337
word    $ffea, $1550, $c0fc, $d7d5, $c1d7, $5535, $5555, $c0f3, $fc2a, $1503, $c0ff, $cdf7, $cdd7, $5535, $7515, $f0f7
word    $f0aa, $54ff, $c0ff, $c3f7, $ccd7, $5c35, $7415, $000f, $02aa, $17f0, $c03f, $c017, $43f7, $7c31, $7407, $000f
word    $aaaa, $ffc0, $c00f, $c03f, $c3f7, $7017, $7c05, $0007, $aaaa, $f002, $003f, $c03c, $c037, $f41f, $7c01, $0000
word    $aaaa, $002a, $000c, $c03c, $003f, $f01f, $fc01, $0000, $aaaa, $00aa, $0000, $40f0, $000f, $f00f, $3c07, $0000
word    $aaaa, $2aaa, $0000, $00c0, $000f, $c03c, $300f, $0004, $aaaa, $2aaa, $0000, $0000, $0000, $0000, $300d, $0000
word    $aaaa, $aaaa, $0000, $0000, $0000, $0000, $0400, $0000, $aaaa, $aaaa, $0000, $0000, $0000, $0000, $0000, $0000
word    $aaaa, $aaaa, $0002, $0000, $0000, $0000, $0000, $0000, $aaaa, $aaaa, $0002, $0000, $0000, $0000, $0000, $0000










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
