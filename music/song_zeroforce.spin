' *********************************************************
' zeroforce.spin
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

byte    18     'number of bars
byte    150     'tempo
byte    8      'bar resolution

'MAIN SECTION
'0-5
byte    0,36,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,51,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,56,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,63,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'6
byte    0,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

'7-10
byte    0,41,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,60,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,53,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,65,SOFF,65,SOFF,63

'11-12
byte    0,SNOP,SNOP,SNOP,44,SNOP,SNOP,SNOP,SNOP
byte    3,65,65,63,68,SNOP,SOFF,SNOP,SNOP

'13-14
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,SOFF,SNOP
byte    2,29,SNOP,SOFF,SNOP,29,SNOP,27,SNOP

byte    0,46,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    0,44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP


'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    4,BAROFF
byte    5,BAROFF

byte    6,BAROFF

byte    7,8,9,10,BAROFF
byte    11,12,BAROFF
byte    7,8,9,10,BAROFF
byte    11,12,BAROFF

byte    10,13,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    10,13,17,BAROFF
byte    12,14,BAROFF
byte    10,13,BAROFF
byte    12,14,BAROFF

byte    10,13,15,BAROFF
byte    12,14,BAROFF
byte    10,13,16,BAROFF
byte    12,14,BAROFF

byte    SONGOFF


