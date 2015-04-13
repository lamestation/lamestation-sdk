---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 7: Key Press"
section: "Section 5: Audio"


prev_file: "06_Waveform.spin.html"
prev_name: "Step 6: Waveform"
---
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   &quot;LameAudio&quot;
    ctrl    :   &quot;LameControl&quot;
    
VAR
    byte    clicked    
    byte    note
    byte    volume
    byte    noting
    
PUB Noise
    audio.Start
    ctrl.Start
    
    audio.SetNote(0, note := 80)
    audio.SetVolume(0, volume := 127)
    audio.SetWaveform(0, audio#_SINE)
    audio.SetADSR(0,127, 100, 0, 127)
    
    audio.SetEnvelope(0, 1)
    
    repeat
        ctrl.Update
        
        if ctrl.A
            if not noting
                audio.PlaySound(0,note)
                noting := 1
        else
            audio.StopSound(0)
            noting := 0

            
        if ctrl.Left
            if note &gt; 40
                note--
        if ctrl.Right
            if note &lt; 80
                note++</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/07_KeyPress.spin
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
    
VAR
    byte    clicked    
    byte    note
    byte    volume
    byte    noting
    
PUB Noise
    audio.Start
    ctrl.Start
    
    audio.SetNote(0, note := 80)
    audio.SetVolume(0, volume := 127)
    audio.SetWaveform(0, audio#_SINE)
    audio.SetADSR(0,127, 100, 0, 127)
    
    audio.SetEnvelope(0, 1)
    
    repeat
        ctrl.Update
        
        if ctrl.A
            if not noting
                audio.PlaySound(0,note)
                noting := 1
        else
            audio.StopSound(0)
            noting := 0

            
        if ctrl.Left
            if note &gt; 40
                note--
        if ctrl.Right
            if note &lt; 80
                note++

</code></pre>
