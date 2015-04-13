<pre><code>&#39; *********************************************************
&#39; blehtroid.spin
&#39; *********************************************************
DAT    
song_data
word    @patterns_data, @sequence_data

CON
    SONGOFF = $80
    SNOP    = $82
    SOFF    = $83
    
    ADSRW   = $A0
    TEMPO   = $B0
    TRANS   = $C0
    
    #0, SQUARE, SAW, TRIANGLE, SINE, NOISE, SAMPLE
    
PUB Addr
    result.word[1] := @@0
    result.word{0} := @song_data

DAT    

patterns_data
byte    16    &#39;bar resolution

&#39;main
byte    33, 33, 35, 35, 38, 38, 37, 37, 40, 40, 38, 38, 43, 43, 42, 42
byte    SNOP, SNOP, 23, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF


sequence_data
byte    TRANS, 0
byte    TEMPO, 110
byte    ADSRW+$F, 127, 3, 60, 0, SAW

byte    1,0,0,0
byte    1,0,0,0
byte    1,0,0,0
byte    1,0,0,0
byte    1,2,0,0
byte    1,0,0,0
byte    1,2,0,0
byte    1,0,0,0

byte    SONGOFF</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/sng_blehtroid.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39; *********************************************************
&#39; blehtroid.spin
&#39; *********************************************************
DAT    
song_data
word    @patterns_data, @sequence_data

CON
    SONGOFF = $80
    SNOP    = $82
    SOFF    = $83
    
    ADSRW   = $A0
    TEMPO   = $B0
    TRANS   = $C0
    
    #0, SQUARE, SAW, TRIANGLE, SINE, NOISE, SAMPLE
    
PUB Addr
    result.word[1] := @@0
    result.word{0} := @song_data

DAT    

patterns_data
byte    16    &#39;bar resolution

&#39;main
byte    33, 33, 35, 35, 38, 38, 37, 37, 40, 40, 38, 38, 43, 43, 42, 42
byte    SNOP, SNOP, 23, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF


sequence_data
byte    TRANS, 0
byte    TEMPO, 110
byte    ADSRW+$F, 127, 3, 60, 0, SAW

byte    1,0,0,0
byte    1,0,0,0
byte    1,0,0,0
byte    1,0,0,0
byte    1,2,0,0
byte    1,0,0,0
byte    1,2,0,0
byte    1,0,0,0

byte    SONGOFF

</code></pre>
