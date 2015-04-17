
    ' *********************************************************
    ' tankbattle.spin
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
    byte    8       'bar resolution

    'ROOT BASS
    byte     36,SOFF,  36,SOFF,   34,  36,SOFF,  34
    byte     24,SOFF,  24,SOFF,   22,  24,SOFF,  22

    'DOWN TO SAD
    byte     32,SNOP,  32,SOFF,   31,  32,SOFF,  31
    byte     20,SNOP,  20,SOFF,   19,  20,SOFF,  19

    'THEN FOURTH
    byte     29,SNOP,  29,SOFF,   27,  29,SOFF,  27
    byte     17,SNOP,  17,SOFF,   15,  17,SOFF,  15

    byte       48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
    byte     SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
    byte       53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
    byte     SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP

    'melody
    byte       48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
    byte     SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF

    'harmonies
    byte       44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
    byte     SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
    byte     SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF

    sequence_data
    byte    TRANS, 0
    byte    TEMPO, 180
    byte    ADSRW+$F, 127, 30, 100, 30, SAW

    byte    1,0,0,0
    byte    1,0,0,0
    byte    1,0,0,0
    byte    1,0,0,0
    byte    1,2,0,0
    byte    1,2,0,0
    byte    1,2,0,0
    byte    1,2,0,0
    'verse
    byte    1,2,7,0
    byte    1,2,8,0
    byte    1,2,9,0
    byte    1,2,10,0
    byte    3,4,11,13
    byte    3,4,11,14
    byte    5,6,0,0
    byte    5,6,12,15
    'verse
    byte    1,2,7,0
    byte    1,2,8,0
    byte    1,2,9,0
    byte    1,2,10,0
    byte    3,4,11,13
    byte    3,4,11,14
    byte    5,6,0,0
    byte    5,6,12,15

    byte    SONGOFF

