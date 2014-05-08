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
  
    SONGCOUNT = 4
    SONGPOS = 40
    SONGWINDOW = 3

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


    word    songs[SONGCOUNT]   '' This array contains memory address, so we use data type word.    
    word    songnames[SONGCOUNT]   '' This array contains memory address, so we use data type word.

    word    buffer[1024]


    byte    slide
    byte    songoffset
    byte    songchoice
    byte    songplaying
    byte    songinc
    byte    joymoved
    byte    buttonpressed
    byte    character[2]


PUB MusicPlayer

    ' Initialize the video system
    gfx.Start(@buffer, lcd.Start)
    
    'gfx.LoadFont(@gfx_chars_cropped, " ", 8, 8)
    gfx.LoadFont(@gfx_4x4, " ", 4,4)
    
    ' Initialize the user controls
    ctrl.Start
    
    ' Initialize the audio system
    audio.Start
    audio.SetWaveform(0, 127)
    audio.SetADSR(127, 100, 40, 100) 


    songoffset := 0
    songchoice := 0
    songplaying := 0
    
    character[1] := 0

    songnames[0] := @zeroforce_name
    songnames[1] := @tankbattle_name
    songnames[2] := @pixel_name
    songnames[3] := @lastboss_name
    
    songs[0] := @zeroforce_theme
    songs[1] := @tankbattle_theme
    songs[2] := @pixel_theme
    songs[3] := @lastboss_theme
    
    

    repeat
        
        'To update the screen, you simply call switchFrame.
        gfx.DrawScreen

        'Make sure to call update before attempting to check values
        ctrl.Update
        gfx.ClearScreen
        
        'Put some awesome text on the screen
        gfx.PutString(string("-= The Music Box =-"),2,0)
        gfx.PutString(string("Press joystick up/down to"),8,8)
        gfx.PutString(string("choose, button to select"), 8, 16)
        gfx.PutString(string("Playing:"), 0, 32)
        
        if audio.SongPlaying        
            'gfx.PutString(songnames[songplaying], 40, 32)
        
        repeat songinc from 0 to constant(SONGWINDOW-1)
        
            if songinc+songoffset == songchoice
                gfx.PutString(string("->"), 0, SONGPOS+songinc<<3)
                
            gfx.PutChar("1" + songinc + songoffset, 16, SONGPOS+songinc<<3)
            gfx.PutString(songnames[songinc+songoffset], 32, SONGPOS+songinc<<3)
        
       
        ' Receive user input
        ' Added a little debouncing code to require one joy
        ' press for each menu entry.
        if ctrl.Up
            if not joymoved
                joymoved := 1          
                if songchoice > 0
                    songchoice--
                else
                    songchoice := 0
        elseif ctrl.Down
            if not joymoved
                joymoved := 1
                 songchoice++
                 if songchoice > constant(SONGCOUNT-1)
                    songchoice := constant(SONGCOUNT-1)
        else
            joymoved := 0
        
        ' If the player presses any button, act
        if ctrl.A or ctrl.B
            if not buttonpressed
                buttonpressed := 1
                if audio.SongPlaying and songplaying == songchoice
                    audio.StopSong
                else
                    songplaying := songchoice
                    audio.StopSong
                    audio.LoadSong(songs[songplaying])
                    audio.PlaySong
        else
            buttonpressed := 0
                
                
        ' Add scrolling to song menu for cool effect
        if songchoice > constant(SONGWINDOW-1)
            songoffset := songchoice - constant(SONGWINDOW-1)
        else
            songoffset := 0
                            
       



DAT



tankbattle_name             byte    "Tank Danger",0
zeroforce_name              byte    "Into Infinity",0
pixel_name                  byte    "Intensity",0
lastboss_name               byte    "Enter Darkness",0




gfx_4x4

word    $0400, $0400, $0000, $0400, $1515, $1515, $1105, $0000, $1511, $1100, $1500, $0000, $1505, $0115, $1515, $0000
word    $1104, $0405, $1115, $0000, $1505, $0511, $1505, $0000, $0404, $0414, $0015, $0000, $0515, $1105, $1501, $0000
word    $0410, $1004, $0410, $0000, $1511, $0415, $1511, $0000, $0415, $1515, $0404, $0000, $1110, $0511, $1115, $0000
word    $0000, $1500, $0004, $0004, $1501, $1501, $1115, $0000, $1000, $0400, $0104, $0000, $1505, $1111, $1511, $0000
word    $0505, $0411, $1514, $0000, $1515, $1115, $0501, $0000, $1505, $1404, $1514, $0000, $1415, $0405, $0511, $0000
word    $1414, $0415, $0510, $0000, $1115, $1104, $1504, $0000, $1501, $1015, $0415, $0000, $1111, $1511, $1504, $0000
word    $1504, $1515, $1015, $0000, $1111, $1504, $0411, $0000, $0400, $0004, $0404, $0100, $1405, $0404, $1414, $0000
word    $1510, $0004, $1510, $0000, $0501, $0404, $0510, $0000, $1504, $1410, $0004, $0400, $0004, $0011, $0000, $5500



gfx_chars_cropped

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0140, $0550, $0550, $0140, $0140, $0000, $0140, $0000
word    $1450, $1450, $1450, $0000, $0000, $0000, $0000, $0000, $1450, $1450, $5554, $1450, $5554, $1450, $1450, $0000
word    $0140, $1550, $0014, $0550, $1400, $0554, $0140, $0000, $0014, $1414, $0500, $0140, $0050, $1414, $1400, $0000
word    $0150, $1414, $1414, $5550, $1414, $1414, $5150, $0000, $0540, $0140, $0050, $0000, $0000, $0000, $0000, $0000
word    $0500, $0140, $0050, $0050, $0050, $0140, $0500, $0000, $0050, $0140, $0500, $0500, $0500, $0140, $0050, $0000
word    $0000, $1414, $0550, $5555, $0550, $1414, $0000, $0000, $0000, $0140, $0140, $1554, $0140, $0140, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0140, $0140, $0050, $0000, $0000, $0000, $1554, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0140, $0140, $0000, $0000, $1400, $0500, $0140, $0050, $0014, $0000, $0000
word    $0550, $1414, $1514, $1554, $1454, $1414, $0550, $0000, $0140, $0150, $0140, $0140, $0140, $0140, $1554, $0000
word    $0550, $1414, $1400, $0540, $0050, $1414, $1554, $0000, $0550, $1414, $1400, $0540, $1400, $1414, $0550, $0000
word    $1500, $1540, $1450, $1414, $5554, $1400, $5500, $0000, $1554, $0014, $0014, $0554, $1400, $1414, $0550, $0000
word    $0540, $0050, $0014, $0554, $1414, $1414, $0550, $0000, $1554, $1414, $1400, $0500, $0140, $0140, $0140, $0000
word    $0550, $1414, $1414, $0550, $1414, $1414, $0550, $0000, $0550, $1414, $1414, $1550, $1400, $0500, $0150, $0000
word    $0000, $0000, $0140, $0140, $0000, $0140, $0140, $0000, $0000, $0000, $0140, $0140, $0000, $0140, $0140, $0050
word    $0500, $0140, $0050, $0014, $0050, $0140, $0500, $0000, $0000, $0000, $1554, $0000, $1554, $0000, $0000, $0000
word    $0050, $0140, $0500, $1400, $0500, $0140, $0050, $0000, $0550, $1414, $1400, $0500, $0140, $0000, $0140, $0000
word    $0550, $1414, $1514, $1114, $1514, $0014, $0550, $0000, $0550, $1414, $1414, $1554, $1414, $1414, $1414, $0000
word    $0554, $1414, $1414, $0554, $1414, $1414, $0554, $0000, $0550, $1414, $0014, $0014, $0014, $1414, $0550, $0000
word    $0154, $0514, $1414, $1414, $1414, $0514, $0154, $0000, $1554, $0014, $0014, $0554, $0014, $0014, $1554, $0000
word    $1554, $0014, $0014, $0554, $0014, $0014, $0014, $0000, $0550, $1414, $0014, $1514, $1414, $1414, $0550, $0000
word    $1414, $1414, $1414, $1554, $1414, $1414, $1414, $0000, $0550, $0140, $0140, $0140, $0140, $0140, $0550, $0000
word    $1500, $1400, $1400, $1400, $1414, $1414, $0550, $0000, $1414, $1414, $0514, $0154, $0514, $1414, $1414, $0000
word    $0014, $0014, $0014, $0014, $0014, $0014, $1554, $0000, $5014, $5454, $5554, $5554, $5114, $5014, $5014, $0000
word    $1414, $1454, $1554, $1554, $1514, $1414, $1414, $0000, $0550, $1414, $1414, $1414, $1414, $1414, $0550, $0000
word    $0554, $1414, $1414, $0554, $0014, $0014, $0014, $0000, $0550, $1414, $1414, $1414, $1514, $0550, $1500, $0000
word    $0554, $1414, $1414, $0554, $0514, $1414, $1414, $0000, $0550, $1414, $0014, $0550, $1400, $1414, $0550, $0000
word    $1554, $0140, $0140, $0140, $0140, $0140, $0140, $0000, $1414, $1414, $1414, $1414, $1414, $1414, $0550, $0000
word    $1414, $1414, $1414, $1414, $1414, $0550, $0140, $0000, $5014, $5014, $5014, $5114, $5554, $5454, $5014, $0000
word    $1414, $1414, $0550, $0140, $0550, $1414, $1414, $0000, $1414, $1414, $1414, $0550, $0140, $0140, $0140, $0000
word    $1554, $1400, $0500, $0140, $0050, $0014, $1554, $0000, $1550, $0050, $0050, $0050, $0050, $0050, $1550, $0000
word    $0000, $0014, $0050, $0140, $0500, $1400, $0000, $0000, $1550, $1400, $1400, $1400, $1400, $1400, $1550, $0000
word    $0100, $0540, $1450, $5014, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5555, $0000
word    $0150, $0140, $0500, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0550, $1400, $1550, $1414, $1550, $0000
word    $0014, $0014, $0554, $1414, $1414, $1414, $0554, $0000, $0000, $0000, $0550, $1414, $0014, $1414, $0550, $0000
word    $1400, $1400, $1550, $1414, $1414, $1414, $1550, $0000, $0000, $0000, $0550, $1414, $1554, $0014, $0550, $0000
word    $1540, $0050, $0050, $0554, $0050, $0050, $0050, $0000, $0000, $0000, $1550, $1414, $1414, $1550, $1400, $0550
word    $0014, $0014, $0554, $1414, $1414, $1414, $1414, $0000, $0140, $0000, $0150, $0140, $0140, $0140, $0550, $0000
word    $0140, $0000, $0150, $0140, $0140, $0140, $0140, $0050, $0014, $0014, $1414, $0514, $0154, $0514, $1414, $0000
word    $0150, $0140, $0140, $0140, $0140, $0140, $0500, $0000, $0000, $0000, $1450, $5554, $5114, $5114, $5014, $0000
word    $0000, $0000, $0554, $1414, $1414, $1414, $1414, $0000, $0000, $0000, $0550, $1414, $1414, $1414, $0550, $0000
word    $0000, $0000, $0554, $1414, $1414, $0554, $0014, $0014, $0000, $0000, $1550, $1414, $1414, $1550, $1400, $5400
word    $0000, $0000, $0554, $1414, $0014, $0014, $0014, $0000, $0000, $0000, $1550, $0014, $0550, $1400, $0554, $0000
word    $0050, $0050, $0554, $0050, $0050, $0050, $0540, $0000, $0000, $0000, $1414, $1414, $1414, $1414, $1550, $0000
word    $0000, $0000, $1414, $1414, $1414, $0550, $0140, $0000, $0000, $0000, $5014, $5114, $5114, $5554, $1450, $0000
word    $0000, $0000, $1414, $0550, $0140, $0550, $1414, $0000, $0000, $0000, $1414, $1414, $1414, $1550, $1400, $0550
word    $0000, $0000, $1554, $0500, $0140, $0050, $1554, $0000, $0540, $0050, $0050, $0014, $0050, $0050, $0540, $0000
word    $0140, $0140, $0140, $0000, $0140, $0140, $0140, $0000, $0150, $0500, $0500, $1400, $0500, $0500, $0150, $0000
word    $0000, $0000, $5150, $1514, $0000, $0000, $0000, $0000, $0000, $0100, $0540, $1450, $5014, $5014, $5554, $0000








tankbattle_theme
'' Header
'' ------

    byte    15     'number of bars
    byte    28    'tempo
    byte    8       'bar resolution

'' Loop Definitions
'' ----------------

    'ROOT BASS

    byte    0, 36,SOFF,  36,SOFF,   34,  36,SOFF,  34
    byte    1, 24,SOFF,  24,SOFF,   22,  24,SOFF,  22

    'DOWN TO SAD

    byte    0, 32,SNOP,  32,SOFF,   31,  32,SOFF,  31
    byte    1, 20,SNOP,  20,SOFF,   19,  20,SOFF,  19

    'THEN FOURTH
    byte    0, 29,SNOP,  29,SOFF,   27,  29,SOFF,  27
    byte    1, 17,SNOP,  17,SOFF,   15,  17,SOFF,  15

    byte    2,   48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
    byte    2, SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
    byte    2,   53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
    byte    2, SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP 

    'melody
    byte    2,   48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
    byte    2, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF     

    'harmonies
    byte    3,   44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
    byte    3, SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
    byte    3, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF 
 
'' Song Definition
'' ---------------
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF
    'verse
    byte    0,1,6,BAROFF
    byte    0,1,7,BAROFF
    byte    0,1,8,BAROFF
    byte    0,1,9,BAROFF
    byte    2,3,10,12,BAROFF
    byte    2,3,13,BAROFF
    byte    4,5,BAROFF
    byte    4,5,11,14,BAROFF
    'verse
    byte    0,1,6,BAROFF
    byte    0,1,7,BAROFF
    byte    0,1,8,BAROFF
    byte    0,1,9,BAROFF
    byte    2,3,10,12,BAROFF
    byte    2,3,13,BAROFF
    byte    4,5,BAROFF
    byte    4,5,11,14,BAROFF

'' Footer
    byte    SONGOFF








zeroforce_theme
byte    18     'number of bars
byte    30     'tempo
byte    8      'bar resolution

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







pixel_theme
byte    14     'number of bars
byte    40    'tempo
byte    8    'bar resolution

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









lastboss_theme

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
