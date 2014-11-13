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
byte    1,SOFF,SNOP,  49,  49,SOFF,SNOP,  49,SOFF,   SNOP,SNOP,  49,  49,SOFF,  49,  49,SOFF    '7  chords

byte    2,  21,SOFF,SNOP,  25,SOFF,SNOP,  26,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '8  bass
byte    2,  25,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,     21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '9  bass
byte    2,  21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  28    '10 bass
byte    2,  33,  28,  21,  21,SNOP,SNOP,SNOP,SNOP,     21,SOFF,  21,  21,SOFF,  21,  21,SOFF    '11 bass

byte    0,  45,SNOP,SOFF,  45,SNOP,SOFF,  45,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '12 chords
byte    0,  45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '13 chords
                                                                                                
byte    1,  45,SNOP,SOFF,  49,SNOP,SOFF,  50,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '14 chords
byte    1,  50,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '15 chords
byte    1,  49,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '16 chords


sequence_data
byte    TRANS, 0
byte    TEMPO, 120
byte    ADSRW+%0001, 127, 0, 100, 00, SINE
byte    ADSRW+%0010, 127, 0, 100, 00, SINE
byte    ADSRW+%0100, 127, 0, 100, 00, SQUARE
byte    ADSRW+%1000, 127, 60, 0, 60, NOISE

    
{{
byte    0,BAROFF
byte    1,BAROFF

byte    0,2,5,BAROFF
byte    1,3,5,BAROFF
byte    0,2,5,BAROFF
byte    1,3,5,BAROFF
}}
byte    0,2,4,5,BAROFF
byte    1,3,4,5,BAROFF

byte    NOTEOFF, 2

byte    TRANS, 10
byte    ADSRW+%0011, 127, 0, 100, 0, SAW
byte    ADSRW+%0100, 127, 0, 100, 0, SQUARE

byte    6,7,4,5,BAROFF
byte    6,7,4,5,BAROFF

byte    TRANS, 8

byte    8,12,14,BAROFF
byte    9,BAROFF
    
byte    TRANS, 7

byte    10,13,15,BAROFF
byte    11,13,16,BAROFF

byte    TRANS, 0
    
byte    SONGOFF

