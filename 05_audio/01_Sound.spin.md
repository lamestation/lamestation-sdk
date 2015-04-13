---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 1: Sound"
section: "Section 5: Audio"

next_file: "02_Noise.spin.html"
next_name: "Step 2: Noise"

---
<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio : &quot;LameAudio&quot;

PUB Main
    audio.Start
    audio.PlaySound(1,50)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/01_Sound.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio : &quot;LameAudio&quot;

PUB Main
    audio.Start
    audio.PlaySound(1,50)

</code></pre>
