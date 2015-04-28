' *********************************************************
' song_boss.spin
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
byte    8

byte    26,26,26,SNOP,SNOP,SNOP,27,26
byte    27,26,27,26,SNOP,26,27,SNOP

sequence_data
byte    TRANS, 0
byte    TEMPO, 100
byte    ADSRW+$F, 127, 10, 100, 10, SAW

byte    1,0,0,0
byte    2,0,0,0

byte    SONGOFF

