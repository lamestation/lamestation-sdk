---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 3: Speed Hack"
section: "Section 6: Music"

next_file: "04_JukeBox.spin.html"
next_name: "Step 4: Juke Box"

prev_file: "02_SwitchSongs.spin.html"
prev_name: "Step 2: Switch Songs"
---
<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    music   : &quot;LameMusic&quot;
    
    song    : &quot;song_pixeltheme_speedhax&quot;

PUB Main
    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/03_SpeedHack.spin
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
    
    song    : &quot;song_pixeltheme_speedhax&quot;

PUB Main
    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop

</code></pre>
