' *********************************************************
' song_ohno.spin
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

byte    30, 29, 28, 27, SNOP, SNOP, SOFF
byte    18, 17, 16, 15, SNOP, SNOP, SOFF

sequence_data
byte    TRANS, 0
byte    TEMPO, 120
byte    ADSRW+$F, 127, 10, 100, 10, SAW

byte    1,2,0,0

byte    SONGOFF

