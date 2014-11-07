' *********************************************************
' song_frappy.spin
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
byte    32    'bar resolution

'MAIN SECTION
byte    0,  63,SNOP,  75,  74,SOFF,  70,SOFF,  67,SNOP,SNOP,SNOP,SNOP,  68,  67,  68,  70,      63,SNOP,  75,  73,SOFF,  70,SOFF,  68,SNOP,SNOP,SNOP,SNOP,  68,  70,  68,  67
byte    1,  39,  51,  50,  43,  44,  46,  44,  43,  39,  51,  50,  43,  44,  43,  39,  35,      39,  51,  50,  39,  41,  42,  41,  39,  27,  51,  49,  46,  53,  49,  49,  51
byte    2,  27,SNOP,  39,SNOP,SOFF,  27,SOFF,  27,SNOP,SNOP,  39,SOFF,  25,SOFF,  25,SOFF,      23,SNOP,  35,SNOP,SOFF,  23,SOFF,  23,SNOP,  35,  25,SOFF,  27,SOFF,  37,SNOP
byte    3,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,  40,SNOP,    SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,  40,  40

byte    0,  63,SNOP,  75,  74,SOFF,  70,SOFF,  67,SNOP,SNOP,SNOP,SNOP,  68,  67,  68,  70,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    1,  39,  51,  50,  43,  44,  46,  44,  43,  39,  51,  50,  43,  44,  43,  39,  42,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    2,  27,SNOP,  39,SNOP,SOFF,  27,SOFF,  27,SNOP,SNOP,  39,SOFF,  25,  25,  25,  23,    SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
byte    3,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,SOFF,SOFF,  40,SOFF,  40,SOFF,SOFF,  40,    SNOP,SOFF,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP,SNOP
        
sequence_data
byte    TRANS, 0
byte    TEMPO, 80
'byte    ADSRW+$F, 127, 10, 100, 10, SQUARE

byte    0,1,2,3,BAROFF
byte    4,5,6,7,BAROFF

byte    SONGOFF


{{    
    audio.SetWaveform(3,audio#_NOISE)
    audio.SetEnvelope(0,1)
    audio.SetEnvelope(1,1)
    audio.SetEnvelope(2,1)
    audio.SetEnvelope(3,1)
    audio.SetADSR(3, 127, 100, 0, 100)
    music.LoadSong(theme.Addr)
    music.PlaySong
    }}
