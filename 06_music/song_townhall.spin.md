<pre><code>&#39; *********************************************************
&#39; townhall.spin
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
byte    16      &#39;bar resolution

byte    36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF &#39;0

byte    60,SOFF,  60,SOFF,  55,SOFF,  55,SOFF,  58,SNOP,  57,  58,SNOP,  57,  55,  53 &#39;1
byte    52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP &#39;1
byte    52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  60,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP &#39;1

byte    39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF &#39;0
byte    63,SOFF,  63,SOFF,  58,SOFF,  58,SOFF,  61,SNOP,  60,  61,SNOP,  60,  58,  56 &#39;1

byte    41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF &#39;0
byte    65,SOFF,  65,SOFF,  60,SOFF,  60,SOFF,  63,SNOP,  62,  63,SNOP,  62,  60,  58 &#39;1

byte    36,  36,  48,  48,  36,  41,  42,  43,SNOP,  43,  43,  43,  43,  43,  43,  43 &#39;0
byte    52,SOFF,SNOP,SNOP,SNOP,  53,  54,  55,SNOP,  55,  55,  55,  55,  55,  55,  55 &#39;1

    
sequence_data
byte    TRANS, 12
byte    TEMPO, 130
byte    ADSRW+$F, 127,  30, 100,   0,   SINE

byte    1,0,0,0
byte    1,0,0,0
    
byte    1,2,0,0
byte    1,3,0,0

byte    1,2,0,0
byte    1,4,0,0

byte    5,6,0,0
byte    7,8,0,0

byte    1,2,0,0
byte    9,10,0,0

byte    SONGOFF

</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/song_townhall.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39; *********************************************************
&#39; townhall.spin
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
byte    16      &#39;bar resolution

byte    36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF &#39;0

byte    60,SOFF,  60,SOFF,  55,SOFF,  55,SOFF,  58,SNOP,  57,  58,SNOP,  57,  55,  53 &#39;1
byte    52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP &#39;1
byte    52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  60,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP &#39;1

byte    39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF &#39;0
byte    63,SOFF,  63,SOFF,  58,SOFF,  58,SOFF,  61,SNOP,  60,  61,SNOP,  60,  58,  56 &#39;1

byte    41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF &#39;0
byte    65,SOFF,  65,SOFF,  60,SOFF,  60,SOFF,  63,SNOP,  62,  63,SNOP,  62,  60,  58 &#39;1

byte    36,  36,  48,  48,  36,  41,  42,  43,SNOP,  43,  43,  43,  43,  43,  43,  43 &#39;0
byte    52,SOFF,SNOP,SNOP,SNOP,  53,  54,  55,SNOP,  55,  55,  55,  55,  55,  55,  55 &#39;1

    
sequence_data
byte    TRANS, 12
byte    TEMPO, 130
byte    ADSRW+$F, 127,  30, 100,   0,   SINE

byte    1,0,0,0
byte    1,0,0,0
    
byte    1,2,0,0
byte    1,3,0,0

byte    1,2,0,0
byte    1,4,0,0

byte    5,6,0,0
byte    7,8,0,0

byte    1,2,0,0
byte    9,10,0,0

byte    SONGOFF



</code></pre>
