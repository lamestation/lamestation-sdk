' *********************************************************
' blehtroid.spin
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

byte    2     'number of bars
byte    110   'tempo
byte    16    'bar resolution

'main
byte    0,  33, 33, 35, 35, 38, 38, 37, 37, 40, 40, 38, 38, 43, 43, 42, 42
byte    1,  SNOP, SNOP, 23, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF

'SONG ------

byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,BAROFF

byte    SONGOFF
