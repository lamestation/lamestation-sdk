
    ' *********************************************************
    ' ibelieve.spin
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

    'main
    byte    50, 46, 53, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    55, 51, 46, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    58, SNOP, SNOP, SNOP, 57, SNOP, SNOP, SNOP, 55, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP
    byte    50, 46, 41, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

    'low harmony
    byte    46, 41, 50, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    51, 46, 39, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    55, SNOP, SNOP, SNOP, 53, SNOP, SNOP, SNOP, 51, SNOP, SNOP, SNOP, 48, SNOP, SNOP, SNOP
    byte    46, 41, 38, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

    'low part
    byte    22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    27, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP
    byte    31, SNOP, SNOP, SNOP, 29, SNOP, SNOP, SNOP, 27, SNOP, SNOP, SNOP, 24, SNOP, SNOP, SNOP
    byte    22, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF, SNOP

    sequence_data
    byte    TRANS, 0
    byte    TEMPO, 80
    byte    ADSRW+$F, 120, 80, 40, 110, SAW

    byte    1,0,0,0
    byte    2,0,0,0
    byte    3,0,0,0
    byte    4,0,0,0

    byte    1,5,0,0
    byte    2,6,0,0
    byte    3,7,0,0
    byte    4,8,0,0

    byte    1,5,9,0
    byte    2,6,10,0
    byte    3,7,11,0
    byte    4,8,12,0

    byte    SONGOFF
