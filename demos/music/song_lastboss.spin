' *********************************************************
' lastboss.spin
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

byte    4     'number of bars
byte    150    'tempo
byte    12     'notes/bar

'MAIN SECTION
'0-5
byte    0,45,41,40,45,41,40,45,41,40,45,41,40
byte    0,46,43,42,46,43,42,46,43,42,46,43,42

byte    1,26,SNOP,SNOP,29,SNOP,SNOP,28,SNOP,SNOP,29,SNOP,SNOP
byte    1,25,SNOP,SNOP,26,SNOP,SNOP,27,SNOP,SNOP,21,SNOP,SNOP


'SONG ------

byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
byte    0,2,BAROFF
byte    1,3,BAROFF
byte    SONGOFF

