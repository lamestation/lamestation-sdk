' *********************************************************
' zeroforce.spin
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
    
    #1,     DRUM1, DRUM2, DRUM3
    #4,     RHYTHM
    #5,     MELODY1, MELODY2, MELODY3, MELODY4, MELODY5, MELODY6
    #11,    BASS1, BASS2, BASS3
    #14,    MELODY7, MELODY8, MELODY9, MELODY10, MELODY11, MELODY12
    #20,    BASS4, BASS5, BASS6, BASS7, BASS8
    #25,    ENDING1, ENDING2, ENDING3, ENDING4

PUB Addr
    result.word[1] := @@0
    result.word{0} := @song_data

DAT

patterns_data
byte    16      'bar resolution


byte    SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF
byte    SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF,   26, SOFF,   26, SOFF
byte    SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26,   26,   26,   26,   26,   26

' main harmony
byte      52,   50,   45,   50,   52,   50,   45,   50,   52,   50,   45,   50,   52,   50,   45,   50


'melody 
byte      33, SNOP, SNOP, SNOP, SNOP, SNOP,   38, SNOP, SNOP, SNOP, SNOP, SNOP,   40, SNOP, SNOP, SNOP
byte      43, SNOP, SNOP, SNOP,   42, SNOP,   40, SNOP, SNOP, SNOP,   38, SNOP, SNOP, SNOP, SNOP, SNOP
byte      33, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP
byte    SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP

byte      45, SNOP, SNOP, SNOP, SNOP, SNOP,   43,   42,   40, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP
byte    SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP

' bass
byte      26, SNOP,   26, SNOP, SNOP, SNOP,   26, SNOP, SNOP, SNOP,   26,   26,   26,   26,   26,   26
byte      24, SNOP,   24, SNOP, SNOP, SNOP,   24, SNOP, SNOP, SNOP,   24,   24,   24,   24,   24,   24
byte      25, SNOP,   25, SNOP, SNOP, SNOP,   25, SNOP, SNOP, SNOP,   25,   25,   25,   25,   25,   25

' second part
byte      45, SNOP, SNOP, SNOP, SNOP, SNOP,   42, SNOP, SNOP, SNOP,   43, SNOP,   45, SNOP, SNOP, SNOP
byte      43, SNOP, SNOP, SNOP, SNOP, SNOP,   42, SNOP, SNOP, SNOP, SNOP, SNOP,   45, SNOP, SNOP, SNOP
byte      43, SNOP, SNOP, SNOP, SNOP, SNOP,   42, SNOP, SNOP, SNOP, SNOP, SNOP,   38, SNOP, SNOP, SNOP
byte      34, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP

byte      43, SNOP, SNOP, SNOP,   42, SNOP,   40, SNOP, SNOP, SNOP,   45, SNOP, SNOP, SNOP, SNOP, SNOP
byte      38, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP

' second bass
byte      23, SNOP,   23, SNOP, SNOP, SNOP,   23, SNOP, SNOP, SNOP,   23,   23,   23,   23,   23,   23
byte      22, SNOP,   22, SNOP, SNOP, SNOP,   22,   22,   18, SNOP,   18, SNOP, SNOP, SNOP,   18, SNOP
byte      21, SNOP,   21, SNOP, SNOP, SNOP,   21, SNOP, SNOP, SNOP,   21, SNOP,   21, SNOP,   21, SNOP
byte      20, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP

byte      21,   21, SNOP,   21,   21,   21, SNOP,   21,   21,   21, SNOP,   21,   21,   21, SNOP,   21

'ending
byte      26, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26,   26,   26,   26,   26,   26
byte      26, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF, SNOP, SNOP,   26, SOFF,   26, SOFF,   26, SOFF

byte      38, SNOP,   38, SOFF, SNOP, SNOP,   38, SOFF, SNOP, SNOP,   38,   38,   38,   38,   38,   38
byte      38, SNOP,   38, SOFF, SNOP, SNOP,   38, SOFF, SNOP, SNOP,   38, SOFF,   38, SOFF,   38, SOFF


sequence_data
byte    TRANS, 12
byte    TEMPO, 150
byte    ADSRW+%0001, 127, 100, 127, 100, TRIANGLE
byte    ADSRW+%0010, 127, 100, 127, 100, SAW
byte    ADSRW+%0100, 127,  30,   0,  30, SQUARE
byte    ADSRW+%1000, 127,  40,  30,  40, NOISE


byte    4,0,0,1
byte    4,0,0,2
byte    4,0,0,1
byte    4,0,0,3

' verse 1
byte    RHYTHM,     MELODY1,    0,  DRUM1
byte    RHYTHM,     MELODY2,    0,  DRUM2
byte    RHYTHM,     MELODY3,    0,  DRUM1
byte    RHYTHM,     MELODY4,    0,  DRUM3

byte    RHYTHM,     MELODY1,    0,  DRUM1
byte    RHYTHM,     MELODY2,    0,  DRUM2
byte    RHYTHM,     MELODY5,    0,  DRUM1
byte    RHYTHM,     MELODY6,    0,  DRUM3

' chorus
byte    RHYTHM,     MELODY7,    0,  DRUM1
byte    RHYTHM,     MELODY8,    0,  DRUM2
byte    RHYTHM,     MELODY9,    0,  DRUM1
byte    RHYTHM,     MELODY10,   0,  DRUM3

byte    RHYTHM,     MELODY1,    0,  DRUM1
byte    RHYTHM,     MELODY11,   0,  DRUM2
byte    RHYTHM,     MELODY12,   0,  DRUM1
byte    RHYTHM,     MELODY12,   0,  DRUM3

' verse 2
byte    RHYTHM,     MELODY1,    BASS1,  DRUM1
byte    RHYTHM,     MELODY2,    BASS1,  DRUM2
byte    RHYTHM,     MELODY3,    BASS1,  DRUM1
byte    RHYTHM,     MELODY4,    BASS1,  DRUM3

byte    RHYTHM,     MELODY1,    BASS1,  DRUM1
byte    RHYTHM,     MELODY2,    BASS1,  DRUM2
byte    RHYTHM,     MELODY5,    BASS2,  DRUM1
byte    RHYTHM,     MELODY6,    BASS3,  DRUM3

' chorus
byte    MELODY7,    BASS4,      MELODY7,  DRUM1
byte    MELODY8,    BASS5,      MELODY8,  DRUM2
byte    MELODY9,    BASS6,      MELODY9,  DRUM1
byte    MELODY10,   BASS7,      MELODY10, DRUM3

byte    RHYTHM,     MELODY1,    BASS8,  DRUM1
byte    RHYTHM,     MELODY11,   BASS8,  DRUM2
byte    RHYTHM,     MELODY12,   BASS1,  DRUM1
byte    RHYTHM,     MELODY12,   BASS1,  DRUM3

byte    0,  ENDING3,  ENDING1, ENDING1
byte    0,  ENDING4,  ENDING2, ENDING2
'byte    0,  0,  0,  0


byte    SONGOFF

