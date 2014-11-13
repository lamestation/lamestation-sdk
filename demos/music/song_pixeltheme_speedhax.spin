' *********************************************************
' song_pixeltheme.spin
' *********************************************************
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
byte    8    'bar resolution

'MAIN SECTION
byte     26,  26,  26,  38,   26,  26,  39,  26
byte     26,  36,  26,  26,   36,  26,  36,  38
byte     26,  26,  26,  33,   26,  26,  34,  26
byte     31,  26,  33,  26,   29,  26,  31,  28

byte     14, SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    SOFF,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP

byte     33,  33,  33,  36,   33,  33,  36,  33
byte     33,  36,  33,  33,   36,  33,  36,  38

byte     14,  14,  14,  17,   14,  14,  17,  14
byte     14,  17,  14,  14,   17,  14,  17,  19

'UPLIFTING
byte     31,  31,  31,  34,   31,  31,  34,  31
byte     31,  34,  31,  31,   34,  31,  34,  36

byte     19,  19,  19,  22,   19,  19,  22,  19
byte     19,  22,  19,  19,   22,  19,  22,  24


sequence_data
byte    TRANS, 0
byte    TEMPO, 120
byte    ADSRW+$F, 127, 10, 100, 10, SAW

byte    1,0,0,0
byte    2,0,0,0
byte    3,0,0,0
byte    4,0,0,0
byte    1,0,0,0
byte    2,0,0,0
byte    3,0,0,0
byte    4,0,0,0

byte    TEMPO, 140

byte    1,5,0,0
byte    2,5,0,0
byte    3,6,0,0
byte    4,6,0,0

byte    TEMPO, 160

byte    1,5,0,0
byte    2,5,0,0
byte    3,6,0,0
byte    4,6,0,0

byte    ADSRW+$F, 127, 10, 100, 10, SINE
byte    TRANS, 24
    
byte    1,7,0,0
byte    2,8,0,0
byte    3,7,0,0
byte    4,8,0,0

byte    1,7,9,0
byte    2,8,10,0
byte    3,7,9,0
byte    4,8,10,0

byte    11,13,0,0
byte    12,14,0,0
byte    11,13,0,0
byte    12,14,0,0

byte    TEMPO, 240

byte    1,7,9,0
byte    2,8,10,0
byte    3,7,9,0
byte    4,8,10,0

byte    11,13,0,0
byte    12,14,0,0
byte    11,13,0,0
byte    12,14,0,0

byte    1,7,9,0
byte    2,8,10,0

byte    TEMPO, 255
    
byte    3,7,9,0
byte    4,8,10,0

byte    SONGOFF

