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
    
    long    bounce_x
    long    bounce_y
    long    bounce_speedx
    long    bounce_speedy
    long    bounce_forcex
    long    bounce_forcey
    
    long    xoffset
    
    byte    tiles_on




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
    
    
    bounce_x := 40
    bounce_y := 5
    bounce_speedx := 10
    
    'gfx.Blit(@gfx_logo_tankbattle)
    
    'gfx.TranslateBuffer(@prebuffer, word[screenpointer])
    
    'lcd.SwitchFrame
    
    'repeat x from 0 to 500000
    
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
            
            if ctrl.A
                if tiles_on
                    tiles_on := 0
                else
                    tiles_on := 1
                

            if tiles_on
                'DRAW TILES TO SCREEN
                tilecnt := 0
                tilecnttemp := 2
                    
                repeat y from 0 to 7
                    repeat x from 1 to 15
                        tilecnt := tilecnttemp + (xoffset >> 3) + x
                        tile := (byte[@map_supersidescroll][tilecnt] & TILEBYTE) -1 
                        if tile > 0
                            gfx.Box(@gfx_tiles_2b_tuxor + (tile << 4), (x << 3) - (xoffset & $7), (y << 3))

                    tilecnttemp += byte[@map_supersidescroll][0]          
            
            
            {
            bounce_forcex := (60 - bounce_x) >> 3
            bounce_forcey := (28 - bounce_y) >> 3
            bounce_speedx += bounce_forcex
            bounce_speedy += bounce_forcey
            bounce_x += bounce_speedx
            bounce_y += bounce_speedy            
            gfx.Box(@gfx_test_box2,bounce_x,bounce_y)
            }
            'gfx.Sprite(@gfx_player, pos_x, pos_y, 0, 1, 0)              
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


        {    if ctrl.Up
                pos_y -= SPEED
                pos_dir := 0

            if ctrl.Down
                pos_y += SPEED
                pos_dir := 2
         }       

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

{{
gfx_logo_tankbattle
word    2048  'frameboost
word    128, 64   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $c350, $4057, $1555, $5540, $0035, $f500, $1000, $5570, $3401, $0170, $5f55, $5c05, $0555, $0005, $5400, $0155
word    $00d0, $507f, $5555, $f550, $10c3, $d540, $0000, $5fc0, $d505, $05c0, $f0f5, $f005, $0555, $4005, $5500, $000f
word    $0000, $0000, $5000, $0050, $5000, $0140, $0000, $0000, $0005, $0500, $0000, $0000, $0000, $000d, $053c, $0000
word    $c000, $0000, $5000, $0070, $5000, $0150, $0000, $000c, $3c05, $0500, $0003, $0000, $000c, $0003, $053c, $0000
word    $f001, $0000, $5000, $0070, $50c0, $00d4, $00c0, $000f, $0ff5, $0500, $0000, $0004, $000f, $0000, $050f, $3000
word    $7000, $d0c0, $5703, $0070, $5070, $0035, $0000, $5557, $5535, $0555, $0000, $03c0, $030f, $f000, $d50f, $0000
word    $5000, $5000, $5c0f, $00c0, $7070, $000d, $0000, $ffd5, $5505, $0555, $0c00, $03c0, $0007, $3f00, $5500, $0003
word    $5000, $5000, $d000, $0000, $7050, $0001, $0000, $3f05, $0507, $0500, $0700, $00ff, $0005, $00f3, $0500, $0000
word    $5000, $5000, $d000, $0030, $7050, $3c00, $0000, $0f05, $0d07, $0500, $f700, $003c, $0005, $000d, $0500, $0000
word    $5000, $5000, $f000, $00f0, $f050, $dc00, $f000, $c3f5, $0d0f, $0700, $0700, $000f, $0005, $5555, $5505, $03d5
word    $5000, $5000, $f000, $0c50, $c050, $5000, $fc00, $00ff, $0d03, $0f00, $0500, $0000, $3005, $c3d4, $5407, $00ff
word    $0010, $0000, $0000, $0fc0, $0000, $0000, $fff0, $03ff, $0000, $0000, $000f, $0000, $3f00, $0000, $0000, $0000
word    $0000, $0000, $0000, $00c0, $0000, $f000, $0fff, $0000, $0000, $c000, $003f, $0000, $0fc0, $00c0, $0000, $3c30
word    $0000, $0000, $c000, $00ff, $f000, $ffff, $000f, $0000, $0030, $fffc, $000f, $0000, $33f0, $0000, $0000, $0fff
word    $0000, $0000, $ff00, $000f, $fc00, $3ffc, $0003, $0000, $0000, $fcff, $0000, $0000, $000f, $0000, $f000, $003f
word    $3000, $0300, $ffc0, $0003, $cfc0, $0fff, $0000, $0030, $0000, $03ff, $0000, $f3f0, $f00f, $f003, $fc03, $000f
word    $0000, $0000, $c3ff, $0000, $fffc, $003f, $00c0, $0000, $fc00, $003f, $00c0, $ffff, $0300, $0550, $ffc0, $0000
word    $0000, $c000, $c03f, $0000, $3fff, $0000, $0000, $0c00, $f3f0, $3000, $c003, $cff3, $0000, $0f55, $3fcc, $0000
word    $0000, $ffc3, $000f, $ff00, $0cf0, $0c0c, $0000, $0000, $000f, $0000, $3c00, $0c30, $40c0, $f0d5, $03c0, $0c00
word    $3000, $3ff0, $ff00, $3f33, $0cff, $3f3f, $033c, $0000, $0000, $0000, $0000, $00f0, $50f3, $fcf5, $0c33, $0000
word    $0030, $3fff, $0000, $0000, $cffc, $000f, $0000, $0000, $ffff, $f003, $f03f, $07ff, $5400, $ff3d, $f03f, $300f
word    $00f3, $0000, $fffc, $03ff, $c000, $0000, $fffc, $ffff, $d555, $557f, $ffff, $f575, $5505, $fc0d, $f0ff, $00ff
word    $0fff, $5f00, $5fd5, $fdd5, $000f, $0000, $ffff, $5557, $5555, $5555, $ffd5, $5557, $5545, $014d, $000f, $03f0
word    $c0ff, $555f, $5555, $f555, $0fff, $0f3c, $fc00, $5d5f, $5555, $5555, $5555, $0015, $5540, $0005, $0550, $0f05
word    $7c03, $5555, $5555, $5555, $0555, $c300, $c003, $5fff, $555f, $5555, $5555, $5545, $5571, $5551, $4555, $ff10
word    $5f00, $5555, $5555, $5555, $5555, $0f05, $3d5c, $7ffc, $5557, $5555, $5555, $5551, $5571, $5551, $1155, $fc40
word    $57f3, $1555, $5400, $5555, $5555, $7c3f, $70f5, $fc01, $7fff, $5555, $5555, $5551, $5571, $5551, $1101, $fc40
word    $55ff, $0155, $0000, $5555, $5555, $5035, $cc1f, $0055, $77ff, $555d, $5555, $1571, $0000, $1500, $1100, $fc40
word    $555f, $0055, $0000, $5555, $5555, $50f5, $55f0, $1540, $fff0, $5d5d, $5555, $1571, $0071, $5500, $13ff, $fc40
word    $5557, $f015, $000f, $5554, $d555, $c3f5, $fffd, $f7fd, $ffc1, $5d7f, $5555, $ffc5, $0043, $ff01, $403f, $ff10
word    $5577, $5145, $0151, $5554, $5555, $cfdd, $77c3, $fc37, $fc17, $ff77, $5557, $ffc5, $0043, $ff01, $010f, $ff05
word    $5555, $4551, $0554, $5550, $5555, $4fdd, $d7f7, $3f57, $01d5, $5d7f, $555f, $0015, $5540, $0005, $0000, $ffc3
word    $5555, $0411, $0504, $5550, $d555, $cfdd, $57cd, $0155, $57f7, $fff0, $57ff, $5555, $5540, $5505, $5105, $fc0f
word    $5555, $0411, $c504, $1550, $d500, $4fff, $170d, $0000, $0000, $ff04, $55ff, $1555, $5040, $5045, $5005, $c3f5
word    $5555, $c411, $c504, $0150, $5500, $43ff, $01cd, $5554, $5555, $f014, $77d7, $4555, $4145, $4515, $5101, $3f55
word    $5555, $4551, $c554, $0054, $fd50, $543f, $4400, $0154, $5500, $0551, $7fdf, $5155, $15c5, $1510, $5104, $f555
word    $5555, $53c5, $13f1, $4055, $fd55, $d543, $454f, $f154, $013f, $1540, $5dfc, $515f, $5715, $5515, $5005, $d555
word    $5555, $5415, $3405, $5055, $3f5f, $0554, $5150, $3154, $0400, $5415, $5fc0, $535f, $5c55, $5455, $5555, $5555
word    $5555, $1155, $4d54, $d005, $03ff, $f555, $5153, $415c, $5155, $d140, $fc17, $517f, $5c55, $5155, $5555, $5555
word    $5555, $c555, $53ff, $0050, $5000, $7f55, $5454, $415c, $0455, $4400, $00ff, $f3c0, $7155, $4555, $5555, $5555
word    $1555, $1540, $0000, $c3d5, $5555, $f0fd, $545c, $055c, $0455, $4400, $fd55, $f3c7, $c17d, $1555, $5554, $5555
word    $5755, $0015, $3f3f, $30ff, $0000, $0000, $551c, $055c, $0117, $1000, $f555, $fc15, $05ff, $5557, $5554, $5555
word    $5f5d, $1575, $3f3f, $c403, $5555, $3555, $5533, $c55c, $013c, $1000, $0000, $4054, $1ff0, $55c0, $d501, $77f5
word    $dffd, $3f7d, $0000, $0550, $0000, $0000, $55cc, $c55c, $04c3, $c400, $d555, $0003, $3f00, $5005, $d545, $7ffd
word    $ff7f, $00ff, $0000, $47f5, $5555, $5555, $ffc1, $c7fc, $043f, $0400, $0003, $1550, $0054, $00ff, $f550, $7ffd
word    $ffdf, $5400, $4000, $457d, $5555, $5555, $000d, $3f00, $5000, $1140, $5570, $5555, $0543, $c000, $ffff, $7fff
word    $03fd, $0554, $00c0, $c557, $ffff, $5557, $ffcd, $00fc, $0000, $0015, $55c4, $5555, $143d, $1455, $ff00, $ffff
word    $5000, $d555, $ffff, $057f, $0000, $fffc, $fc0f, $fffc, $ffff, $3fc0, $ffc5, $00ff, $3c00, $5455, $0015, $ffff
word    $5554, $557f, $5555, $455d, $5555, $0001, $c000, $fff0, $ffff, $03ff, $0004, $5500, $33f5, $547f, $1555, $f000
word    $d555, $d555, $f55f, $45ff, $5555, $5555, $c035, $ffc0, $ffff, $00ff, $55c4, $5555, $1155, $00f0, $5555, $0055
word    $7fff, $ffd5, $5f55, $717d, $5555, $5555, $0035, $ff30, $ffff, $0000, $55cc, $5555, $5155, $57ff, $5555, $5555
word    $55d5, $557d, $d5ff, $71f7, $5555, $5555, $0035, $cfc0, $c003, $000f, $55cc, $5555, $4555, $5fff, $dfd5, $557f
word    $f555, $d557, $755f, $715f, $5555, $5555, $0335, $0000, $0000, $c000, $573f, $5555, $4555, $57d5, $757f, $7ff5
word    $7575, $ff55, $0155, $f154, $ffff, $5557, $3f35, $0000, $0000, $0300, $ff3f, $ffff, $4fff, $5555, $5555, $7d55
word    $543d, $5fdd, $3555, $0154, $0000, $fffc, $f30f, $ffff, $ffff, $f003, $ff30, $03ff, $4000, $5d55, $0155, $5554
word    $5507, $5575, $5f55, $3555, $0000, $0000, $f300, $3ff3, $c0ff, $003f, $0000, $0000, $5400, $fd55, $0fff, $5554
word    $5507, $555f, $57f5, $1555, $0000, $0000, $f3f0, $3ff3, $0fff, $00ff, $00f3, $5400, $5455, $7d55, $d555, $555f
word    $f555, $5557, $555f, $37d5, $5554, $1555, $ffcc, $fff3, $3fff, $0ffc, $5000, $0155, $5400, $d555, $ffff, $5555
word    $7fd5, $0015, $5555, $f5f5, $0000, $0000, $fffc, $3ff0, $ffff, $fffc, $00c0, $fc00, $5503, $5555, $5555, $5555
word    $55fd, $0035, $5555, $f55f, $fffc, $003f, $fdfc, $f540, $d5ff, $fff0, $fc03, $0003, $fd54, $ffff, $5555, $5555
word    $555d, $500d, $d555, $c557, $0000, $0000, $5d5f, $5400, $5557, $d5fd, $0003, $5554, $5555, $4015, $ffff, $5557
word    $5555, $5405, $7555, $5555, $5555, $5555, $5d57, $5400, $5557, $5555, $5555, $5555, $5555, $0155, $5555, $5555

}}





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
