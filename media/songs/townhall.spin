' *********************************************************
' townhall.spin
' *********************************************************
CON
    SONGOFF = 255
    BAROFF  = 254
    SNOP    = 253
    SOFF    = 252

PUB Addr
    return @song_data

DAT

song_data

byte    10
byte    120
byte    16

byte    0, 36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF,  36,SOFF,  48,SOFF

byte    1, 60,SOFF,  60,SOFF,  55,SOFF,  55,SOFF,  58,SNOP,  57,  58,SNOP,  57,  55,  53
byte    1, 52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP
byte    1, 52,SNOP,SNOP,SNOP,SNOP,  53,  55,SNOP,  60,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP

byte    0, 39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF,  39,SOFF,  51,SOFF
byte    1, 63,SOFF,  63,SOFF,  58,SOFF,  58,SOFF,  61,SNOP,  60,  61,SNOP,  60,  58,  56

byte    0, 41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF,  41,SOFF,  53,SOFF
byte    1, 65,SOFF,  65,SOFF,  60,SOFF,  60,SOFF,  63,SNOP,  62,  63,SNOP,  62,  60,  58

byte    0, 36,  36,  48,  48,  36,  41,  42,  43,SNOP,  43,  43,  43,  43,  43,  43,  43
byte    1, 52,SOFF,SNOP,SNOP,SNOP,  53,  54,  55,SNOP,  55,  55,  55,  55,  55,  55,  55

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