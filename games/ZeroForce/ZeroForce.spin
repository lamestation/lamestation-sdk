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
                          
    SCREEN_BW = 16   
    SCREEN_BH = 8
    
    BULLETS = 10
    ENEMIES = 10
    
    PLAYERSPEED = 1
    BULLSPEED = 2
    ENEMSPEED = 1

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
    FRAMES = 1

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
    
    long    playerx
    long    playery

    long    enemyindex
    long    nextenemy
    long    enemyon[ENEMIES]    
    long    enemyx[ENEMIES]
    long    enemyy[ENEMIES]
    long    enemyspeed[BULLETS]    
    byte    enemyhealth[ENEMIES]
    
    word    enemygraphics[3]
    
    word    currentenemies
    word    currentenemiestmp
    word    currentenemiesoffset
    
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    long    bulleton[BULLETS]
    long    bulletspeed[BULLETS]
    long    bulletindex
    long    nextbullet
    long    bullettiming
    
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
    StaticScreen
    'LogoScreen
    
    repeat
        'TitleScreen
        'LevelStage
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
    gfx.Sprite(@gfx_logo_teamlame, 0, 24, 0, 0, 0)
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
  '  repeat
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
    



PUB InitLevel

    playerx := 3
    playery := 3
    
    enemygraphics[0] := @gfx_krakken
    enemygraphics[1] := @gfx_spacetank
    enemygraphics[2] := @gfx_blackhole
    
    currentenemiesoffset := 0
    
    repeat enemyindex from 0 to constant(ENEMIES-1)
        enemyon[enemyindex] := 0
        enemyx[enemyindex] := 0
        enemyy[enemyindex] := 0
        enemyspeed[enemyindex] := 0
        
    
    nextbullet := 0
    blinkon := 0
    blinkcount := 0
    
    bosshealth := 10

    repeat bulletindex from 0 to constant(BULLETS-1)
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletspeed[bulletindex] := 0
    
    
PUB HandleBullets

    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]
            bulletx[bulletindex] += bulletspeed[bulletindex]
            if bulletx[bulletindex] => SCREEN_BW << 3
                bulleton[bulletindex] := 0
            else
                gfx.Sprite(@gfx_laser, bulletx[bulletindex] >> 3, bullety[bulletindex] >> 3, 0, 1, 0)
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            enemyx[enemyindex] -= enemyspeed[enemyindex]
            if enemyx[enemyindex] => 0
                gfx.Sprite(enemygraphics[enemyon[enemyindex]], enemyx[enemyindex] >> 4, enemyy[enemyindex] >> 4, 0, 1, 0)
            else
                enemyon[enemyindex] := 0

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
            if bullettiming > 30
                SpawnBullet(playerx >> 3 + 2,playery >> 3 + 1)                
                bullettiming := 0
            
        gfx.Sprite(@gfx_zeroforce, playerx >> 3, playery >> 3, 0, 1, 0)             
        


PUB SpawnBullet(dx, dy)
    bulleton[nextbullet] := 1
    bulletx[nextbullet] := dx << 3
    bullety[nextbullet] := dy << 3    
    bulletspeed[nextbullet] := BULLSPEED
    
    nextbullet++
    if nextbullet => BULLETS
        nextbullet := 0

PUB SpawnEnemy(dx, dy, type)
    enemyon[nextenemy] := type
    enemyx[nextenemy] := dx << 4
    enemyy[nextenemy] := dy << 4    
    enemyspeed[nextenemy] := ENEMSPEED
    enemyhealth[nextenemy] := 1
    
    nextenemy++
    if nextenemy => ENEMIES
        nextenemy := 0
        
        
PUB CreateFixedEnemies
        currentenemies := word[@level1][currentenemiesoffset]
        currentenemiestmp := currentenemies
        repeat x from 0 to 5
            currentenemiestmp := currentenemies & 3
            if currentenemiestmp > 0
                SpawnEnemy(13,x,currentenemiestmp-1)
            currentenemies >>= 2
            
            
PUB CreateRandomEnemies | ran
    ran := cnt
    
    currentenemies := ran?    
    repeat x from 1 to 6
        currentenemiestmp := currentenemies & 3
        if currentenemiestmp > 0 and currentenemiestmp < 3
            SpawnEnemy(14,x,currentenemiestmp-1)    
        currentenemies >>= 2

        
PUB LevelStage
    
    InitLevel
    
    choice := 1
    repeat until not choice
        gfx.TranslateBuffer(@prebuffer, screen)    
        gfx.ClearScreen
       
             
       
        
        HandlePlayer                        
                        
     '   CreateFixedEnemies
        currentenemiesoffset++
        if currentenemiesoffset > 700     
            CreateRandomEnemies
            currentenemiesoffset := 0

            
        HandleEnemies                
                       
        HandleBullets
        
        
        
        
    
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
        
        'gfx.Sprite(@gfx_planet, 5,6, 0, 0)
        

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


  
        'HandlePlayer   
        'HandleBullets
        
          
        
    audio.StopSong
        
        




DAT 'LEVEL DATA





gfx_zeroforce
word    $40  'frameboost
word    $2, $2   'width, height
byte    $4, $F3, $4, $3, $C, $B, $78, $67, $F0, $9F, $D0, $4F, $90, $8F, $80, $1F, $40, $1F, $20, $1F, $0, $3F, $40, $3F, $80, $7F, $0, $FF, $0, $FF, $0, $FF
byte    $2, $E3, $C, $CC, $1E, $DA, $3E, $B2, $3E, $A2, $7E, $42, $7B, $43, $63, $52, $67, $16, $47, $16, $3, $D2, $7, $D6, $3, $DA, $23, $DA, $3, $FA, $3, $F8

gfx_krakken
word    $60  'frameboost
word    $3, $2   'width, height
byte    $C0, $7F, $F0, $9F, $18, $F, $58, $17, $C, $7, $C, $3, $8C, $B, $FC, $33, $F9, $1, $FF, $41, $FB, $8, $F9, $88, $FF, $89, $F9, $1, $FC, $11, $FE, $9
byte    $F2, $43, $F8, $13, $EC, $27, $E0, $47, $F0, $9F, $B0, $1F, $C0, $1F, $60, $7F, $7, $FC, $17, $E5, $17, $C5, $17, $C0, $1F, $C8, $1F, $CA, $1F, $D8, $F, $8C
byte    $63, $2, $7F, $62, $FF, $1, $FF, $C0, $FF, $0, $7F, $1, $7F, $40, $63, $1, $F, $80, $3F, $F4, $0, $C0, $7, $E4, $F, $E8, $7, $F4, $2, $F0, $3, $F0

gfx_blackhole
word    $90  'frameboost
word    $3, $3   'width, height
byte    $3C, $C3, $C4, $3B, $82, $7D, $2, $FD, $82, $FF, $C2, $FF, $32, $F, $F6, $9F, $FC, $9F, $CC, $F, $88, $F, $8, $F, $88, $8F, $C8, $8F, $E8, $F, $68, $F, $7C, $1F, $34, $F, $26, $3F, $42, $7F, $C2, $3D, $62, $9D, $1C, $E3, $0, $FF
byte    $0, $FF, $0, $FF, $1, $FE, $83, $FC, $FF, $F9, $1E, $0, $FC, $10, $F9, $B0, $F1, $61, $F0, $0, $F0, $0, $F0, $60, $F9, $B0, $F9, $11, $3C, $0, $1C, $0, $4, $0, $2, $0, $3, $0, $81, $80, $FF, $FF, $C0, $FF, $80, $FF, $0, $FF
byte    $E, $F1, $F, $F3, $5, $FB, $7, $F9, $3F, $C0, $7F, $86, $F, $FC, $5, $FC, $F, $FE, $7F, $80, $7F, $9E, $9, $F8, $B, $F8, $7F, $B0, $7F, $80, $1E, $FC, $E, $F8, $E, $F0, $B, $F7, $9, $F7, $10, $EF, $10, $EF, $13, $ED, $1F, $E3


gfx_spacetank
word    $20  'frameboost
word    $2, $1   'width, height
byte    $20, $A7, $10, $97, $32, $B7, $22, $A7, $22, $23, $22, $3, $38, $9, $34, $25, $3C, $25, $36, $22, $7E, $42, $76, $42, $7E, $42, $3C, $4, $18, $89, $8, $8F


gfx_planet
word    $C0  'frameboost
word    $6, $2   'width, height
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $80, $FF, $80, $FF, $80, $7F, $40, $7F, $C0, $BF, $C0, $BF, $E0, $BF, $60, $3F, $60, $3F, $60, $3F, $40, $1F, $60, $1F, $60, $1F, $60, $1F, $20, $1F, $A0, $9F, $A0, $9F, $A0, $9F, $E0, $BF, $80, $9F, $A0, $BF, $20, $3F, $20, $3F, $20, $1F, $40, $3F, $40, $7F, $40, $7F, $80, $7F, $80, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF
byte    $80, $FF, $60, $7F, $70, $1F, $58, $4F, $DC, $57, $BE, $1B, $BE, $3B, $FB, $79, $FB, $59, $FC, $5C, $AD, $D, $AD, $D, $EC, $C, $FC, $C, $FC, $C, $FB, $1B, $FB, $B, $FF, $F, $FF, $4F, $FA, $8A, $FB, $B, $FF, $2B, $FC, $68, $EE, $68, $EE, $68, $EE, $6E, $EE, $EE, $FA, $FA, $FA, $FA, $F6, $F6, $FE, $F4, $FE, $F0, $FE, $F2, $FE, $B0, $FE, $26, $F6, $36, $D4, $14, $D0, $10, $F8, $38, $C1, $1, $81, $1, $86, $3, $86, $83, $8C, $87, $18, $F, $30, $1F, $E0, $3F, $80, $7F



gfx_vortex
word    $400  'frameboost
word    $8, $8   'width, height
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $7F, $0, $7F, $0, $7F, $0, $7F, $0, $7F, $0, $7F, $0, $7F, $0, $3F, $0, $3F, $0, $3F, $0, $1F, $20, $3F, $0, $F, $0, $7, $80, $83, $80, $81, $B8, $A1, $B8, $A1, $B8, $A1, $B0, $A1, $80, $81, $18, $11, $38, $21, $F8, $C1, $F8, $81, $38, $1, $C0, $1, $4, $5, $F4, $5, $4, $1, $FC, $1, $EC, $21, $DC, $C5, $9C, $85, $38, $1, $78, $9, $F0, $31, $E0, $E1, $0, $7, $0, $3F, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $EF, $0, $7, $30, $33, $38, $23, $7C, $45, $7E, $42, $FF, $81, $FF, $91, $FF, $11, $FF, $11, $FF, $1, $FF, $C1, $1F, $1, $DF, $0, $DF, $4, $DF, $4, $9F, $4, $3F, $0, $FF, $0, $FF, $20, $FF, $20, $FF, $0, $FF, $0, $FF, $84, $FF, $84, $FF, $C0, $FF, $E1, $FE, $F2, $FE, $FA, $7E, $7E, $3C, $3C, $99, $18, $C2, $0, $F1, $80, $7C, $0, $7F, $40, $9F, $10, $E7, $21, $F7, $7, $F3, $3, $F8, $80, $FD, $80, $FF, $C1, $7F, $4F, $7C, $7C, $78, $78, $70, $71, $70, $73
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $F3, $0, $0, $5C, $1C, $5E, $12, $1E, $12, $9E, $12, $FE, $2, $FC, $4, $79, $49, $A3, $A2, $DF, $DC, $3F, $38, $7F, $61, $FE, $C2, $F9, $F8, $C3, $C0, $1F, $0, $FE, $C0, $FD, $0, $FB, $0, $FB, $0, $F7, $6, $C7, $7, $CF, $F, $C7, $7, $C3, $3, $EB, $B, $E5, $5, $F0, $0, $7A, $2, $7D, $0, $3C, $0, $7E, $40, $7E, $40, $7F, $61, $7F, $78, $7F, $78, $7, $4, $F3, $D3, $FD, $5, $FD, $1, $FE, $0, $E2, $20, $82, $80, $1, $0, $0, $0, $0, $0, $1, $0
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $7F, $80, $8E, $C1, $C1, $4D, $4C, $6D, $60, $B5, $30, $DB, $18, $ED, $D, $F2, $2, $FD, $1, $FE, $C2, $FF, $E3, $3E, $3E, $9C, $9C, $C3, $C3, $3, $3, $F0, $B0, $FF, $8F, $FF, $0, $FF, $0, $7F, $0, $3F, $20, $1F, $10, $CF, $88, $A7, $80, $73, $40, $7B, $42, $39, $20, $90, $0, $A0, $A0, $C2, $0, $37, $34, $0, $0, $8A, $0, $E6, $22, $EF, $27, $EF, $23, $DF, $40, $D8, $40, $C3, $42, $8F, $8, $9F, $90, $9F, $90, $BF, $A0, $BF, $A1, $BE, $A0, $BE, $A2, $B8, $80
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1, $F9, $5, $E5, $1E, $1E, $3F, $3E, $FF, $F0, $7F, $60, $BF, $B0, $9F, $1C, $EF, $E, $F3, $83, $FD, $81, $FE, $C2, $7F, $61, $9F, $0, $8F, $F, $C0, $0, $BF, $3F, $9F, $91, $AF, $AE, $E9, $29, $5C, $40, $FC, $30, $19, $19, $6B, $9, $81, $1, $10, $10, $3C, $3C, $3F, $E, $7F, $3, $7F, $0, $3, $0, $3C, $3C, $FF, $C0, $FF, $C0, $FF, $80, $FF, $80, $3, $0, $38, $38, $7E, $70, $FF, $C0, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $0, $0, $3F, $38, $FF, $E0, $FF, $80
byte    $0, $C3, $78, $7B, $F8, $8B, $F8, $B, $F0, $13, $F0, $17, $F0, $17, $60, $27, $60, $27, $60, $2F, $60, $2F, $60, $2F, $60, $2F, $60, $2F, $E0, $27, $E0, $27, $E0, $23, $E0, $20, $E8, $28, $E8, $28, $6E, $6E, $F, $F, $E7, $E6, $F7, $F5, $FB, $7B, $FD, $3C, $DE, $9E, $FE, $E, $FE, $0, $CF, $0, $DF, $10, $FF, $38, $FF, $0, $FF, $4, $FF, $3D, $FF, $FF, $FF, $64, $BF, $80, $E, $0, $EF, $60, $EF, $60, $EF, $20, $FE, $30, $AE, $20, $EE, $20, $EE, $20, $EE, $20, $EE, $20, $EC, $20, $EC, $20, $EC, $20, $EC, $20, $EC, $20, $EC, $20, $FC, $0, $EC, $0, $EC, $80, $EC, $60, $FC, $F0, $EC, $20, $EC, $20, $FC, $F0, $F4, $F0, $F4, $F0
byte    $0, $FF, $0, $FE, $1, $FD, $7, $F6, $7, $E6, $F, $CE, $1F, $DC, $1D, $DC, $19, $98, $13, $10, $37, $30, $77, $70, $6F, $60, $7F, $40, $FF, $C0, $D3, $C0, $FB, $F8, $FD, $FC, $BF, $BE, $1F, $1F, $0, $0, $0, $0, $1, $1, $7F, $7F, $7F, $78, $FF, $C0, $FF, $D8, $1F, $1E, $1F, $17, $F, $A, $7, $1, $FF, $FF, $FF, $FC, $FF, $0, $FF, $E0, $7F, $7F, $6F, $60, $18, $18, $3, $3, $FF, $DE, $FF, $C0, $DC, $80, $FC, $3C, $0, $0, $F, $0, $BF, $30, $FF, $E0, $FF, $80, $FF, $20, $7F, $0, $1F, $0, $7, $0, $F, $0, $FF, $C0, $FF, $F8, $FF, $0, $7F, $7F, $7B, $30, $F, $F, $D, $C, $3, $3, $1, $1, $9, $9, $F, $F
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FE, $0, $FC, $0, $FC, $0, $FC, $0, $F0, $0, $C0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $3, $3, $6, $6, $0, $0, $0, $0, $0, $0, $3, $1, $7, $7, $7, $7, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $3, $3, $7, $7, $5, $4, $0, $0, $0, $0, $0, $0, $3, $3, $7, $7, $F, $6, $E, $C, $0, $0, $0, $0, $0, $0, $13, $3, $F, $F, $1, $1, $0, $0, $4, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0



gfx_vortex_hand
word    $90  'frameboost
word    $3, $3   'width, height
byte    $0, $7, $0, $3, $CC, $CD, $EE, $86, $F6, $12, $F6, $12, $F6, $12, $F6, $12, $F6, $12, $F6, $12, $F6, $12, $F6, $12, $EE, $86, $CC, $CC, $0, $1, $0, $3, $F8, $61, $F8, $31, $F0, $30, $E6, $4, $8E, $C, $1E, $1A, $70, $71, $0, $7
byte    $0, $0, $0, $0, $78, $78, $FD, $E5, $FD, $C5, $FF, $C7, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $C1, $FD, $C5, $FD, $E5, $78, $78, $0, $0, $0, $0, $1F, $18, $7F, $78, $FF, $FC, $8F, $F, $C3, $43, $E1, $E1, $8, $8, $0, $0
byte    $0, $E0, $0, $C0, $4, $C4, $E, $8E, $E, $C, $2E, $28, $2E, $28, $2E, $28, $2E, $28, $2E, $28, $2E, $28, $E, $8, $E, $C, $6, $6, $0, $80, $0, $C0, $2, $C2, $F, $CD, $7, $E4, $7, $E6, $3, $F3, $0, $F8, $0, $FC, $0, $FE




gfx_laser
word    $10  'frameboost
word    $1, $1   'width, height
byte    $22, $FF, $66, $DD, $66, $DD, $66, $DD, $66, $DD, $66, $DD, $66, $DD, $22, $FF






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
