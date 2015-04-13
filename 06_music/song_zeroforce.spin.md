<pre><code>&#39; *********************************************************
&#39; zeroforce.spin
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
byte    8      &#39;bar resolution

&#39;MAIN SECTION
&#39;0-5
byte    36,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    51,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    56,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    63,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

&#39;6
byte    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

&#39;7-10
byte    41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    60,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    53,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    65,65,63,65,SOFF,65,SOFF,63

&#39;11-12
byte    SNOP,SNOP,SNOP,44,SNOP,SNOP,SNOP,SNOP
byte    65,65,63,68,SNOP,SOFF,SNOP,SNOP

&#39;13-14
byte    29,SNOP,SOFF,SNOP,29,SNOP,SOFF,SNOP
byte    29,SNOP,SOFF,SNOP,29,SNOP,27,SNOP

byte    46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 150
byte    ADSRW+$F, 127, 100, 40, 100, SAW

byte    1,0,0,0
byte    1,2,0,0
byte    1,2,3,0
byte    1,2,3,4
byte    5,2,3,4
byte    5,6,3,4
byte    5,6,7,4

byte    11,8,9,10
byte    13,12,0,10
byte    11,8,9,10
byte    13,12,0,10

byte    11,14,10,10
byte    13,15,10,10
byte    11,14,10,10
byte    13,15,10,10

byte    11,14,16,10
byte    13,15,16,10
byte    11,14,17,10
byte    13,15,17,10

byte    11,14,18,10
byte    13,15,18,10
byte    11,14,18,10
byte    13,15,18,10

byte    11,14,16,10
byte    13,15,16,10
byte    11,14,17,10
byte    13,15,17,10

byte    SONGOFF

</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 06_music/song_zeroforce.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39; *********************************************************
&#39; zeroforce.spin
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
byte    8      &#39;bar resolution

&#39;MAIN SECTION
&#39;0-5
byte    36,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    51,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    56,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    63,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

&#39;6
byte    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

&#39;7-10
byte    41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    60,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    53,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    65,65,63,65,SOFF,65,SOFF,63

&#39;11-12
byte    SNOP,SNOP,SNOP,44,SNOP,SNOP,SNOP,SNOP
byte    65,65,63,68,SNOP,SOFF,SNOP,SNOP

&#39;13-14
byte    29,SNOP,SOFF,SNOP,29,SNOP,SOFF,SNOP
byte    29,SNOP,SOFF,SNOP,29,SNOP,27,SNOP

byte    46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 150
byte    ADSRW+$F, 127, 100, 40, 100, SAW

byte    1,0,0,0
byte    1,2,0,0
byte    1,2,3,0
byte    1,2,3,4
byte    5,2,3,4
byte    5,6,3,4
byte    5,6,7,4

byte    11,8,9,10
byte    13,12,0,10
byte    11,8,9,10
byte    13,12,0,10

byte    11,14,10,10
byte    13,15,10,10
byte    11,14,10,10
byte    13,15,10,10

byte    11,14,16,10
byte    13,15,16,10
byte    11,14,17,10
byte    13,15,17,10

byte    11,14,18,10
byte    13,15,18,10
byte    11,14,18,10
byte    13,15,18,10

byte    11,14,16,10
byte    13,15,16,10
byte    11,14,17,10
byte    13,15,17,10

byte    SONGOFF



</code></pre>
