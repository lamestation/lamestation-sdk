' *********************************************************
' proppaly_awesome.spin
' *********************************************************
DAT    
song_data
word    @patterns_data, @sequence_data

CON
    SONGOFF = $80
    BAROFF  = $81
    SNOP    = $82
    SOFF    = $83
    
    NOTEOFF = $90
    
    ADSRW   = $A0
    TEMPO   = $B0
    TRANS   = $C0
    
    #0, SQUARE, SAW, TRIANGLE, SINE, NOISE, SAMPLE
    
PUB Addr
    result.word[1] := @@0
    result.word{0} := @song_data

DAT    

patterns_data
byte    16    'bar resolution

'MAIN SECTION
byte    0,  61,SOFF,  57,SOFF,  59,SOFF,  57,SOFF,     61,SOFF,  57,  59,SNOP,  59,  57,  57    '0  melody
byte    0,  61,  61,  57,  57,  59,SOFF,  57,SOFF,     61,SOFF,  57,  59,SNOP,  59,  57,  57    '1  melody

byte    1,  45,SNOP,SOFF,SNOP,  40,SNOP,SOFF,SNOP,     37,SNOP,SOFF,  38,SNOP,SNOP,  40,SNOP    '2  low
byte    1,SOFF,SNOP,  33,SNOP,  37,SNOP,SNOP,SNOP,     38,SNOP,SOFF,  38,SNOP,  37,  33,SNOP    '3  low

byte    2,  21,SNOP,SOFF,SNOP,  28,SNOP,SOFF,SNOP,     25,SNOP,SOFF,  26,SNOP,SNOP,  28,SNOP    '4  bass

byte    3,SNOP,SNOP,  40,SOFF,SNOP,SNOP,  40,SOFF,   SNOP,SNOP,  40,  40,SOFF,  40,  40,SOFF    '5  snare

byte    0,SOFF,SNOP,  45,  45,SOFF,SNOP,  45,SOFF,   SNOP,SNOP,  45,  45,SOFF,  45,  45,SOFF    '6  chords
byte    0,SOFF,SNOP,  45,  45,SOFF,SNOP,  45,SOFF,     45,SNOP,SOFF,  45,SNOP,SOFF,  45,SOFF    '7  chords
byte    1,SOFF,SNOP,  49,  49,SOFF,SNOP,  49,SOFF,   SNOP,SNOP,  49,  49,SOFF,  49,  49,SOFF    '8  chords
byte    1,SOFF,SNOP,  49,  49,SOFF,SNOP,  49,SOFF,     50,SNOP,SOFF,  50,SNOP,SOFF,  49,SOFF    '9  chords



byte    2,  21,SOFF,SNOP,  25,SOFF,SNOP,  26,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '10 bass
byte    2,  25,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,     21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '11 bass
byte    2,  21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  28    '12 bass
byte    2,  33,  28,  21,  21,SNOP,SNOP,SNOP,SNOP,     21,SOFF,  21,  21,SOFF,  21,  21,SOFF    '13 bass

byte    0,  45,SNOP,SOFF,  45,SNOP,SOFF,  45,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '14 chords
byte    0,  45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '15 chords
                                                                                                
byte    1,  45,SNOP,SOFF,  49,SNOP,SOFF,  50,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '16 chords
byte    1,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '17 chords
byte    1,  49,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '18 chords

byte    3,   9,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '19 LOW
byte    3,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,      9,SOFF,   9,   9,SOFF,   9,   9,SOFF    '20 LOW

byte    2,   9,SNOP,SOFF,SNOP,  13,SNOP,SOFF,SNOP,     14,SNOP,SOFF,  15,SNOP,SNOP,  16,SNOP    '21 low
byte    2,SOFF,SNOP,   9,SNOP,  13,SNOP,SOFF,SNOP,     14,SNOP,SOFF,  15,SNOP,SNOP,  16,SNOP    '22 low
byte    2,   9,SOFF,   9,SOFF,  13,SOFF,  13,SOFF,     14,SOFF,  14,  15,SOFF,  15,  16,SOFF    '23 low

' break it down
byte    2,SNOP,SNOP,   9,SNOP,SNOP,  13,SNOP,SNOP,     14,SNOP,SNOP,  15,SNOP,SNOP,  16,SNOP    '24 low
byte    1,SNOP,SNOP,  21,SNOP,SNOP,  25,SNOP,SNOP,     26,SNOP,SNOP,  27,SNOP,SNOP,  28,SNOP    '25 bass

byte    0,  64,  61,  57,  55,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  57,SOFF    '26 melody again
byte    0,  57,SOFF,SNOP,  52,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  55,SOFF    '27 melody again
byte    0,  55,  52,  50,  49,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,  50,SNOP,SNOP,  52,SNOP    '28 melody again
byte    0,  45,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '29 melody again



sequence_data

byte    TEMPO, 120

byte    TRANS, 0
byte    ADSRW+%0011, 127, 0, 100, 00, SINE
byte    ADSRW+%0100, 127, 0, 100, 00, SQUARE
byte    ADSRW+%1000, 127, 60, 0, 60, NOISE

' main section

byte    0,BAROFF
byte    1,BAROFF

byte    0,2,5,BAROFF
byte    1,3,5,BAROFF
byte    0,2,5,BAROFF
byte    1,3,5,BAROFF

byte    0,2,4,5,BAROFF
byte    1,3,4,5,BAROFF

byte    NOTEOFF, 2

' drop down

byte    TRANS, 10

byte    ADSRW+%0011, 127, 0, 100, 0, SAW
byte    ADSRW+%0100, 127, 0, 100, 0, SQUARE

byte    6,8,4,5,BAROFF
byte    7,9,4,5,BAROFF
byte    6,8,4,5,BAROFF
byte    7,9,4,5,BAROFF

byte    TRANS, 8
byte    ADSRW+%1000, 127, 0, 100, 00, SQUARE

byte    10,14,16,BAROFF
byte    11,BAROFF
    
byte    TRANS, 7

byte    12,15,17,19,BAROFF
byte    13,15,18,20,BAROFF

byte    NOTEOFF, 0

' cut out into noise
    
byte    TRANS, 12
byte    ADSRW+%0011, 127, 0, 100, 0, SINE
byte    ADSRW+%0100, 127, 0, 100, 0, SAMPLE

byte    26,8,21,5,BAROFF
byte    27,9,22,5,BAROFF
byte    28,8,23,5,BAROFF
 
byte    ADSRW+%0100, 127, 0, 100, 0, SQUARE
byte    ADSRW+%0010, 127, 0, 100, 0, SQUARE

byte    29,24,25,BAROFF

' final breakdown!!!
byte    ADSRW+%0011, 127, 0, 100, 0, SINE

byte    26,2,21,5,BAROFF
byte    27,3,22,5,BAROFF
byte    28,2,23,5,BAROFF
byte    29,24,25,5,BAROFF


byte    SONGOFF

