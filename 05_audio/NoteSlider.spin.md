<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : &quot;LameAudio&quot;
    ctrl    : &quot;LameControl&quot;
    fn      : &quot;LameFunctions&quot;
    
VAR
    long    note

PUB Main
    audio.Start
    ctrl.Start
    
    note := 24
    
    audio.SetEnvelope(0,0)
    audio.SetEnvelope(1,0)
    audio.SetEnvelope(2,0)
    audio.SetEnvelope(3,0)
    
    audio.SetWaveform(0, audio#_SQUARE)
    audio.SetWaveform(1, audio#_SAW)
    audio.SetWaveform(2, audio#_SINE)
    audio.SetWaveform(3, audio#_SINE)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            if note &gt; 0
                note--
        if ctrl.Right
            if note &lt; 150
                note++

        audio.SetNote(0, note)
        audio.SetNote(1, note - 12)
        audio.SetFreq(2, note &lt;&lt; 10)
        audio.SetFreq(3, note &gt;&gt; 2)
        
        fn.Sleep(5)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/NoteSlider.spin
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
    fn      : &quot;LameFunctions&quot;
    
VAR
    long    note

PUB Main
    audio.Start
    ctrl.Start
    
    note := 24
    
    audio.SetEnvelope(0,0)
    audio.SetEnvelope(1,0)
    audio.SetEnvelope(2,0)
    audio.SetEnvelope(3,0)
    
    audio.SetWaveform(0, audio#_SQUARE)
    audio.SetWaveform(1, audio#_SAW)
    audio.SetWaveform(2, audio#_SINE)
    audio.SetWaveform(3, audio#_SINE)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            if note &gt; 0
                note--
        if ctrl.Right
            if note &lt; 150
                note++

        audio.SetNote(0, note)
        audio.SetNote(1, note - 12)
        audio.SetFreq(2, note &lt;&lt; 10)
        audio.SetFreq(3, note &gt;&gt; 2)
        
        fn.Sleep(5)

</code></pre>
