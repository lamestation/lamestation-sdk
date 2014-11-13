' *********************************************************
' song_sad.spin
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
'low part
byte    32,  39, 42, 46, 32, 39, 42, 46
byte    28,  35, 37, 42, 28, 35, 37, 42
byte    25,  32, 37, 40, 25, 32, 37, 40
byte    22,  29, 34, 38, 22, 29, 34, 38
byte    27,SNOP, 27, 29, 30, 27, 30, 34 ' do do dooo do doo
'high part
byte       59,SNOP,  59,  58, 58, SNOP, SNOP, SNOP
byte     SNOP,  59,  59,  58, 58,   54,   54,   51
byte       54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte     SNOP,  54,  54,  52, 52,   51,   51,   54
byte       54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte     SNOP,  54,  54,  51, 51,   47,   47,   51
byte       51,SNOP,SNOP,  50, 50, SNOP, SNOP, SNOP
byte     SNOP,SNOP,  51,  53, 54,   51,   54,   58
byte       58,SNOP,SNOP,  56, 56, SNOP, SNOP, SNOP


sequence_data
byte    TRANS, 12
byte    TEMPO, 35
byte    ADSRW+$F, 127, 3, 0, 3, TRIANGLE

byte    1,6,0,0
byte    1,7,0,0
byte    2,8,0,0
byte    2,9,0,0
byte    3,10,0,0
byte    3,11,0,0
byte    4,12,0,0
byte    5,13,0,0
byte    1,14,0,0
byte    1,0,0,0

byte    SONGOFF

