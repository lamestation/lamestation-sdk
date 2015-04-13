---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 5: Propally  Awesome"
section: "Section 6: Music"


prev_file: "04_JukeBox.spin.html"
prev_name: "Step 4: Juke Box"
---
<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    music   : &quot;LameMusic&quot;
    
    song    : &quot;song_proppaly_awesome&quot;

PUB Main
    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Play</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/05_Propally_Awesome.spin
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
    
    song    : &quot;song_proppaly_awesome&quot;

PUB Main
    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Play

</code></pre>
