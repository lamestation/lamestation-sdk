' *********************************************************
' pixeltheme.spin
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

byte    14     'number of bars
byte    120    'tempo
byte    8    'bar resolution

'MAIN SECTION
byte    0, 26,  26,  26,  38,   26,  26,  39,  26
byte    0, 26,  36,  26,  26,   36,  26,  36,  38
byte    0, 26,  26,  26,  33,   26,  26,  34,  26
byte    0, 31,  26,  33,  26,   29,  26,  31,  28

byte    1, 14, SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    1,SOFF,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP

byte    2, 33,  33,  33,  36,   33,  33,  36,  33
byte    2, 33,  36,  33,  33,   36,  33,  36,  38

byte    1, 14,  14,  14,  17,   14,  14,  17,  14
byte    1, 14,  17,  14,  14,   17,  14,  17,  19

'UPLIFTING
byte    0, 31,  31,  31,  34,   31,  31,  34,  31
byte    0, 31,  34,  31,  31,   34,  31,  34,  36



byte    1, 19,  19,  19,  22,   19,  19,  22,  19
byte    1, 19,  22,  19,  19,   22,  19,  22,  24




'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,6,BAROFF
byte    1,7,BAROFF
byte    2,6,BAROFF
byte    3,7,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    SONGOFF


