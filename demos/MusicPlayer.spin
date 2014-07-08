{{
The Music Box - a LameStation jukebox
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}



CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
  
    SONGCOUNT = 4
    SONGPOS = 38
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

        font    :               "Font4x6"

        juke    :               "gfx_jukebox"


VAR


    word    songs[SONGCOUNT]
    word    songnames[SONGCOUNT]

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
    lcd.Start(gfx.Start)
    
    gfx.LoadFont(font.Addr, " ", 4, 6)
    
    ' Initialize the user controls
    ctrl.Start
    
    ' Initialize the audio system
    audio.Start
    audio.SetWaveform(0)
    audio.SetADSR(127, 100, 40, 100) 
    
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
        lcd.DrawScreen

        'Make sure to call update before attempting to check values
        ctrl.Update
        gfx.Blit(juke.Addr)
        
        'Put some awesome text on the screen
        gfx.TextBox(string("The Music Box"),0,0,64,32)
        gfx.TextBox(string("Up/dn: choose",10,"  A/B: select"), 74, 0,64,32)
        gfx.PutString(string("NOW:"), 22, 26)
        
        if audio.SongPlaying        
            gfx.PutString(songnames[songplaying], 40, 26)
        
        repeat songinc from 0 to constant(SONGWINDOW-1)
        
            if songinc+songoffset == songchoice
                gfx.PutString(string(">"), 30, SONGPOS+songinc<<3-1)
                
            gfx.PutChar("1" + songinc + songoffset, 35, SONGPOS+songinc<<3)
            gfx.PutString(songnames[songinc+songoffset], 40, SONGPOS+songinc<<3)
        
       
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
                    audio.LoopSong
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





tankbattle_theme
'' Header
'' ------

    byte    15     'number of bars
    byte    180    'tempo
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
byte    150     'tempo
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
byte    120    'tempo
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
byte    150    'tempo
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