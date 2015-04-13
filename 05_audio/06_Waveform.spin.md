---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 6: Waveform"
section: "Section 5: Audio"

next_file: "07_KeyPress.spin.html"
next_name: "Step 7: Key Press"

prev_file: "05_Amplitude.spin.html"
prev_name: "Step 5: Amplitude"
---
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   &quot;LameAudio&quot;
    ctrl    :   &quot;LameControl&quot;
    fn      :   &quot;LameFunctions&quot;
    
VAR
    byte    waveform
    byte    note
    
PUB Noise
    audio.Start
    ctrl.Start

    waveform := 1
    note := 50
    
    audio.SetADSR(1,127, 1, 0, 70)
    audio.PlaySound(1,note)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            if waveform &gt; 0
                waveform--
                fn.Sleep(200)
        if ctrl.Right
            if waveform &lt; 5
                waveform++
                fn.Sleep(200)
                
        if ctrl.Up
            if note &lt; 127
                note++
                fn.Sleep(50)
        if ctrl.Down
            if note &gt; 0
                note--
                fn.Sleep(50)
                
        audio.SetWaveform(1, waveform)
        audio.PlaySound(1,note) </code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/06_Waveform.spin
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
    byte    waveform
    byte    note
    
PUB Noise
    audio.Start
    ctrl.Start

    waveform := 1
    note := 50
    
    audio.SetADSR(1,127, 1, 0, 70)
    audio.PlaySound(1,note)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            if waveform &gt; 0
                waveform--
                fn.Sleep(200)
        if ctrl.Right
            if waveform &lt; 5
                waveform++
                fn.Sleep(200)
                
        if ctrl.Up
            if note &lt; 127
                note++
                fn.Sleep(50)
        if ctrl.Down
            if note &gt; 0
                note--
                fn.Sleep(50)
                
        audio.SetWaveform(1, waveform)
        audio.PlaySound(1,note) 

</code></pre>
