---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 4: Volume"
section: "Section 5: Audio"

next_file: "05_Amplitude.spin.html"
next_name: "Step 5: Amplitude"

prev_file: "03_Sampler.spin.html"
prev_name: "Step 3: Sampler"
---
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   &quot;LameAudio&quot;
    ctrl    :   &quot;LameControl&quot;
    fn      :   &quot;LameFunctions&quot;
    
VAR
    byte    volume
    
PUB Noise
    audio.Start
    ctrl.Start

    volume := 127

    audio.SetWaveform(1,2)
    audio.SetEnvelope(1,0)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.SetNote(1,70)
        
    repeat
        ctrl.Update

        if ctrl.Up
            if volume &lt; 127
                volume++
                fn.Sleep(10)
        if ctrl.Down
            if volume &gt; 0
                volume--
                fn.Sleep(10)
                
        audio.SetVolume(1,volume)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/04_Volume.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   &quot;LameAudio&quot;
    ctrl    :   &quot;LameControl&quot;
    fn      :   &quot;LameFunctions&quot;
    
VAR
    byte    volume
    
PUB Noise
    audio.Start
    ctrl.Start

    volume := 127

    audio.SetWaveform(1,2)
    audio.SetEnvelope(1,0)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.SetNote(1,70)
        
    repeat
        ctrl.Update

        if ctrl.Up
            if volume &lt; 127
                volume++
                fn.Sleep(10)
        if ctrl.Down
            if volume &gt; 0
                volume--
                fn.Sleep(10)
                
        audio.SetVolume(1,volume)

</code></pre>
