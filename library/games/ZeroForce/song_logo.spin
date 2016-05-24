' *********************************************************
' logo.spin
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
byte    12

byte    72,SNOP,70,SNOP,68,SNOP,63,SNOP,51,75,87,SOFF


'SONG ------
sequence_data
byte    TRANS, 0
byte    TEMPO, 255
byte    ADSRW+$F, 127, 20, 40, 20, SINE

byte    1,0,0,0

byte    SONGOFF

