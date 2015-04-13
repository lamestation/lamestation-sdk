<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    ctrl    : &quot;LameControl&quot;
    
VAR
    long    volume
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 1
    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
        audio.SetFreq(1,freq)

        if ctrl.A
            if freq &gt; 4000
                freq -= 20
            
            volcount++ 
            if (volcount &gt;&gt; 2) // 2 == 1
                volume := 127
            else
                volume := 0
            
            audio.SetVolume(1,volume)
        else
            freq := 40000
            audio.SetVolume(1,0)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/Robot.spin
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
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 1
    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
        audio.SetFreq(1,freq)

        if ctrl.A
            if freq &gt; 4000
                freq -= 20
            
            volcount++ 
            if (volcount &gt;&gt; 2) // 2 == 1
                volume := 127
            else
                volume := 0
            
            audio.SetVolume(1,volume)
        else
            freq := 40000
            audio.SetVolume(1,0)

</code></pre>
