---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 2: Noise"
section: "Section 5: Audio"

next_file: "03_Sampler.spin.html"
next_name: "Step 3: Sampler"

prev_file: "01_Sound.spin.html"
prev_name: "Step 1: Sound"
---
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :               &quot;LameAudio&quot;

PUB Noise
    audio.Start

    audio.SetWaveform(1, 4)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.PlaySound(1,50)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/02_Noise.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :               &quot;LameAudio&quot;

PUB Noise
    audio.Start

    audio.SetWaveform(1, 4)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.PlaySound(1,50)

</code></pre>
