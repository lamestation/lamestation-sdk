' *********************************************************
' townhall.spin
' *********************************************************
' 
' prg pattern
' 000 00000
' F
' 
DAT    
song_data
word    @patches_data, @patterns_data, @sequence_data

CON
    SONGOFF = 255
    BAROFF  = 254
    SNOP    = 253
    SOFF    = 252
    
PUB Addr
    result.word[1] := @@0
    result.word{0} := @song_data

DAT
patches_data
byte    0, 127,  30, 100,   0,   3
byte    1, 127,  30, 100,   0,   3
    
    
patterns_data
byte    16      'bar resolution

byte    0,36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF '0

byte    1,60,SOFF,  60,SOFF,  55,SOFF,  55,SOFF,  58,SNOP,  57,  58,SNOP,  57,  55,  53 '1
byte    1,52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP '1
byte    1,52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  60,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP '1

byte    0,39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF '0
byte    1,63,SOFF,  63,SOFF,  58,SOFF,  58,SOFF,  61,SNOP,  60,  61,SNOP,  60,  58,  56 '1

byte    0,41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF '0
byte    1,65,SOFF,  65,SOFF,  60,SOFF,  60,SOFF,  63,SNOP,  62,  63,SNOP,  62,  60,  58 '1

byte    0,36,  36,  48,  48,  36,  41,  42,  43,SNOP,  43,  43,  43,  43,  43,  43,  43 '0
byte    1,52,SOFF,SNOP,SNOP,SNOP,  53,  54,  55,SNOP,  55,  55,  55,  55,  55,  55,  55 '1

    
sequence_data
byte    120     'tempo (bpm)

byte    0, BAROFF
byte    0, BAROFF
    
byte    0,1,BAROFF
byte    0,2,BAROFF
byte    0,1,BAROFF
byte    0,3,BAROFF

byte    4,5,BAROFF
byte    6,7,BAROFF

byte    0,1,BAROFF
byte    8,9,BAROFF

byte    SONGOFF


