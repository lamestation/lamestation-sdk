' *********************************************************
' song_superohno.spin
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
byte    7

byte    27, 26, 25, 24, SNOP, SNOP, SOFF
byte    15, 14, 13, 12, SNOP, SNOP, SOFF

sequence_data
byte    TRANS, 0
byte    TEMPO, 75
byte    ADSRW+$F, 127, 10, 100, 10, SAW

byte    0,1,0,0
byte    SONGOFF

