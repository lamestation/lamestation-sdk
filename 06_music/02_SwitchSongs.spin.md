---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 2: Switch Songs"
section: "Section 6: Music"

next_file: "03_SpeedHack.spin.html"
next_name: "Step 3: Speed Hack"

prev_file: "01_PlaySong.spin.html"
prev_name: "Step 1: Play Song"
---
<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    music   : &quot;LameMusic&quot;
    fn      : &quot;LameFunctions&quot;

    song    : &quot;song_pixeltheme&quot;
    song2   : &quot;song_lastboss&quot;

PUB Play
    audio.Start
    music.Start
    
    music.Load(song.Addr)
    music.Loop
    
    fn.Sleep(2000)
    
    music.Stop
    music.Load(song2.Addr)
    music.Loop

    fn.Sleep(2000)    

    music.Stop
    music.Load(song.Addr)
    music.Play
    
    repeat until not music.IsPlaying
    
    music.Load(song2.Addr)
    music.Play</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/02_SwitchSongs.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    music   : &quot;LameMusic&quot;
    fn      : &quot;LameFunctions&quot;

    song    : &quot;song_pixeltheme&quot;
    song2   : &quot;song_lastboss&quot;

PUB Play
    audio.Start
    music.Start
    
    music.Load(song.Addr)
    music.Loop
    
    fn.Sleep(2000)
    
    music.Stop
    music.Load(song2.Addr)
    music.Loop

    fn.Sleep(2000)    

    music.Stop
    music.Load(song.Addr)
    music.Play
    
    repeat until not music.IsPlaying
    
    music.Load(song2.Addr)
    music.Play

</code></pre>
