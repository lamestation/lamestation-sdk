{{
JukeBox - a LameStation Music Player
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}



CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
  
    SONGCOUNT = 5
    SONGPOS = 38
    SONGWINDOW = 3

OBJ
    lcd       : "LameLCD" 
    gfx       : "LameGFX" 
    audio     : "LameAudio"
    ctrl      : "LameControl"

    font      : "font4x6"
    juke      : "gfx_jukebox"

    song_last : "song_lastboss.spin"
    song_pixl : "song_pixeltheme.spin"
    song_tank : "song_tankbattle.spin"
    song_town : "song_townhall.spin"
    song_zero : "song_zeroforce.spin"

VAR

    long    songs[SONGCOUNT]    ' song.Addr returns LONG, not WORD
    word    songnames[SONGCOUNT]

    byte    slide
    byte    songoffset
    byte    songchoice
    byte    songplaying
    byte    songinc
    byte    joymoved
    byte    buttonpressed
    byte    character[2]


PUB JukeBox

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, " ", 4, 6)
    
    ctrl.Start
    audio.Start
 
    character[1] := 0

    songnames[0] := @zero_name
    songnames[1] := @tank_name
    songnames[2] := @pixl_name
    songnames[3] := @town_name
    songnames[4] := @last_name
    
    songs[0] := song_zero.Addr
    songs[1] := song_tank.Addr
    songs[2] := song_pixl.Addr
    songs[3] := song_town.Addr
    songs[4] := song_last.Addr


    repeat
        
        lcd.DrawScreen

        ctrl.Update
        gfx.Blit(juke.Addr)
        
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
                
                
        if songchoice > constant(SONGWINDOW-1)
            songoffset := songchoice - constant(SONGWINDOW-1)
        else
            songoffset := 0
                                  
DAT

tank_name   byte    "Tank Danger",0
zero_name   byte    "Into Infinity",0
pixl_name   byte    "Intensity",0
town_name   byte    "Midday Affair",0
last_name   byte    "Enter Darkness",0

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
