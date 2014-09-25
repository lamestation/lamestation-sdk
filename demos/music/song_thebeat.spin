' *********************************************************
' thebeat.spin
' *********************************************************
DAT    
song_data
word    @patterns_data, @sequence_data

CON
    SONGOFF = $80
    BAROFF  = $81
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
byte    8    'bar resolution

'MAIN SECTION
byte    0,  26,SNOP,SOFF,  24,  26,SOFF,SNOP,SNOP
byte    1,  26,SOFF,  24,SOFF,  26,SOFF,  20,SOFF

byte    2,  38,SOFF,  38,SOFF,  38,SOFF,  38,SNOP
byte    2,SNOP,SNOP,SNOP,SNOP,  41,SNOP,SNOP,SNOP
byte    2,  44,SOFF,  44,SOFF,  44,SOFF,  44,SNOP
byte    2,SNOP,SNOP,SNOP,SNOP,  40,SNOP,SNOP,SNOP

byte    2,  45,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,  44,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP

sequence_data
byte    TRANS, 0
byte    TEMPO, 120

byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF

byte    0,1,2,BAROFF
byte    0,1,3,BAROFF
byte    0,1,4,BAROFF
byte    0,1,5,BAROFF
byte    0,1,6,BAROFF
byte    0,1,BAROFF
byte    0,1,7,BAROFF
byte    0,1,BAROFF
    
byte    SONGOFF

