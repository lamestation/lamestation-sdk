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
        

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    audio   :               "LameAudio"
    ctrl    :               "LameControl"

VAR

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
    gfx.Start(lcd.Start)

    audio.Start

    gfx.ClearScreen
    lcd.SwitchFrame

    clicked := 0
'    StaticScreen
'    LogoScreen
    
    repeat
   '     TitleScreen
   '     LevelStage
        BossStage


PUB StaticScreen

    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 127, 127, 127) 
    audio.LoadSong(@staticSong)
    audio.PlaySong
    
    repeat x from 0 to 20
        lcd.SwitchFrame
        gfx.Static
        
    audio.StopSong


PUB LogoScreen


    

    gfx.ClearScreen
    lcd.SwitchFrame
    
    repeat x from 0 to 100000
    
    gfx.ClearScreen
    gfx.SpriteTrans(@teamlamelogo, 0, 3, 0)
    lcd.SwitchFrame

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
 '   repeat
        lcd.SwitchFrame

        gfx.Blit(@gfx_zeroforcelogo)
        ctrl.Update

        if ctrl.Any
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
                gfx.Sprite(@gfx_laser, bulletx[bulletindex] >> 3, bullety[bulletindex] >> 3, 0, 0)
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            enemyx[enemyindex] -= enemyspeed[enemyindex]
            if enemyx[enemyindex] => 0
                gfx.Sprite(enemygraphics[enemyon[enemyindex]], enemyx[enemyindex] >> 4, enemyy[enemyindex] >> 4, 0, 0)
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

               
        if ctrl.Any
            bullettiming++
            if bullettiming > 30
                SpawnBullet(playerx >> 3 + 2,playery >> 3 + 1)                
                bullettiming := 0
            
        gfx.Sprite(@gfx_zeroforce, playerx >> 3, playery >> 3, 0, 0)             
        


PUB SpawnBullet(dx, dy)
    bulleton[nextbullet] := 1
    bulletx[nextbullet] := dx << 3
    bullety[nextbullet] := dy << 3    
    bulletspeed[nextbullet] := 1
    
    nextbullet++
    if nextbullet => BULLETS
        nextbullet := 0

PUB SpawnEnemy(dx, dy, type)
    enemyon[nextenemy] := type
    enemyx[nextenemy] := dx << 4
    enemyy[nextenemy] := dy << 4    
    enemyspeed[nextenemy] := 1
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
        lcd.SwitchFrame    
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
        lcd.SwitchFrame    
        gfx.ClearScreen
        
     '   gfx.Sprite(@gfx_planet, 5,6, 0, 0)
        
        HandlePlayer
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

        if bosshealth > 0   
            if blinkon
    
                blinkstate := blinkcount / 20 // 2
                
                if not blinkstate
                    blinkcount++
                else
                    blinkcount += 5
                    gfx.Sprite(@gfx_vortex, 8, 0, 0, 0)  
                    
                    
                if blinkcount > 100
                    blinkcount := 0
                    blinkon := 0
                              
            else
                gfx.Sprite(@gfx_vortex, 8, 0, 0, 0)
                gfx.Sprite(@gfx_vortex_hand, 12, 3, 0, 0)
        else
            gfx.Sprite(@gfx_blackhole, 11, 4, 0, 0)  
            
            gfx.TextBox(string("THIS IS THE END"), 3, 2)
            gfx.TextBox(string("Or is it?"),6,4)
            
            lcd.SwitchFrame
            repeat x from 0 to 600000
            choice := 0
  
        
        HandleBullets
        
        
        
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






teamlamelogo
word    $200  'frameboost
word    $10, $2   'width, height
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $18, $10, $18, $10, $18, $10, $18, $10, $F8, $0, $F8, $0, $18, $10, $18, $10, $18, $10, $18, $10, $0, $0, $F8, $40, $F8, $0, $D8, $90, $D8, $90, $D8, $90
byte    $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $0, $0, $0, $0, $80, $0, $E0, $0, $F8, $80, $38, $20, $F8, $80, $E0, $0, $80, $0, $0, $0, $0, $0
byte    $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0, $F8, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $80, $0
byte    $E0, $0, $F8, $80, $38, $20, $F8, $80, $E0, $0, $80, $0, $0, $0, $0, $0, $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0
byte    $F8, $0, $F8, $0, $F8, $0, $0, $0, $F8, $40, $F8, $0, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $0, $0, $18, $10
byte    $78, $40, $18, $10, $0, $0, $78, $40, $18, $10, $70, $40, $18, $10, $70, $40, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $F, $8, $F, $8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8
byte    $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $E, $8, $F, $8, $3, $2, $0, $0, $0, $0, $0, $0, $3, $2, $F, $8, $E, $8, $C, $8
byte    $F, $8, $F, $8, $1, $1, $7, $4, $F, $8, $E, $8, $F, $8, $7, $4, $1, $1, $F, $8, $F, $8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $0, $0, $C, $8, $E, $8, $F, $8
byte    $3, $2, $0, $0, $0, $0, $0, $0, $3, $2, $F, $8, $E, $8, $C, $8, $F, $8, $F, $8, $1, $1, $7, $4, $F, $8, $E, $8, $F, $8, $7, $4
byte    $1, $1, $F, $8, $F, $8, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0




gfx_zeroforcelogo
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1F, $FF, $E0, $FF, $0, $FF, $0, $FF, $0, $FF, $3, $FF, $FC, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $2, $FF, $1A, $FF, $20, $FF, $4, $FF, $1, $FF, $0, $FF, $40, $FF, $40, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $7, $FF, $3F, $FF, $FE
byte    $FF, $FC, $FF, $F8, $FF, $E0, $FF, $C0, $FF, $C0, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1
byte    $FF, $6, $FF, $8, $FF, $0, $FF, $2, $FF, $0, $FF, $6, $FF, $0, $FF, $18, $FF, $4, $FF, $1, $FF, $10, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $3, $FF, $4, $FF, $18, $FF, $20, $FF, $0, $FF, $40, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $90, $FF, $C0, $FF, $F4, $FF, $F8, $FF, $FC, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $1F, $FF, $7, $FF, $1, $FF, $0, $FF, $0, $FF, $0, $FF, $1
byte    $FF, $1, $FF, $2, $FF, $4, $FF, $8, $FF, $10, $FF, $10, $FF, $20, $FF, $40, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $F, $FF, $F0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1F, $FF, $E0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $0, $FF, $2, $FF, $0, $FF, $1, $FF, $2, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $13, $FF, $7, $FF, $5F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $F8, $FF, $F4, $FF, $E8, $FF, $C0, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $C
byte    $FF, $3E, $FF, $7E, $FF, $FF, $FF, $FE, $FF, $FD, $FF, $F3, $FF, $CF, $FF, $3F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FD, $FF, $F2, $FF, $EE, $FF, $DC
byte    $FF, $B8, $FF, $78, $FF, $F8, $FF, $F0, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $40, $FF, $0, $FF, $0, $FF, $40, $FF, $90, $FF, $C4, $FF, $F1
byte    $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $1F, $FF, $7, $FF, $80, $FF, $80, $FF, $0, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $2, $FF, $2, $FF, $4, $FF, $8, $FF, $30, $FF, $40
byte    $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $80, $FF, $80, $FF, $80, $FF, $FF, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $81, $FF, $82, $FF, $0
byte    $FF, $0, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $98, $FF, $F4, $FF, $F8
byte    $FF, $F8, $FF, $E0, $FF, $80, $FF, $81, $FF, $8F, $FF, $F, $FF, $1F, $FF, $3F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $BD, $FF, $BC
byte    $FF, $84, $FF, $80, $FF, $80, $FF, $81, $FF, $FF, $FF, $FF, $FF, $3F, $FF, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
byte    $FF, $FF, $FF, $FF, $FF, $FE, $FF, $F5, $FF, $FB, $FF, $F7, $FF, $EE, $FF, $C8, $FF, $D0, $FF, $30, $FF, $65, $FF, $C2, $FF, $CE, $FF, $9F, $FF, $9F, $FF, $8F
byte    $FF, $8F, $FF, $C7, $FF, $83, $FF, $0, $FF, $C0, $FF, $1, $FF, $D, $FF, $6, $FF, $FF, $FF, $FE, $FF, $FF, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FE, $FF, $FE
byte    $FF, $F8, $FF, $F8, $FF, $F8, $FF, $F0, $FF, $F0, $FF, $E0, $FF, $E0, $FF, $E0, $FF, $C0, $FF, $C0, $FF, $80, $FF, $80, $FF, $80, $FF, $80, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $81, $FF, $82, $FF, $8C, $FF, $90, $FF, $A0, $FF, $C0, $FF, $80, $FF, $80, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $1, $FC, $80, $FC, $C0, $7C, $60, $3C, $30, $1C, $18, $C, $C, $84, $4, $C0, $C0, $E0, $20, $F0, $90, $F8, $E0
byte    $FF, $F2, $FF, $FF, $0, $0, $0, $0, $0, $0, $9C, $9C, $9C, $9C, $9C, $9C, $9C, $98, $9C, $80, $FC, $E0, $FF, $FC, $FF, $0, $FF, $FF, $0, $0, $0, $0
byte    $0, $0, $3C, $2C, $3C, $3C, $3C, $3C, $1C, $1C, $0, $0, $1, $0, $C3, $C0, $FF, $F0, $FF, $FF, $7, $7, $3, $3, $1, $1, $F0, $F0, $FC, $F8, $FC, $F8
byte    $FC, $FC, $FC, $FC, $F0, $F0, $1, $1, $3, $3, $7, $4, $FF, $FE, $FF, $7F, $FF, $3F, $FF, $8F, $FF, $F, $FF, $7, $FF, $3, $FF, $3, $FF, $FF, $0, $0
byte    $0, $0, $0, $0, $9C, $10, $9C, $10, $9C, $10, $9C, $10, $9C, $14, $9C, $10, $FF, $2B, $FF, $FF, $7, $7, $3, $3, $1, $1, $F0, $30, $FC, $F0, $FC, $E4
byte    $FC, $9C, $FC, $FC, $F0, $F0, $1, $1, $3, $3, $7, $7, $FF, $40, $FF, $0, $FF, $FF, $0, $0, $0, $0, $0, $0, $3C, $24, $3C, $30, $3C, $34, $1C, $1C
byte    $0, $0, $1, $1, $C3, $3, $FF, $3, $FF, $FF, $7, $7, $3, $3, $1, $1, $F1, $1, $F8, $0, $FC, $C, $FC, $C, $FC, $1C, $FC, $1C, $FC, $3C, $F9, $38
byte    $FF, $78, $FF, $FF, $0, $0, $0, $0, $0, $0, $9C, $10, $9C, $10, $9C, $10, $9C, $10, $9C, $0, $FC, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $7, $F1, $1, $F0, $80, $F0, $60, $F0, $90, $F2, $E2, $F3, $F3, $F3, $F2, $F3, $F2, $F3, $F3, $F3, $F3, $F3, $F3
byte    $FF, $FF, $FF, $7F, $F0, $30, $F0, $30, $F0, $30, $F3, $13, $F3, $13, $F3, $13, $F3, $13, $F3, $3, $F3, $3, $FF, $B, $FF, $7, $FF, $7, $F0, $0, $F0, $0
byte    $F0, $0, $FF, $0, $FF, $0, $FF, $1, $FE, $6, $F8, $0, $F0, $0, $F0, $10, $F3, $13, $F7, $77, $FE, $52, $FC, $FC, $F8, $F8, $F0, $70, $F3, $F3, $F3, $F3
byte    $F3, $F3, $F3, $3, $F0, $F0, $F8, $F8, $FC, $FC, $FE, $FE, $FF, $FF, $FF, $3, $FF, $0, $FF, $C1, $FF, $1, $FF, $2, $FF, $2, $FF, $4, $FF, $8F, $F0, $C0
byte    $F0, $30, $F0, $30, $FF, $D8, $FF, $8, $FF, $4, $FF, $4, $FF, $4, $FF, $2, $FF, $2, $FF, $2, $FE, $4, $FC, $4, $F8, $8, $F0, $0, $F3, $D2, $F3, $63
byte    $F3, $83, $F3, $33, $F0, $F0, $F8, $F0, $FC, $CC, $FE, $3E, $FF, $EF, $FF, $0, $FF, $7, $F0, $0, $F0, $0, $F0, $0, $FF, $0, $FF, $0, $FF, $81, $FE, $2
byte    $F8, $0, $F0, $0, $F0, $0, $F3, $0, $F7, $0, $FE, $0, $FC, $0, $F8, $0, $F8, $0, $F1, $0, $F3, $2, $F3, $2, $F3, $2, $F3, $3, $F3, $3, $F9, $0
byte    $FF, $0, $FF, $7, $F0, $0, $F0, $0, $F0, $0, $F3, $3, $F3, $3, $F3, $2, $F3, $2, $F3, $2, $F3, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $60, $FF, $98, $FF, $E2, $FF, $F9, $FF, $3E, $FF, $3F, $FF, $9F, $FF, $1F, $FF, $7, $FF, $1, $FF, $1, $FF, $1, $FF, $2
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $1F, $0, $DF, $0, $DF, $0, $DF, $1, $3F, $1, $FF, $1, $7F, $B, $7F, $13
byte    $7F, $3F, $FF, $58, $FF, $87, $7F, $7F, $7F, $7F, $7F, $7F, $FF, $FF, $7F, $5C, $7F, $60, $7F, $3, $7F, $10, $FF, $C, $7F, $6, $7F, $1, $7F, $0, $7F, $0
byte    $FF, $0, $FF, $4, $FF, $2, $FF, $7, $7F, $39, $7F, $40, $7F, $0, $7F, $0, $7F, $0, $1F, $0, $7F, $0, $FF, $0, $FF, $0, $7F, $70, $7F, $F, $7F, $E
byte    $7F, $70, $FF, $0, $7F, $1, $7F, $7F, $7F, $7F, $7F, $7F, $1F, $14, $7F, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $1, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $8, $FF, $7, $FF, $78, $FF, $1F, $FF, $4, $FF, $8, $FF, $4, $FF, $9, $FF, $0, $FF, $2, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $1, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $F8, $0, $FE, $0, $FE, $0, $FE, $0, $FF, $0, $FF, $0, $F8, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FC, $0, $FA, $0, $FA, $2, $FA, $2, $FF, $7, $FA, $A, $FA, $1A, $F9, $19, $F9, $19, $FF, $3E, $FA, $78, $FA, $B8, $F9, $F9, $F9, $F1
byte    $FF, $E0, $FF, $E0, $FF, $C0, $FF, $C0, $FA, $80, $FA, $82, $F9, $B8, $F9, $80, $FF, $80, $F8, $80, $FB, $80, $FF, $80, $FF, $80, $F8, $18, $FA, $C0, $FA, $C0
byte    $F8, $E0, $FF, $F0, $F8, $78, $FF, $3B, $FF, $D, $FF, $17, $F8, $0, $FB, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $2, $FF, $1, $FF, $7, $FF, $5, $FF, $7, $FF, $3, $FF, $7, $FF, $7, $FF, $F, $FF, $7, $FF, $0, $FF, $7, $FF, $7, $FF, $7, $FF, $6, $FF, $2
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0







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
