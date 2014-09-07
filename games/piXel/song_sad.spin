' *********************************************************
' song_sad.spin
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
byte    8
'low part
byte    0, 32,  39, 42, 46, 32, 39, 42, 46
byte    0, 28,  35, 37, 42, 28, 35, 37, 42
byte    0, 25,  32, 37, 40, 25, 32, 37, 40
byte    0, 22,  29, 34, 38, 22, 29, 34, 38
byte    0, 27,SNOP, 27, 29, 30, 27, 30, 34 ' do do dooo do doo
'high part
byte    1,   59,SNOP,  59,  58, 58, SNOP, SNOP, SNOP
byte    1, SNOP,  59,  59,  58, 58,   54,   54,   51
byte    1,   54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte    1, SNOP,  54,  54,  52, 52,   51,   51,   54
byte    1,   54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte    1, SNOP,  54,  54,  51, 51,   47,   47,   51
byte    1,   51,SNOP,SNOP,  50, 50, SNOP, SNOP, SNOP
byte    1, SNOP,SNOP,  51,  53, 54,   51,   54,   58
byte    1,   58,SNOP,SNOP,  56, 56, SNOP, SNOP, SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 35
byte    ADSRW+$F, 127, 3, 0, 3, SINE

byte    0,5,BAROFF
byte    0,6,BAROFF
byte    1,7,BAROFF
byte    1,8,BAROFF
byte    2,9,BAROFF
byte    2,10,BAROFF
byte    3,11,BAROFF
byte    4,12,BAROFF
byte    0,13,BAROFF
byte    0,BAROFF

byte    SONGOFF

