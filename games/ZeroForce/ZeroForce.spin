{{
Zero Force - Action Shoot-Em-Up Game!
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
    
    BULLETS = 10
    
    PLAYERSPEED = 2
    BULLSPEED = 8

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
    
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    
    FP_OFFSET = 3

    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    TOTALBUFFER_BYTES = SCREENSIZE_BYTES
        

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    audio   :               "LameAudio"
    ctrl    :               "LameControl"

VAR
    word    prebuffer[TOTALBUFFER_BYTES/2]
    word    screen
    
    byte    choice
    byte    menuchoice
    byte    clicked           
    byte    joyclicked

    
    long    xoffset
    
    byte    blinkon
    word    blinkcount
    byte    blinkstate
    byte    collided
    byte    bosshealth
    
    long    x

    
PUB Main

    dira~
    screen := lcd.Start
    gfx.Start(@prebuffer)

    audio.Start

    gfx.ClearScreen
    gfx.TranslateBuffer(@prebuffer, screen)

    clicked := 0
    'StaticScreen
    'LogoScreen
    
    repeat
        'TitleScreen
        LevelStage
        BossStage


PUB StaticScreen

    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 127, 127, 127) 
    audio.LoadSong(@staticSong)
    audio.PlaySong
    
    repeat x from 0 to 50
        gfx.TranslateBuffer(@prebuffer, screen)
        gfx.Static
        
    audio.StopSong


PUB LogoScreen

    gfx.ClearScreen
    gfx.TranslateBuffer(@prebuffer, screen)
    
    repeat x from 0 to 100000
    
    gfx.ClearScreen 
    gfx.Sprite(@gfx_logo_teamlame, 0, 24, 0)
    gfx.TranslateBuffer(@prebuffer, screen)

    audio.SetWaveform(3, 127)
    audio.SetADSR(127, 10, 0, 10)
    audio.PlaySequence(@logoScreenSound)  

    repeat x from 0 to 120000 

    audio.StopSong


PUB TitleScreen

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 100, 40, 100) 
    audio.LoadSong(@titleScreenSong)
    audio.PlaySong

    choice := 1
    repeat until choice == 0  
        gfx.TranslateBuffer(@prebuffer, screen)

        gfx.Blit(@gfx_zeroforcelogo)
        ctrl.Update

        if ctrl.A or ctrl.B
              if clicked == 0
                choice := 0
                clicked := 1
        else
              clicked := 0
              
              
    audio.StopSong
    

   
' *********************************************************
'  Enemies
' *********************************************************
CON
    ENEMIES = 16

VAR           
  
    byte    enemyindex
    byte    enemycount
    byte    nextenemy
    byte    enemyon[ENEMIES]    
    long    enemyx[ENEMIES]
    long    enemyy[ENEMIES] 
    byte    enemyhealth[ENEMIES]
    word    enemyspeed[ENEMIES] 
    
    word    enemygraphics[3]
    byte    enemytypespeed[3]
    byte    enemytypeacceleration[3]
    
    word    currentenemies
    word    currentenemiestmp
    word    currentenemiesoffset


PUB InitEnemies
    enemygraphics[0] := @gfx_spacetank
    enemygraphics[1] := @gfx_krakken
    enemygraphics[2] := @gfx_blackhole

    enemytypespeed[0] := 6
    enemytypespeed[1] := 3
    enemytypespeed[2] := 2
    
    currentenemiesoffset := 0
    enemycount := 0
    
    repeat enemyindex from 0 to constant(ENEMIES-1)
        enemyon[enemyindex] := 0
        enemyx[enemyindex] := 0
        enemyy[enemyindex] := 0
        
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            enemyx[enemyindex] -= enemytypespeed[enemyon[enemyindex]-1]
            if enemyx[enemyindex] => -(24 << FP_OFFSET)
                gfx.Sprite(enemygraphics[enemyon[enemyindex]-1], enemyx[enemyindex] >> FP_OFFSET, enemyy[enemyindex] >> FP_OFFSET, 0)
            else
                enemyon[enemyindex] := 0
                enemycount--


PUB SpawnEnemy(dx, dy, type)
    if enemycount < ENEMIES-1
        enemyon[nextenemy] := type
        enemyx[nextenemy] := dx << FP_OFFSET
        enemyy[nextenemy] := dy << FP_OFFSET
        enemyhealth[nextenemy] := 1
        
        nextenemy++
        if nextenemy => ENEMIES
            nextenemy := 0
            
        enemycount++
        
        
PUB CreateFixedEnemies
        currentenemies := word[@level1][currentenemiesoffset]
        currentenemiestmp := currentenemies
        repeat x from 0 to 5
            currentenemiestmp := currentenemies & $3
            if currentenemiestmp > 0
                SpawnEnemy(SCREEN_W,x << 3,currentenemiestmp)
            currentenemies >>= 2
            
            
PUB CreateRandomEnemies | ran
    ran := cnt
    
    currentenemies := ran? & ran?
    repeat x from 0 to 7
        currentenemiestmp := currentenemies & $3
        if currentenemiestmp > 0
            SpawnEnemy(SCREEN_W,x << 3,currentenemiestmp)    
        currentenemies >>= 2







' *********************************************************
'  Player
' *********************************************************
VAR
    long    playerx
    long    playery


PUB InitPlayer
    playerx := 3
    playery := 3


PUB HandlePlayer

        ctrl.Update      
        
        if ctrl.Left
             playerx -= PLAYERSPEED
             if playerx < 0
                playerx := 0
        if ctrl.Right
            playerx += PLAYERSPEED
             if playerx  > 14 << 3
                playerx := 14 << 3

                      
        'UP AND DOWN   
        if ctrl.Up
             playery -= PLAYERSPEED
             if playery < 0
                playery := 0
        if ctrl.Down
             playery += PLAYERSPEED
             if playery > 6 << 3
                playery := 6 << 3

               
        if ctrl.A or ctrl.B
            bullettiming++
            if bullettiming > 2
                SpawnBullet(playerx + 8,playery + 7)                
                bullettiming := 0
        else
            bullettiming := 0
            
        gfx.Sprite(@gfx_zeroforce, playerx, playery, 0)             
        

    
' *********************************************************
'  Bullets
' *********************************************************
VAR
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    long    bulleton[BULLETS]
    long    bulletspeed[BULLETS]
    long    bulletindex
    long    nextbullet
    long    bullettiming
    
    
PUB InitBullets
    nextbullet := 0
    repeat bulletindex from 0 to constant(BULLETS-1)
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletspeed[bulletindex] := 0
        

PUB SpawnBullet(dx, dy)
    bulleton[nextbullet] := 1
    bulletx[nextbullet] := dx
    bullety[nextbullet] := dy    
    bulletspeed[nextbullet] := BULLSPEED
    
    nextbullet++
    if nextbullet => BULLETS
        nextbullet := 0

PUB HandleBullets

    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]
            bulletx[bulletindex] += bulletspeed[bulletindex]
            if bulletx[bulletindex] => SCREEN_W
                bulleton[bulletindex] := 0
            else
                gfx.Sprite(@gfx_laser, bulletx[bulletindex], bullety[bulletindex], 0)
   

    

    

        


PUB InitLevel
    InitBoss
    InitPlayer
    InitBullets
    InitEnemies
    






PUB LevelStage
    
    InitLevel
    
    choice := 1
    repeat until not choice
        gfx.TranslateBuffer(@prebuffer, screen)    
        gfx.ClearScreen
       

        HandlePlayer                        
                        
     '   CreateFixedEnemies
        currentenemiesoffset++
        if currentenemiesoffset > 100
            CreateRandomEnemies
            currentenemiesoffset := 0

            
        HandleEnemies                
                       
        HandleBullets


' *********************************************************
'  Boss
' *********************************************************
VAR
    byte bosshand1_x
    byte bosshand1_y


    
PUB InitBoss
    blinkon := 0
    blinkcount := 0
    bosshealth := 10

PUB HandleBoss

{{
    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]
            collided := 1
            if bulletx[bulletindex] < 8
                collided := 0
            if bosshealth > 0
                if collided == 1
                    bulleton[bulletindex] := 0
                    blinkon := 1
                  
                    bosshealth--
}}

        
    gfx.Sprite(@gfx_vortex_hand, 72,24, 0)
    gfx.Sprite(@gfx_vortex, 64,0, 0)        
    gfx.Sprite(@gfx_vortex_hand, 96,32, 0)   



PUB BossStage

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 100, 40, 100) 
    audio.LoadSong(@lastBossSong)
    audio.PlaySong
    
    InitLevel
    
    choice := 1
    
    repeat until not choice

        gfx.TranslateBuffer(@prebuffer, screen)
        
        gfx.ClearScreen
        
        gfx.Sprite(@gfx_planet, 20,48, 0)
        
        
        HandleBoss
     


  
        HandlePlayer   
        HandleBullets
        
          
        
    audio.StopSong
        
        



' *********************************************************
'  Data
' *********************************************************
DAT


gfx_ball
word    256  'frameboost
word    32, 32   'width, height

word    $5555, $0555, $5540, $5555, $5555, $0015, $5003, $5555, $5555, $0c00, $0f33, $5554, $1555, $f300, $c3ff, $5550
word    $0555, $7fcc, $f5dd, $5543, $0155, $57f0, $5d55, $5503, $c055, $55fc, $5555, $543f, $0c15, $757f, $5555, $50f5
word    $c005, $55dd, $5555, $43f7, $f005, $555f, $5555, $43d5, $f005, $5557, $5555, $4f55, $f0c1, $555f, $5555, $0375
word    $fc01, $5557, $5555, $0f55, $7cc1, $555f, $5555, $0755, $fc00, $5557, $5555, $0fd5, $fc30, $5555, $5555, $0f55
word    $ff00, $5557, $5555, $3d55, $dc00, $557f, $5555, $0fd5, $ff00, $55df, $5555, $0f75, $f001, $557d, $5555, $33d5
word    $f0c1, $55df, $7555, $0fff, $fc01, $77ff, $5555, $03f7, $f005, $ff7f, $f5d5, $40fd, $0005, $ffff, $f77f, $4c3f
word    $c005, $f7fc, $f7fd, $403f, $0015, $fff3, $fff7, $50c3, $0055, $ffc3, $ffff, $5400, $0155, $f0c0, $c3ff, $5503
word    $0555, $3c00, $3030, $5540, $1555, $0000, $c00c, $5550, $5555, $0000, $0000, $5554, $5555, $0015, $5000, $5555


gfx_blackhole
word    144  'frameboost
word    24, 24   'width, height

word    $aaaa, $aaaa, $aaaa, $ff5a, $aaaa, $a5fa, $eaa5, $aaaf, $9abf, $aaa9, $ffff, $9aab, $daa9, $0003, $9aa7, $5aa9
word    $5001, $a6b5, $4ea6, $5405, $a5c1, $cf96, $1f17, $a900, $435a, $0d03, $ab50, $056a, $0000, $ab14, $15aa, $5000
word    $ab01, $57aa, $5500, $ab00, $f7aa, $5f55, $ab00, $d3aa, $17d7, $ab00, $53aa, $05d7, $af00, $d3ea, $0755, $bfc0
word    $55fe, $1555, $faf0, $1d6d, $5537, $dab5, $fd55, $d437, $6aa5, $b5a5, $d7f7, $6a57, $a5aa, $deb6, $55aa, $a5aa
word    $9e96, $aaaa, $a6aa, $9696, $aaaa, $aaaa, $aaaa, $aaaa


gfx_krakken
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $af5f, $aaaa, $aaaa, $4114, $aaab, $57aa, $5104, $aab0, $757a, $d7f5, $aa14, $c0de, $7555, $af0d, $c006
word    $5555, $c575, $4047, $555d, $d1d7, $500d, $57d5, $1755, $557d, $dd75, $4545, $5d55, $555f, $5545, $d57f, $1554
word    $0dcd, $ff02, $1554, $0305, $3556, $1554, $a80c, $000a, $555d, $aa8c, $2aaa, $75dd, $aaa8, $aaaa, $01d0, $aaaa


gfx_laser
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $d557, $bffe, $aaaa, $aaaa, $d557, $bffe, $aaaa


gfx_moon
word    256  'frameboost
word    32, 32   'width, height

word    $aaaa, $0aaa, $aa80, $aaaa, $aaaa, $002a, $a003, $aaaa, $aaaa, $0c00, $0f33, $aaa8, $2aaa, $f300, $c3ff, $aaa0
word    $0aaa, $7fcc, $f5dd, $aa83, $02aa, $5700, $5d55, $aa03, $c0aa, $55c0, $5555, $a83f, $0c2a, $357c, $3f55, $a0f5
word    $000a, $f5d0, $d557, $83f4, $f00a, $c15f, $555f, $83d3, $f00a, $c557, $d543, $8f5d, $c0c2, $d55f, $5557, $037d
word    $c002, $5557, $5555, $0f75, $4cc2, $555f, $5555, $0755, $fc00, $555f, $5555, $0fd5, $fc30, $57fd, $f555, $0f55
word    $ff00, $5770, $f555, $3d57, $dc00, $5f73, $c155, $0fd0, $5f00, $5dcf, $1555, $0f75, $7002, $7f3d, $5555, $33d4
word    $f0c2, $5cd5, $7555, $0fff, $c002, $ff55, $555f, $03f4, $000a, $3d7f, $51fc, $80fc, $000a, $d57f, $17ff, $8c3c
word    $c00a, $55fc, $0ffd, $803f, $002a, $55f3, $f3f5, $a0c3, $00aa, $ffc3, $ffff, $a800, $02aa, $f0c0, $c3ff, $aa03
word    $0aaa, $3c00, $3030, $aa80, $2aaa, $0000, $c00c, $aaa0, $aaaa, $0000, $0000, $aaa8, $aaaa, $002a, $a000, $aaaa


gfx_planet
word    192  'frameboost
word    48, 16   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $eaaa
word    $553f, $fcd5, $aaa9, $aaaa, $aaaa, $57aa, $1555, $0040, $aaf4, $aaaa, $aaaa, $fc7e, $0000, $0fff, $bd00, $aaaa
word    $eaaa, $c0f3, $0f3f, $0000, $c000, $aaab, $7eaa, $c001, $4fff, $5ffd, $00f7, $aabc, $17aa, $3ffc, $543c, $7c3d
word    $03f5, $aad4, $fdea, $ffff, $ffff, $53ff, $3015, $ab40, $ff7a, $d40f, $1555, $ffc0, $3fdf, $ad00, $f41e, $5555
word    $fd55, $ffff, $30ff, $b400, $c3de, $550f, $f575, $ffff, $5557, $9000, $5503, $5555, $55d5, $fff5, $555f, $50f5


gfx_rocket
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $aaaa, $5aaa, $aaaa, $aaaa, $d5aa, $5555, $aaa9, $bd56, $5555, $6aa1, $abd5, $ffff, $568f, $abff, $ffff
word    $f54f, $aaff, $ffff, $554f, $a955, $ffff, $0fcf, $a000, $ffff, $000f, $ffff, $ffff, $0fcf, $ac00, $ffff, $5543
word    $a955, $0000, $d580, $aaff, $0000, $5aa0, $abfd, $0000, $aaa8, $abd5, $aaaa, $aaaa, $ad5a, $aaaa, $aaaa, $95aa


gfx_spacetank
word    32  'frameboost
word    16, 8   'width, height

word    $aaaa, $a002, $0ffa, $83fc, $c0aa, $8d57, $3000, $f511, $503c, $1555, $d7f3, $055f, $0000, $03f0, $00aa, $a000


gfx_vortex_hand
word    144  'frameboost
word    24, 24   'width, height

word    $002a, $a000, $a00a, $ffca, $83ff, $8d40, $55f2, $0f55, $87c0, $0070, $0d00, $0f05, $ff00, $00ff, $3c3d, $5540
word    $0155, $307f, $5570, $0d55, $3057, $55f0, $0f55, $0155, $ffc0, $03ff, $0fd5, $0c00, $0000, $03d5, $5fc0, $03d5
word    $00f5, $5570, $0d55, $30ff, $5570, $0d55, $003f, $55f0, $0f55, $0c3c, $5ff0, $0ff5, $0f3c, $ffc0, $03ff, $0d70
word    $0000, $0000, $035c, $55c0, $0d55, $83d7, $57f0, $0f55, $a0fc, $ffc0, $03ff, $a80c, $0000, $0000, $aa00, $fc02
word    $003f, $aaa0, $002a, $8000, $aaaa, $00aa, $a000, $aaaa


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


gfx_zeroforce
word    64  'frameboost
word    16, 16   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $aa95, $aaaa, $aa70, $aaaa, $9742, $aaaa, $01c2, $aaa4, $0dc2, $aa41, $7702, $a900
word    $7002, $5555, $fff3, $7fff, $055c, $00cf, $157c, $aa00, $95f0, $aaaa, $57c2, $a401, $fc2a, $aaa5, $02aa, $aaa0





gfx_logo_teamlame
word    512  'frameboost
word    128, 16   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $5555, $5545, $0155, $0054, $0015, $0015, $0050, $0000, $0054, $0015, $5515, $4555, $1145, $0000
word    $0000, $0000, $0500, $0140, $0000, $0054, $0015, $0015, $0050, $0000, $0054, $0015, $0515, $0000, $4441, $0000
word    $0000, $0000, $0500, $0140, $0000, $0145, $4055, $0015, $0050, $0000, $0145, $4055, $0515, $0000, $4441, $0000
word    $0000, $0000, $0500, $5500, $0155, $0145, $4055, $0015, $0050, $0000, $0145, $4055, $5415, $0555, $0000, $0000
word    $0000, $0000, $0500, $0140, $4000, $0501, $5155, $0015, $0050, $4000, $0501, $5155, $0515, $0000, $0000, $0000
word    $0000, $0000, $0500, $0140, $4000, $0501, $5145, $0014, $0050, $4000, $0501, $5145, $0514, $0000, $0000, $0000
word    $0000, $0000, $0500, $0140, $5000, $1400, $5545, $0014, $0050, $5000, $1400, $5545, $0514, $0000, $0000, $0000
word    $0000, $0000, $0500, $5500, $5555, $5400, $1505, $0014, $5540, $5455, $5400, $1505, $5414, $0555, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000





gfx_zeroforcelogo
word    2048  'frameboost
word    128, 64   'width, height

word    $5d55, $5575, $5d55, $7d55, $5555, $d555, $5555, $555d, $55d5, $5555, $d555, $d5ff, $5557, $5555, $5555, $5555
word    $5d55, $5575, $557d, $fd55, $5555, $5555, $5dd7, $5555, $55d5, $5555, $f555, $557f, $555d, $5555, $5555, $5555
word    $5d55, $55d5, $5755, $fd55, $5557, $5555, $5d57, $5557, $5755, $5555, $fdd5, $557f, $5575, $5555, $5555, $5555
word    $5d55, $55d5, $5575, $f555, $555f, $5555, $d55d, $5555, $5d55, $5555, $ff55, $555f, $55d5, $5555, $5555, $5555
word    $5d55, $55d5, $5575, $f555, $555f, $5555, $d555, $5575, $5d55, $5555, $ffdd, $555f, $5f55, $5555, $5555, $5555
word    $7555, $55d5, $55d5, $f555, $557f, $5555, $5555, $5555, $7555, $5555, $ffd5, $5557, $7555, $5555, $5555, $5555
word    $7555, $55d5, $d555, $d557, $57ff, $5555, $5555, $5555, $5555, $5557, $fff5, $5557, $d555, $5555, $5555, $5555
word    $7555, $55d5, $5555, $d555, $5fff, $5555, $5555, $5555, $5555, $5555, $fffd, $5557, $5555, $5557, $5555, $5555
word    $7555, $5755, $d5d5, $5555, $5fff, $5555, $ff75, $577f, $5555, $d555, $fffd, $5555, $5555, $555d, $5555, $5555
word    $7555, $5755, $5d55, $5557, $7fff, $5555, $fdff, $7dff, $5555, $5555, $ffff, $5555, $5555, $55f5, $5555, $5555
word    $7555, $5755, $5555, $5555, $7ffd, $d557, $f7ff, $f7ff, $5555, $7555, $ffff, $5555, $5555, $5755, $5555, $5555
word    $7555, $5755, $5555, $5555, $fff5, $d55d, $f7ff, $f7ff, $557f, $5555, $7fff, $5555, $5555, $5d55, $5555, $5555
word    $d555, $5755, $5555, $5555, $fff7, $5557, $dfff, $dfff, $55ff, $dd55, $7fff, $5555, $5555, $7555, $5555, $5555
word    $d555, $5d55, $5555, $5555, $ffd5, $555f, $dfff, $7fff, $55ff, $d555, $5fff, $5555, $5555, $7555, $5555, $5555
word    $d555, $5d55, $5555, $5555, $fff5, $557f, $7ffd, $ffff, $55fd, $f75d, $5fff, $5555, $5555, $d555, $5555, $5555
word    $d555, $5d55, $5555, $5555, $ffd5, $55ff, $7ff5, $ffff, $57f7, $fd55, $5fff, $55df, $5555, $5555, $5557, $5555
word    $d555, $5d55, $5555, $5555, $ffd5, $77ff, $7fd5, $ffff, $5fdf, $fd75, $7d7f, $5d77, $5555, $5555, $555d, $5555
word    $d555, $7555, $5555, $5555, $ff55, $5fff, $7f55, $ffff, $7f7f, $ffd5, $d57f, $ffff, $5555, $5555, $5575, $5555
word    $d555, $5555, $5555, $7555, $ff55, $ffff, $7f57, $ffff, $7dff, $ff75, $f55f, $ffff, $5555, $5555, $55d5, $5555
word    $d555, $5555, $5555, $dd55, $ff57, $ffff, $7f55, $ffff, $f77f, $ff55, $7557, $ffff, $557f, $5555, $55d5, $5555
word    $d555, $5555, $5555, $fd55, $f557, $ffff, $7f55, $ffff, $5fff, $7d5f, $5555, $ffff, $57ff, $5555, $5755, $5555
word    $d555, $5555, $5555, $f555, $d55f, $ffff, $7f55, $ffff, $7fff, $557d, $5555, $ffff, $ffff, $5555, $5d55, $5555
word    $d555, $5555, $5555, $f555, $555f, $5fff, $5f55, $ffff, $ffff, $57f7, $575d, $ffff, $ffff, $555f, $7555, $5555
word    $ff55, $7fff, $fffd, $fd5f, $57ff, $ffff, $dfff, $ffff, $ffff, $ffd7, $577f, $ffff, $ffff, $5fff, $fffd, $555f
word    $0355, $0000, $000d, $0d40, $5000, $03fd, $d7c0, $3fff, $0000, $03ff, $5fc0, $0003, $fffc, $4003, $000d, $5540
word    $0155, $0000, $000f, $0d40, $4000, $00fd, $f700, $3fff, $0000, $00ff, $5f00, $0003, $3ff0, $0000, $000d, $5540
word    $5555, $00f5, $fc0d, $0dd5, $03fc, $503d, $fc0f, $35ff, $7550, $d03d, $5c0f, $f703, $0f40, $3ff0, $540d, $5555
word    $5555, $403d, $fc0d, $0dd7, $03fc, $f00d, $f00f, $357f, $5550, $500f, $500f, $d503, $0340, $fff4, $540f, $5555
word    $5555, $700f, $fc0f, $0dd7, $03f4, $fc0f, $f03f, $3557, $fff0, $7c0d, $503f, $fd03, $0340, $ff55, $fc0f, $5557
word    $d555, $dc03, $000f, $0df0, $00fc, $fc0f, $f03f, $3557, $0000, $fc0f, $503d, $3f03, $0340, $f555, $000f, $5550
word    $f555, $d700, $000f, $0df0, $c000, $fc0f, $f03f, $3555, $0000, $f40d, $703d, $0003, $0350, $5555, $000f, $5550
word    $3d55, $f740, $fc0f, $0dff, $c000, $fc0f, $703f, $355d, $5550, $f40d, $503f, $0003, $0350, $5555, $540d, $5555
word    $0f55, $fd70, $fc0f, $0fff, $00d4, $f00f, $f00f, $357d, $5550, $d005, $700f, $3503, $0140, $7d54, $7c0d, $5555
word    $0355, $fffc, $fc0f, $0fff, $0354, $f03f, $fc0f, $37d5, $d550, $f01f, $7c0f, $d503, $0540, $3ff0, $fc0d, $555f
word    $0355, $0000, $000f, $0f40, $0354, $00dc, $7f00, $3d55, $7f50, $00f5, $7f00, $5503, $1500, $0000, $000d, $5540
word    $0155, $0000, $000f, $05c0, $0554, $03d0, $7fc0, $3555, $55f0, $0355, $7f40, $5501, $5401, $4001, $0005, $5540
word    $5555, $fff7, $ffff, $5557, $d555, $ffff, $7ff7, $5555, $557f, $7555, $5dfd, $5555, $5555, $5555, $5555, $5555
word    $d555, $fffd, $57ff, $5555, $5555, $ffdd, $7ff7, $5555, $555f, $d555, $7dfd, $5555, $5555, $5555, $5555, $5555
word    $d555, $fffd, $555f, $5555, $5555, $fffd, $7ff7, $d55d, $5575, $f555, $77f5, $5555, $5555, $5555, $5555, $5555
word    $7555, $ffff, $5557, $5555, $5555, $f7d5, $7ff7, $f55d, $5575, $7555, $77f7, $7555, $5555, $5555, $5555, $5555
word    $7555, $7fff, $5555, $5555, $5555, $ffd5, $7ff7, $5d5d, $57d5, $7555, $5ff5, $5555, $5557, $5555, $5555, $5555
word    $dd55, $d5ff, $5555, $5555, $5555, $f555, $7ff7, $575d, $55f5, $f555, $5fd5, $5555, $5555, $5555, $5555, $5555
word    $d555, $55ff, $5555, $5555, $5555, $5555, $fff7, $57d5, $55dd, $f555, $7fd5, $5555, $5555, $5555, $5555, $5555
word    $f755, $557f, $5555, $5555, $5555, $7555, $ffdf, $55d5, $5755, $f555, $5fd5, $5555, $5555, $5555, $5555, $5555
word    $f755, $557f, $5555, $5555, $5555, $d555, $ffdf, $5575, $5755, $5d55, $7fd7, $5555, $5555, $5555, $5555, $5555
word    $fdd5, $5557, $5555, $5555, $5555, $5500, $7fd7, $5557, $5755, $5d51, $4fd7, $5555, $5555, $5555, $5555, $5555
word    $7dd5, $5555, $5555, $5555, $5555, $5454, $ffdd, $5557, $5d55, $5d51, $4fd7, $5555, $5555, $5555, $5555, $5555
word    $7f55, $555d, $5555, $5555, $5557, $0454, $3034, $0040, $0055, $0140, $0004, $5555, $5555, $5555, $5555, $5555
word    $5775, $5557, $5555, $5555, $555d, $4500, $3005, $f07c, $5055, $0151, $4fc4, $5555, $5555, $5555, $5555, $5555
word    $5775, $5575, $5555, $5555, $5555, $4554, $ff45, $05c3, $0d55, $5151, $4dc4, $5555, $5555, $5555, $5555, $5555
word    $df75, $5555, $5555, $5555, $5555, $4554, $3015, $00c0, $0055, $0141, $0f44, $5555, $5555, $5555, $5555, $5555
word    $77dd, $5557, $5555, $5555, $5555, $5555, $d555, $7fff, $7555, $5d55, $57f5, $5555, $5555, $5555, $5555, $5555
word    $57d5, $5555, $5555, $5555, $5555, $5555, $5555, $ffff, $7555, $5d55, $5dfd, $5555, $5555, $5555, $5555, $5555
word    $55d5, $5555, $5555, $5555, $5555, $5555, $5555, $ffd5, $755f, $5555, $55ff, $5555, $5555, $5555, $5555, $5555
word    $55d5, $5555, $5555, $5555, $5555, $5555, $5555, $f755, $55ff, $f555, $557f, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $fd55, $ffff, $f7ff, $555f, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $fffd, $5fdf, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $ff77, $ffdf, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $f7f5, $7fdf, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5557, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555









level1
'' how this works
'' 3 types of enemies, 8 y positions, 0 is no enemy
'' so each word is a row of enemies
'' thank you propeller spin for having quaternary number support
'' that's perfect for this

word %%0010_1010
word %%0002_0002
word %%0002_0002
word %%0002_0002
word %%0002_0002
word %%0002_0002
word %%0002_0002
word %%0003_0000

word %%3333_3333 ' End level symbol









logoScreenSound
byte    NOTEON,0,72
byte    TIMEWAIT,8

byte    NOTEON,1,70
byte    TIMEWAIT,8

byte    NOTEON,2,68
byte    TIMEWAIT,8

byte    NOTEON,3,63
byte    TIMEWAIT,8

byte    NOTEON,4,51
byte    TIMEWAIT,7
byte    NOTEON,5,75
byte    TIMEWAIT,6
byte    NOTEON,6,87
byte    TIMEWAIT,5

byte    ENDOFSONG








staticSong
byte    1
byte    200
byte    1

byte    0,36

byte    0,BAROFF
byte    SONGOFF







titleScreenSong
byte    18     'number of bars
byte    30    'tempo
byte    8       ' meter/4

'MAIN SECTION
'0-5
byte    0,36,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,51,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,56,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,63,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'6
byte    0,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'7-10
byte    0,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,60,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,53,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,65,SOFF,65,SOFF,63

'11-12
byte    0,SNOP,SNOP,SNOP,44,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,68,SNOP,SOFF,SNOP,SNOP

'13-14
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,SOFF,SNOP
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,27,SNOP

byte    0,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP


'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    4,BAROFF
byte    5,BAROFF

byte    6,BAROFF

byte    7,8,9,10,BAROFF
byte    11,12,BAROFF
byte    7,8,9,10,BAROFF
byte    11,12,BAROFF

byte    10,13,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    10,13,17,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    SONGOFF






lastBossSong

byte    4     'number of bars
byte    30    'tempo
byte    12     'notes/bar

'MAIN SECTION
'0-5
byte    0,45,41,40,45,41,40,45,41,40,45,41,40
byte    0,46,43,42,46,43,42,46,43,42,46,43,42

byte    1,26,SNOP,SNOP,29,SNOP,SNOP,28,SNOP,SNOP,29,SNOP,SNOP
byte    1,25,SNOP,SNOP,26,SNOP,SNOP,27,SNOP,SNOP,21,SNOP,SNOP


'SONG ------

byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
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
