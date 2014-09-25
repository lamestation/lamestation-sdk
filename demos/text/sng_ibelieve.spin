' *********************************************************
' ibelieve.spin
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
byte    16    'bar resolution

'main
byte    0,  50, 46, 53, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    0,  55, 51, 46, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    0,  58, SNOP, SNOP, SNOP, 57, SNOP, SNOP, SNOP, 55, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP
byte    0,  50, 46, 41, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

'low harmony
byte    1,  46, 41, 50, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    1,  51, 46, 39, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    1,  55, SNOP, SNOP, SNOP, 53, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP, 48, SNOP, SNOP, SNOP
byte    1,  46, 41, 38, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

'low part
byte    2,  22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    2,  27, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
byte    2,  31, SNOP, SNOP, SNOP, 29, SNOP, SNOP, SNOP, 27, SNOP, SNOP, SNOP, 24, SNOP, SNOP, SNOP
byte    2,  22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 80
byte    ADSRW+$F, 120, 80, 40, 110, SQUARE

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF

byte    0,4,BAROFF
byte    1,5,BAROFF
byte    2,6,BAROFF
byte    3,7,BAROFF

byte    0,4,8,BAROFF
byte    1,5,9,BAROFF
byte    2,6,10,BAROFF
byte    3,7,11,BAROFF

byte    SONGOFF
