
    ' *********************************************************
    ' lastboss.spin
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
    byte    12     'notes/bar

    'MAIN SECTION
    '0-5
    byte    45,41,40,45,41,40,45,41,40,45,41,40
    byte    46,43,42,46,43,42,46,43,42,46,43,42

    byte    26,SNOP,SNOP,29,SNOP,SNOP,28,SNOP,SNOP,29,SNOP,SNOP
    byte    25,SNOP,SNOP,26,SNOP,SNOP,27,SNOP,SNOP,21,SNOP,SNOP

    'SONG ------
    sequence_data
    byte    TRANS, 0
    byte    TEMPO, 150
    byte    ADSRW+$F, 127, 100, 40, 100, SAW

    byte    1,3,0,0
    byte    2,4,0,0
    byte    1,3,0,0
    byte    2,4,0,0
    byte    1,3,0,0
    byte    2,4,0,0
    byte    1,3,0,0
    byte    2,4,0,0

    byte    SONGOFF

