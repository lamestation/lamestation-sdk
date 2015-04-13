' 06_music/song_proppaly_awesome.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
' *********************************************************
' proppaly_awesome.spin
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
byte    16    'bar resolution

'MAIN SECTION
byte      61,SOFF,  57,SOFF,  59,SOFF,  57,SOFF,     61,SOFF,  57,  59,SNOP,  59,  57,  57    '1  melody
byte      61,  61,  57,  57,  59,SOFF,  57,SOFF,     61,SOFF,  57,  59,SNOP,  59,  57,  57    '2  melody

byte      45,SNOP,SOFF,SNOP,  40,SNOP,SOFF,SNOP,     37,SNOP,SOFF,  38,SNOP,SNOP,  40,SNOP    '3  low
byte    SOFF,SNOP,  33,SNOP,  37,SNOP,SNOP,SNOP,     38,SNOP,SOFF,  38,SNOP,  37,  33,SNOP    '4  low

byte      21,SNOP,SOFF,SNOP,  28,SNOP,SOFF,SNOP,     25,SNOP,SOFF,  26,SNOP,SNOP,  28,SNOP    '5  bass

byte    SNOP,SNOP,  40,SOFF,SNOP,SNOP,  40,SOFF,   SNOP,SNOP,  40,  40,SOFF,  40,  40,SOFF    '6  snare

byte    SOFF,SNOP,  45,  45,SOFF,SNOP,  45,SOFF,   SNOP,SNOP,  45,  45,SOFF,  45,  45,SOFF    '7  chords
byte    SOFF,SNOP,  45,  45,SOFF,SNOP,  45,SOFF,     45,SNOP,SOFF,  45,SNOP,SOFF,  45,SOFF    '8  chords
byte    SOFF,SNOP,  49,  49,SOFF,SNOP,  49,SOFF,   SNOP,SNOP,  49,  49,SOFF,  49,  49,SOFF    '9  chords
byte    SOFF,SNOP,  49,  49,SOFF,SNOP,  49,SOFF,     50,SNOP,SOFF,  50,SNOP,SOFF,  49,SOFF    '10 chords



byte      21,SOFF,SNOP,  25,SOFF,SNOP,  26,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '11 bass
byte      25,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,     21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '12 bass
byte      21,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  28    '13 bass
byte      33,  28,  21,  21,SNOP,SNOP,SNOP,SNOP,     21,SOFF,  21,  21,SOFF,  21,  21,SOFF    '14 bass

byte      45,SNOP,SOFF,  45,SNOP,SOFF,  45,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '15 chords
byte      45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '16 chords
                                                                                              
byte      45,SNOP,SOFF,  49,SNOP,SOFF,  50,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '17 chords
byte      50,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '18 chords
byte      49,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF    '19 chords

byte       9,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '20 LOW
byte    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,      9,SOFF,   9,   9,SOFF,   9,   9,SOFF    '21 LOW

byte       9,SNOP,SOFF,SNOP,  13,SNOP,SOFF,SNOP,     14,SNOP,SOFF,  15,SNOP,SNOP,  16,SNOP    '22 low
byte    SOFF,SNOP,   9,SNOP,  13,SNOP,SOFF,SNOP,     14,SNOP,SOFF,  15,SNOP,SNOP,  16,SNOP    '23 low
byte       9,SOFF,   9,SOFF,  13,SOFF,  13,SOFF,     14,SOFF,  14,  15,SOFF,  15,  16,SOFF    '24 low

                                                                                              ' break it down

byte    SNOP,SNOP,   9,SNOP,SNOP,  13,SNOP,SNOP,     14,SNOP,SNOP,  15,SNOP,SNOP,  16,SNOP    '25 low
byte    SNOP,SNOP,  21,SNOP,SNOP,  25,SNOP,SNOP,     26,SNOP,SNOP,  27,SNOP,SNOP,  28,SNOP    '26 bass

byte      64,  61,  57,  55,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  57,SOFF    '27 melody again
byte      57,SOFF,SNOP,  52,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,  55,SOFF    '28 melody again
byte      55,  52,  50,  49,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,  50,SNOP,SNOP,  52,SNOP    '29 melody again
byte      45,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,   SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP    '30 melody again



sequence_data

byte    TEMPO, 120

byte    TRANS, 0
byte    ADSRW+%0011, 127, 0, 100, 00, SINE
byte    ADSRW+%0100, 127, 0, 100, 00, SQUARE
byte    ADSRW+%1000, 127, 60, 0, 60, NOISE

' main section

byte      1,  0,  0,  0
byte      2,  0,  0,  0
byte      1,  3,  0,  6
byte      2,  4,  0,  6

byte      1,  3,  5,  6
byte      2,  4,  5,  6
byte      1,  3,  5,  6
byte      2,  4,  5,  6

' drop down

byte    TRANS, 10

byte    ADSRW+%0011, 127, 0, 100, 0, SAW
byte    ADSRW+%0100, 127, 0, 100, 0, SQUARE

byte      7,  9,  5,  6
byte      8, 10,  5,  6
byte      7,  9,  5,  6
byte      8, 10,  5,  6

byte    TRANS, 8
byte    ADSRW+%1000, 127, 0, 100, 00, SQUARE

byte     11, 15, 17,  0
byte     12, 15, 17,  0
    
byte    TRANS, 7

byte     13, 16, 18, 20
byte     14, 16, 19, 21

' cut out into noise

byte    ADSRW+%1000, 127, 60, 0, 60, NOISE
    
byte    TRANS, 12
byte    ADSRW+%0011, 127, 0, 100, 0, SINE
byte    ADSRW+%0100, 127, 0, 100, 0, SAMPLE

byte     27,  9, 22,  6
byte     28, 10, 23,  6
byte     29,  9, 24,  6
 
byte    ADSRW+%0110, 127, 0, 100, 0, SQUARE

byte     30, 25, 26,  0

' final breakdown!!!

byte    ADSRW+%0011, 127, 0, 100, 0, SQUARE

byte     27,  3, 22,  6
byte     28,  4, 23,  6
byte     29,  3, 24,  6
byte     30, 25, 26,  6


byte    SONGOFF


