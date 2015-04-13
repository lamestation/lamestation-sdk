<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    ctrl    : &quot;LameControl&quot;
    
VAR
    long    volume
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    audio.SetWaveform(1, audio#_TRIANGLE)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update

        audio.SetFreq(1,freq)

        if ctrl.A            
            if freq &gt; 2000
                freq -= 30
                audio.SetVolume(1,127)
            else
                audio.SetVolume(1,0)
        else
            freq := 40000
            audio.SetVolume(1,0)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/PunyLaser.spin
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
    ctrl    : &quot;LameControl&quot;
    
VAR
    long    volume
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    audio.SetWaveform(1, audio#_TRIANGLE)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update

        audio.SetFreq(1,freq)

        if ctrl.A            
            if freq &gt; 2000
                freq -= 30
                audio.SetVolume(1,127)
            else
                audio.SetVolume(1,0)
        else
            freq := 40000
            audio.SetVolume(1,0)

</code></pre>
