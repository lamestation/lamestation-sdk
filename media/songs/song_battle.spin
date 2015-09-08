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
byte    16    'bar resolution

'MAIN SECTION
byte    27,SNOP,SNOP,  24,SNOP,SNOP,SNOP,SNOP,  SOFF,SNOP,  27,SNOP,  31,  29,  27,  31
byte    29,  25,SNOP,  32,SNOP,SNOP,SNOP,SNOP,  SNOP,SNOP,  25,SNOP,  32,SNOP,  29,SNOP
byte    29,  25,SNOP,  32,SNOP,SNOP,SNOP,SNOP,    34,SNOP,SNOP,  32,SNOP,SNOP,  29,SNOP

byte     0,   7,   0,   7,   0,   7,   0,   7,     0,   7,   0,   7,   0,   7,   0,   7
byte     1,   8,   1,   8,   1,   8,   1,   8,     1,   8,   1,   8,   1,   8,   1,   8

byte    15,  12,  19,  15,  12,  19,  15,  12,    19,  15,  12,  19,  15,  12,  15,  19
byte    17,  13,  20,  17,  13,  20,  17,  13,    20,  17,  13,  20,  17,  13,  17,  20


byte    32,SNOP,SNOP,SNOP,  31,SNOP,SNOP,SNOP,    29,SNOP,SNOP,SNOP,  31,SNOP,SNOP,SNOP
byte     1,   8,   1,   8,   1,   7,   1,   7,     1,   5,   1,   5,   1,   7,   1,   7
        
sequence_data
byte    TRANS, 33
byte    TEMPO, 80
byte    ADSRW+$F, 127, 10, 100, 10, SQUARE

byte    1,4,6,0
byte    2,5,7,0

byte    1,4,6,0
byte    3,5,7,0

byte    TEMPO, 40

byte    8,9,0,0
byte    8,9,0,0

byte    SONGOFF

