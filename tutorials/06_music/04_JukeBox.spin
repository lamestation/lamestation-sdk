CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    SONGCOUNT = 6
    SONGPOS = 38
    SONGWINDOW = 3

OBJ
    lcd       : "LameLCD"
    gfx       : "LameGFX"
    audio     : "LameAudio"
    music     : "LameMusic"
    ctrl      : "LameControl"

    font      : "gfx_font4x6"
    juke      : "gfx_jukebox"

    song_last : "song_lastboss"
    song_pixl : "song_pixeltheme"
    song_tank : "song_tankbattle"
    song_town : "song_townhall"
    song_zero : "song_zeroforce"
    song_frap : "song_frappy"

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
    music.Start

    character[1] := 0

    songnames[0] := @zero_name
    songnames[1] := @tank_name
    songnames[2] := @pixl_name
    songnames[3] := @town_name
    songnames[4] := @last_name
    songnames[5] := @frap_name

    songs[0] := song_zero.Addr
    songs[1] := song_tank.Addr
    songs[2] := song_pixl.Addr
    songs[3] := song_town.Addr
    songs[4] := song_last.Addr
    songs[5] := song_frap.Addr

    repeat

        lcd.DrawScreen

        ctrl.Update
        gfx.Blit(juke.Addr)

        gfx.TextBox(string("The Music Box"),0,0,64,32)
        gfx.TextBox(string("Up/dn: choose",10,"  A/B: select"), 74, 0,64,32)
        gfx.PutString(string("NOW:"), 22, 26)

        if music.IsPlaying
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
                if music.IsPlaying and songplaying == songchoice
                    music.Stop
                else
                    songplaying := songchoice
                    music.Stop
                    music.Load(songs[songplaying])
                    music.Loop
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
frap_name   byte    "Frappature",0
