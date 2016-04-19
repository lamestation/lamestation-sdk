' *********************************************************
' tetris.spin
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
byte    8      'bar resolution

' bass bass
byte      26,SNOP,  33,SNOP,  26,SNOP,  33,SNOP
byte      31,SNOP,  38,SNOP,  31,SNOP,  38,SNOP
byte      24,SNOP,  31,SNOP,  24,SNOP,  31,SNOP
byte      29,SNOP,  33,SNOP,  28,SNOP,  31,SNOP
byte      24,SNOP,  31,SNOP,  24,SNOP,  31,SNOP
byte      21,SNOP,  21,SNOP,  19,SNOP,  21,SNOP

' harmony
byte      38,SNOP,SNOP,SNOP,SOFF,SNOP,  38,SNOP
byte      43,SNOP,SNOP,SNOP,SOFF,SNOP,  43,SNOP
byte      36,SNOP,SNOP,SNOP,SOFF,SNOP,  36,SNOP
byte      41,SNOP,SNOP,SNOP,  40,SNOP,SNOP,SNOP
byte      36,SNOP,SNOP,SNOP,SOFF,SNOP,  36,SNOP
byte      40,SNOP,  40,SNOP,  38,SNOP,  40,SNOP

' main melody
byte      53,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte      47,SNOP,  50,SNOP,  55,SNOP,  59,SNOP  
byte      60,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte      45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF
byte      53,SNOP,  52,SNOP,  50,SNOP,  48,SNOP
byte      47,SNOP,  50,SNOP,  55,  57,  59,  55  
byte      60,SNOP,  59,  57,  55,SOFF,  52,SNOP
byte      57,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

' high
byte      62,  65,  69,  72,  71,  69,  67,  69
byte      67,  71,  74,  77,  76,  74,  72,  74
byte      72,  67,  64,  67,  65,  64,  62,  60
byte      57,  60,  65,  69,  55,  60,  64,  67
byte      64,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

byte    SNOP,SNOP,SNOP,SNOP,  67,SNOP,  69,SNOP


sequence_data
byte    TRANS, 0
byte    TEMPO, 120
byte    ADSRW+$F, 127, 60, 127, 70, SQUARE

byte    1,0,0,0
byte    2,0,0,0
byte    3,0,0,0
byte    4,0,0,0
byte    1,0,0,0
byte    2,0,0,0
byte    5,0,0,0
byte    6,0,0,0

byte    1, 7,0,0
byte    2, 8,0,0
byte    3, 9,0,0
byte    4,10,0,0
byte    1, 7,0,0
byte    2, 8,0,0
byte    5,11,0,0
byte    6,12,0,0


byte    1, 7,13,0
byte    2, 8,14,0
byte    3, 9,15,0
byte    4,10,16,0
byte    1, 7,17,0
byte    2, 8,18,0
byte    5,11,19,0

byte    6,12,20,0

byte    1, 7,13,21
byte    2, 8,14,22
byte    3, 9,15,23
byte    4,10,16,24
byte    1, 7,17,21
byte    2, 8,18,22
byte    5,11,19,23

byte    6,12,20,25

byte    6,12,20,26
byte    6,12,20,26
byte    6,12,20,26

byte    SONGOFF
