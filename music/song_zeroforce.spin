' *********************************************************
' zeroforce.spin
' *********************************************************
DAT    
song_data
word    @patterns_data, @sequence_data

CON
    SONGOFF = $80
    BAROFF  = $81
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
byte    8      'bar resolution

'MAIN SECTION
'0-5
byte    0,36,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,51,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,56,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,63,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'6
byte    0,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'7-10
byte    0,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,60,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,53,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,65,SOFF,65,SOFF,63

'11-12
byte    0,SNOP,SNOP,SNOP,44,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,68,SNOP,SOFF,SNOP,SNOP

'13-14
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,SOFF,SNOP
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,27,SNOP

byte    0,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 150
byte    ADSRW+$F, 127, 100, 40, 100, SAW

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    4,BAROFF
byte    5,BAROFF

byte    6,BAROFF

byte    7,8,9,10,BAROFF
byte    11,12,BAROFF
byte    7,8,9,10,BAROFF
byte    11,12,BAROFF

byte    10,13,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    10,13,17,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    SONGOFF


