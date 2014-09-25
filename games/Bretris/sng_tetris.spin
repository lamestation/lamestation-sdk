' *********************************************************
' tetris.spin
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

' bass bass
byte    0,  26,SNOP,  33,SNOP,  26,SNOP,  33,SNOP
byte    0,  31,SNOP,  38,SNOP,  31,SNOP,  38,SNOP
byte    0,  24,SNOP,  31,SNOP,  24,SNOP,  31,SNOP
byte    0,  29,SNOP,  33,SNOP,  28,SNOP,  31,SNOP
byte    0,  24,SNOP,  31,SNOP,  24,SNOP,  31,SNOP
byte    0,  21,SNOP,  21,SNOP,  19,SNOP,  21,SNOP

' harmony
byte    1,  38,SNOP,SNOP,SNOP,SOFF,SNOP,  38,SNOP
byte    1,  43,SNOP,SNOP,SNOP,SOFF,SNOP,  43,SNOP
byte    1,  36,SNOP,SNOP,SNOP,SOFF,SNOP,  36,SNOP
byte    1,  41,SNOP,SNOP,SNOP,  40,SNOP,SNOP,SNOP
byte    1,  36,SNOP,SNOP,SNOP,SOFF,SNOP,  36,SNOP
byte    1,  40,SNOP,  40,SNOP,  38,SNOP,  40,SNOP

' main melody
byte    2,  53,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte    2,  47,SNOP,  50,SNOP,  55,SNOP,  59,SNOP  
byte    2,  60,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte    2,  45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF
byte    2,  53,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte    2,  47,SNOP,  50,SNOP,  55,  57,  59,  55  
byte    2,  60,SNOP,  59,  57,  55,SOFF,  52,SNOP
byte    2,  57,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

' high
byte    3,  62,  65,  69,  72,  71,  69,  67,  69
byte    3,  67,  71,  74,  77,  76,  74,  72,  74
byte    3,  72,  67,  64,  67,  65,  64,  62,  60
byte    3,  57,  60,  65,  69,  55,  60,  64,  67
byte    3,  64,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

byte    3,SNOP,SNOP,SNOP,SNOP,  67,SNOP,  69,SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 120
byte    ADSRW+$F, 127, 60, 127, 70, SQUARE

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    0,BAROFF
byte    1,BAROFF
byte    4,BAROFF
byte    5,BAROFF

byte    0, 6,BAROFF
byte    1, 7,BAROFF
byte    2, 8,BAROFF
byte    3, 9,BAROFF
byte    0, 6,BAROFF
byte    1, 7,BAROFF
byte    4,10,BAROFF
byte    5,11,BAROFF


byte    0, 6,12,BAROFF
byte    1, 7,13,BAROFF
byte    2, 8,14,BAROFF
byte    3, 9,15,BAROFF
byte    0, 6,16,BAROFF
byte    1, 7,17,BAROFF
byte    4,10,18,BAROFF

byte    5,11,19,BAROFF

byte    0, 6,12,20,BAROFF
byte    1, 7,13,21,BAROFF
byte    2, 8,14,22,BAROFF
byte    3, 9,15,23,BAROFF
byte    0, 6,16,20,BAROFF
byte    1, 7,17,21,BAROFF
byte    4,10,18,22,BAROFF

byte    5,11,19,24,BAROFF

byte    5,11,19,25,BAROFF
byte    5,11,19,25,BAROFF
byte    5,11,19,25,BAROFF

byte    SONGOFF
