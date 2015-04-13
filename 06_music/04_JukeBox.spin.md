---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 4: Juke Box"
section: "Section 6: Music"

next_file: "05_Propally_Awesome.spin.html"
next_name: "Step 5: Propally  Awesome"

prev_file: "03_SpeedHack.spin.html"
prev_name: "Step 3: Speed Hack"
---
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
  
    SONGCOUNT = 6
    SONGPOS = 38
    SONGWINDOW = 3

OBJ
    lcd       : &quot;LameLCD&quot; 
    gfx       : &quot;LameGFX&quot; 
    audio     : &quot;LameAudio&quot;
    music     : &quot;LameMusic&quot;
    ctrl      : &quot;LameControl&quot;

    font      : &quot;gfx_font4x6&quot;
    juke      : &quot;gfx_jukebox&quot;

    song_last : &quot;song_lastboss&quot;
    song_pixl : &quot;song_pixeltheme&quot;
    song_tank : &quot;song_tankbattle&quot;
    song_town : &quot;song_townhall&quot;
    song_zero : &quot;song_zeroforce&quot;
    song_frap : &quot;song_frappy&quot;

VAR

    long    songs[SONGCOUNT]    &#39; song.Addr returns LONG, not WORD
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
    gfx.LoadFont(font.Addr, &quot; &quot;, 4, 6)
    
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
        
        gfx.TextBox(string(&quot;The Music Box&quot;),0,0,64,32)
        gfx.TextBox(string(&quot;Up/dn: choose&quot;,10,&quot;  A/B: select&quot;), 74, 0,64,32)
        gfx.PutString(string(&quot;NOW:&quot;), 22, 26)
        
        if music.IsPlaying        
            gfx.PutString(songnames[songplaying], 40, 26)
        
        repeat songinc from 0 to constant(SONGWINDOW-1)
        
            if songinc+songoffset == songchoice
                gfx.PutString(string(&quot;&gt;&quot;), 30, SONGPOS+songinc&lt;&lt;3-1)
                
            gfx.PutChar(&quot;1&quot; + songinc + songoffset, 35, SONGPOS+songinc&lt;&lt;3)
            gfx.PutString(songnames[songinc+songoffset], 40, SONGPOS+songinc&lt;&lt;3)
        
       
        if ctrl.Up
            if not joymoved
                joymoved := 1          
                if songchoice &gt; 0
                    songchoice--
                else
                    songchoice := 0
        elseif ctrl.Down
            if not joymoved
                joymoved := 1
                 songchoice++
                 if songchoice &gt; constant(SONGCOUNT-1)
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
                
                
        if songchoice &gt; constant(SONGWINDOW-1)
            songoffset := songchoice - constant(SONGWINDOW-1)
        else
            songoffset := 0
                                  
DAT

tank_name   byte    &quot;Tank Danger&quot;,0
zero_name   byte    &quot;Into Infinity&quot;,0
pixl_name   byte    &quot;Intensity&quot;,0
town_name   byte    &quot;Midday Affair&quot;,0
last_name   byte    &quot;Enter Darkness&quot;,0
frap_name   byte    &quot;Frappature&quot;,0</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/04_JukeBox.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
  
    SONGCOUNT = 6
    SONGPOS = 38
    SONGWINDOW = 3

OBJ
    lcd       : &quot;LameLCD&quot; 
    gfx       : &quot;LameGFX&quot; 
    audio     : &quot;LameAudio&quot;
    music     : &quot;LameMusic&quot;
    ctrl      : &quot;LameControl&quot;

    font      : &quot;gfx_font4x6&quot;
    juke      : &quot;gfx_jukebox&quot;

    song_last : &quot;song_lastboss&quot;
    song_pixl : &quot;song_pixeltheme&quot;
    song_tank : &quot;song_tankbattle&quot;
    song_town : &quot;song_townhall&quot;
    song_zero : &quot;song_zeroforce&quot;
    song_frap : &quot;song_frappy&quot;

VAR

    long    songs[SONGCOUNT]    &#39; song.Addr returns LONG, not WORD
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
    gfx.LoadFont(font.Addr, &quot; &quot;, 4, 6)
    
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
        
        gfx.TextBox(string(&quot;The Music Box&quot;),0,0,64,32)
        gfx.TextBox(string(&quot;Up/dn: choose&quot;,10,&quot;  A/B: select&quot;), 74, 0,64,32)
        gfx.PutString(string(&quot;NOW:&quot;), 22, 26)
        
        if music.IsPlaying        
            gfx.PutString(songnames[songplaying], 40, 26)
        
        repeat songinc from 0 to constant(SONGWINDOW-1)
        
            if songinc+songoffset == songchoice
                gfx.PutString(string(&quot;&gt;&quot;), 30, SONGPOS+songinc&lt;&lt;3-1)
                
            gfx.PutChar(&quot;1&quot; + songinc + songoffset, 35, SONGPOS+songinc&lt;&lt;3)
            gfx.PutString(songnames[songinc+songoffset], 40, SONGPOS+songinc&lt;&lt;3)
        
       
        if ctrl.Up
            if not joymoved
                joymoved := 1          
                if songchoice &gt; 0
                    songchoice--
                else
                    songchoice := 0
        elseif ctrl.Down
            if not joymoved
                joymoved := 1
                 songchoice++
                 if songchoice &gt; constant(SONGCOUNT-1)
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
                
                
        if songchoice &gt; constant(SONGWINDOW-1)
            songoffset := songchoice - constant(SONGWINDOW-1)
        else
            songoffset := 0
                                  
DAT

tank_name   byte    &quot;Tank Danger&quot;,0
zero_name   byte    &quot;Into Infinity&quot;,0
pixl_name   byte    &quot;Intensity&quot;,0
town_name   byte    &quot;Midday Affair&quot;,0
last_name   byte    &quot;Enter Darkness&quot;,0
frap_name   byte    &quot;Frappature&quot;,0

</code></pre>
