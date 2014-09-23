' *********************************************************
' blehtroid.spin
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
byte    0,  33, 33, 35, 35, 38, 38, 37, 37, 40, 40, 38, 38, 43, 43, 42, 42
byte    1,  SNOP, SNOP, 23, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF


sequence_data
byte    TRANS, 0
byte    TEMPO, 110
byte    ADSRW+$F, 127, 3, 60, 0, SAW

byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF

byte    SONGOFF
