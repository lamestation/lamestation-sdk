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
    
    SW1 = 1 << 24
    SW2 = 1 << 25
    SW3 = 1 << 26
    
    J_U = 1 << 12
    J_D = 1 << 13
    J_R = 1 << 14
    J_L = 1 << 15
    
    DIR_U = 2
    DIR_D = 3
    DIR_L = 0
    DIR_R = 1
    
    NL = 10

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
    gfx     :               "LameGFX"
    audio   :               "LameAudio"
    ctrl    :               "LameControl"

VAR

    long    controls
    long    x
    byte    choice
    byte    menuchoice
    byte    clicked           
    byte    joyclicked
    
    long    playerx
    long    playery
    
    long    enemyx
    long    enemyy    
    
    long    xoffset

PUB Main

    dira~
    gfx.Start

    audio.Start

    gfx.ClearScreen
    gfx.SwitchFrame

    clicked := 0
    LogoScreen
    TitleScreen 
    GameLoop



PUB LogoScreen

    gfx.ClearScreen
    gfx.SwitchFrame
    gfx.ClearScreen
    gfx.SpriteTrans(@teamlamelogo, 0, 3, 0)
    gfx.SwitchFrame

    audio.SetWaveform(3, 127)
    audio.SetADSR(127, 10, 0, 10)
    audio.PlaySequence(@logoScreenSound)  

    repeat x from 0 to 150000 

    audio.StopSong






PUB TitleScreen

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 100, 40, 100) 
    audio.LoadSong(@titleScreenSong)
    audio.PlaySong



    choice := 1
    repeat until choice == 0  
        controls := ina   
        gfx.SwitchFrame

        gfx.Blit(@gfx_zeroforcelogo)

        if controls & (SW1+SW2+SW3) <> 0
              if clicked == 0
                choice := 0
                clicked := 1


        else
              clicked := 0
              
              
'    audio.StopSong
    
    
    
    
    
PUB GameLoop

    gfx.ClearScreen
    
    playerx := 3
    playery := 3
    
    enemyx := 10
    enemyy := 3

    repeat
        gfx.SwitchFrame
        
        gfx.ClearScreen
        
        ctrl.Update      
        
        if ctrl.Left
             playerx--
             if playerx < 0
                playerx := 0
        if ctrl.Right
            playerx++
             if playerx > 14
                playerx := 14

                      
        'UP AND DOWN   
        if ctrl.Up
             playery--
             if playery < 0
                playery := 0
        if ctrl.Down
             playery++
             if playery > 6
                playery := 6

               
        if ctrl.A or ctrl.B or ctrl.Menu
             if clicked == 0
                  
                clicked := 1
             else
                clicked := 0

        gfx.SpriteTrans(@gfx_planet, 5, 6, 0)

        gfx.SpriteTrans(@gfx_zeroforce, playerx, playery, 0)
        gfx.SpriteTrans(@gfx_blackhole, enemyx, enemyy, 0)
        
        gfx.SpriteTrans(@gfx_spacetank, 6, 1, 0)
        gfx.SpriteTrans(@gfx_spacetank, 13, 6, 0)


        gfx.TextBox(string("There Is No Escape This Time... Only Fate"), 0, 0)





DAT 'LEVEL DATA





gfx_zeroforce
word    $40  'frameboost
word    $2, $2   'width, height
byte    $4, $F3, $4, $3, $C, $B, $78, $67, $F0, $9F, $D0, $4F, $90, $8F, $80, $1F, $40, $1F, $20, $1F, $0, $3F, $40, $3F, $80, $7F, $0, $FF, $0, $FF, $0, $FF
byte    $2, $E3, $C, $CC, $1E, $DA, $3E, $B2, $3E, $A2, $7E, $42, $7B, $43, $63, $52, $67, $16, $47, $16, $3, $D2, $7, $D6, $3, $DA, $23, $DA, $3, $FA, $3, $F8

gfx_krakken
word	$60  'frameboost
word	$3, $2   'width, height
byte	$C0, $7F, $F0, $9F, $18, $F, $58, $17, $C, $7, $C, $3, $8C, $B, $FC, $33, $F9, $1, $FF, $41, $FB, $8, $F9, $88, $FF, $89, $F9, $1, $FC, $11, $FE, $9
byte	$F2, $43, $F8, $13, $EC, $27, $E0, $47, $F0, $9F, $B0, $1F, $C0, $1F, $60, $7F, $7, $FC, $17, $E5, $17, $C5, $17, $C0, $1F, $C8, $1F, $CA, $1F, $D8, $F, $8C
byte	$63, $2, $7F, $62, $FF, $1, $FF, $C0, $FF, $0, $7F, $1, $7F, $40, $63, $1, $F, $80, $3F, $F4, $0, $C0, $7, $E4, $F, $E8, $7, $F4, $2, $F0, $3, $F0

gfx_blackhole
word	$90  'frameboost
word	$3, $3   'width, height
byte	$3C, $C3, $C4, $3B, $82, $7D, $2, $FD, $82, $FF, $C2, $FF, $32, $F, $F6, $9F, $FC, $9F, $CC, $F, $88, $F, $8, $F, $88, $8F, $C8, $8F, $E8, $F, $68, $F, $7C, $1F, $34, $F, $26, $3F, $42, $7F, $C2, $3D, $62, $9D, $1C, $E3, $0, $FF
byte	$0, $FF, $0, $FF, $1, $FE, $83, $FC, $FF, $F9, $1E, $0, $FC, $10, $F9, $B0, $F1, $61, $F0, $0, $F0, $0, $F0, $60, $F9, $B0, $F9, $11, $3C, $0, $1C, $0, $4, $0, $2, $0, $3, $0, $81, $80, $FF, $FF, $C0, $FF, $80, $FF, $0, $FF
byte	$E, $F1, $F, $F3, $5, $FB, $7, $F9, $3F, $C0, $7F, $86, $F, $FC, $5, $FC, $F, $FE, $7F, $80, $7F, $9E, $9, $F8, $B, $F8, $7F, $B0, $7F, $80, $1E, $FC, $E, $F8, $E, $F0, $B, $F7, $9, $F7, $10, $EF, $10, $EF, $13, $ED, $1F, $E3


gfx_spacetank
word	$20  'frameboost
word	$2, $1   'width, height
byte	$20, $A7, $10, $97, $32, $B7, $22, $A7, $22, $23, $22, $3, $38, $9, $34, $25, $3C, $25, $36, $22, $7E, $42, $76, $42, $7E, $42, $3C, $4, $18, $89, $8, $8F


gfx_planet
word	$C0  'frameboost
word	$6, $2   'width, height
byte	$0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $80, $FF, $80, $FF, $80, $7F, $40, $7F, $C0, $BF, $C0, $BF, $E0, $BF, $60, $3F, $60, $3F, $60, $3F, $40, $1F, $60, $1F, $60, $1F, $60, $1F, $20, $1F, $A0, $9F, $A0, $9F, $A0, $9F, $E0, $BF, $80, $9F, $A0, $BF, $20, $3F, $20, $3F, $20, $1F, $40, $3F, $40, $7F, $40, $7F, $80, $7F, $80, $FF, $80, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF
byte	$80, $FF, $60, $7F, $70, $1F, $58, $4F, $DC, $57, $BE, $1B, $BE, $3B, $FB, $79, $FB, $59, $FC, $5C, $AD, $D, $AD, $D, $EC, $C, $FC, $C, $FC, $C, $FB, $1B, $FB, $B, $FF, $F, $FF, $4F, $FA, $8A, $FB, $B, $FF, $2B, $FC, $68, $EE, $68, $EE, $68, $EE, $6E, $EE, $EE, $FA, $FA, $FA, $FA, $F6, $F6, $FE, $F4, $FE, $F0, $FE, $F2, $FE, $B0, $FE, $26, $F6, $36, $D4, $14, $D0, $10, $F8, $38, $C1, $1, $81, $1, $86, $3, $86, $83, $8C, $87, $18, $F, $30, $1F, $E0, $3F, $80, $7F




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
















titleScreenSong
byte    18     'number of bars
byte    30    'tempo

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
