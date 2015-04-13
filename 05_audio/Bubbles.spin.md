<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    ctrl    : &quot;LameControl&quot;
    
VAR
    long    volume
    long    volume_inc
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 1
    volume_inc := 1
    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
               
        if ctrl.Up
            freq++
        if ctrl.Down
            freq--

        audio.SetFreq(1,freq)

        if ctrl.A
            volume_inc--
            
            volcount++ 
            if (volcount // volume_inc) &gt; (volume_inc &gt;&gt; 1)
                volume := 127
            else
                volume := 0
            
            audio.SetVolume(1,volume)
        else
            volume_inc := 1000
            audio.SetVolume(1,0)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/Bubbles.spin
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
    long    volume_inc
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 1
    volume_inc := 1
    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
               
        if ctrl.Up
            freq++
        if ctrl.Down
            freq--

        audio.SetFreq(1,freq)

        if ctrl.A
            volume_inc--
            
            volcount++ 
            if (volcount // volume_inc) &gt; (volume_inc &gt;&gt; 1)
                volume := 127
            else
                volume := 0
            
            audio.SetVolume(1,volume)
        else
            volume_inc := 1000
            audio.SetVolume(1,0)

</code></pre>
