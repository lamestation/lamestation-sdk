' *********************************************************
' song_frappy.spin
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
byte    32    'bar resolution

'MAIN SECTION
byte      63,SNOP,  75,  74,SOFF,  70,SOFF,  67,SNOP,SNOP,SNOP,SNOP,  68,  67,  68,  70,      63,SNOP,  75,  73,SOFF,  70,SOFF,  68,SNOP,SNOP,SNOP,SNOP,  68,  70,  68,  67
byte      39,  51,  50,  43,  44,  46,  44,  43,  39,  51,  50,  43,  44,  43,  39,  35,      39,  51,  50,  39,  41,  42,  41,  39,  27,  51,  49,  46,  53,  49,  49,  51
byte      27,SNOP,  39,SNOP,SOFF,  27,SOFF,  27,SNOP,SNOP,  39,SOFF,  25,SOFF,  25,SOFF,      23,SNOP,  35,SNOP,SOFF,  23,SOFF,  23,SNOP,  35,  25,SOFF,  27,SOFF,  37,SNOP
byte    SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,  40,SNOP,    SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,  40,  40

byte      63,SNOP,  75,  74,SOFF,  70,SOFF,  67,SNOP,SNOP,SNOP,SNOP,  68,  67,  68,  70,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte      39,  51,  50,  43,  44,  46,  44,  43,  39,  51,  50,  43,  44,  43,  39,  42,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte      27,SNOP,  39,SNOP,SOFF,  27,SOFF,  27,SNOP,SNOP,  39,SOFF,  25,  25,  25,  23,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,SOFF,  40,    SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

sequence_data
byte    TRANS, 0
byte    TEMPO, 80
byte    ADSRW+%0111, 127, 10, 100, 10, SQUARE
byte    ADSRW+%1000, 127, 100, 100, 100, NOISE

byte    1,2,3,4
byte    5,6,7,8

byte    SONGOFF
