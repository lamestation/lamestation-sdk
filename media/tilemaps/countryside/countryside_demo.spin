' *********************************************************
' countryside_demo.spin
' Level conversion by map2dat
' *********************************************************
PUB Addr
    return @map_data

DAT

map_data
word	 32, 32  'width, height

byte	147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147
byte	159,159,171,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147,147
byte	216,217,158,159,171,147,147,147,147,147,147,147,147,147,147,147,147,147,147,170,159,159,159,159,159,159,159,159,159,159,171,147
byte	100,225,216,217,158,171,147,147,147,170,159,159,159,159,159,171,147,170,159,160,  2,215,216,216,216,216,216,216,216,217,158,159
byte	100,100,100,225,217,158,159,159,159,160,  2,137,138,212,140,158,159,160,215,216,217,227,100,100,100,100,100,100,100,225,216,216
byte	100,100,100,100,225,217,  2,  2,134,136,  2,149,150,151,152,  2,  2,215,226,100,229,239,240,240,214,100,100,100,100,100,100,100
byte	214,100,100,100,100,229,  2,  2,146,148,  2,161,162,163,164,  2,215,226,100,100,229,  2,  2,  2,239,240,240,240,240,240,240,240
byte	239,240,214,100,100,225,217,  2,158,160,  2,173,175,173,173,  2,227,100,100,213,241,  2,134,135,136,  2,  2,153,154,155, 91, 91
byte	 91, 92,239,214,100,100,229,  2,  2,172,  2,  2,  4,141,  2,  2,239,240,240,241,  2,  2,146,147,148,  2,  2,165, 38,167,103,103
byte	103, 79, 92,239,214,221,154,155,  2,184,  2,  2,  4,  2,  2,  2,  2,  2, 90, 91, 92,172,146,147,182,136,  2,177,178,179,103,103
byte	154,154,154,154,154,165, 38,167,  3,  4,  4,  4,  4,  2, 90, 91, 91, 91, 80,103,104,184,158,171,147,182,136,189,190,191,103,103
byte	178,178,178,178,178,177,178,179,  2,  2,  2,  2,  4,  2,102,103,103, 67,115, 68,104,  2,  2,158,171,147,148,201,202,203,103,103
byte	202,202,202,202,202,189,190,191, 90, 91, 92,  2,  4,  4,  4,  4,  4,  4,  4, 80, 79, 92,  2,  2,146,147,182,136, 90, 91,103,103
byte	103,103,103,103, 79,201,202,203,102,103, 79, 91,  4,  2,114,115, 68,103,  4,  4,  4,  4,  2,  2,158,171,147,148,102,103,103,103
byte	 68,103,103,103,103, 79, 92,172,246,246,246,115,  4,  2,246,233,102,103,103,103,103,  4,  4,  2,  2,146,147,148,114,115, 68,103
byte	102,103,103,103,103,103, 79,184, 80, 79, 92,145,  4,  2,  2,245,246,246,246,103,103,103,  4,  2,  2,158,171,182,135,136,102,103
byte	114,115,115, 68,103,103,103,103,103,103, 79, 91,  4,  2, 90, 92,  2,102,103,103,103,103,104,  4,  2,  2,158,171,147,148,102,103
byte	135,135,136,114,115,115, 68,103,103,103,103,103,  4,  4,102, 79, 91, 80, 67, 68,103,103,104,  4,  4,  2,  2,158,159,160,114,115
byte	147,147,182,135,135,136,114, 68,103,103,103,103,103,  4,  4,115,115,115,116,102,103,103,104,  2,  4,  4,134,135,136,  2,  2,  2
byte	171,147,147,147,147,182,136,114,115, 68,103,103, 67,115,  4,  4,  2,  2, 90, 80, 67,115,116,  2,  2,  2,146,147,182,135,136,  2
byte	183,147,147,147,147,147,182,135,136,114,115,115,116,  2,  2,  4,  2,  2,102, 67,116,215,216,217,  2,172,146,147,147,147,148,  2
byte	147,147,147,147,147,147,147,147,182,136,  2,  2,  2,  2,  3,  2,  2,172,114,116, 60,226,100,229,  2,184,146,147,147,147,182,135
byte	171,147,147,147,147,147,147,147,147,148,  2,  2,  3,  3,  2,  2,  2,184,215,216, 60,100,213,241,134,135,183,147,147,147,147,147
byte	146,147,147,147,147,147,147,147,147,182,136,  3,  3,  2,  2, 90, 92,215,226,100, 60,213,241,  2,146,147,147,147,147,147,147,147
byte	158,171,147,147,147,147,147,147,147,147,148,  3,  2, 90, 91, 80,104,227,100,100, 60,241,134,135,183,147,147,147,147,147,147,147
byte	  2,146,147,147,147,147,147,147,147,147,148,  3,  2,102,103, 67,116,227,100,213, 60,134,183,147,147,147,147,147,147,147,147,147
byte	  2,158,159,159,171,147,147,147,147,147,148,  3,  2,102, 72, 72, 72, 72, 72, 72,  2,146,147,147,147,147,147,147,147,147,147,147
byte	  2,  2,  2,  2,146,147,147,147,147,170,160,  3,  2,102,104,141,227,100,100,225,217,158,171,147,147,147,147,147,147,147,147,170
byte	  2, 90, 91, 92,158,171,147,147,170,160,  2,  3,  2,102,104,  2,227,100,100,100,225,217,158,171,147,147,147,147,147,147,147,182
byte	 91, 80,103, 79, 92,158,159,159,160,172,  2,  3, 90, 80, 79, 92,227,100,100,100,100,225,217,158,171,147,147,147,147,147,147,147
byte	103,103,103,103, 79, 91, 91, 92,  2,184,  3,  2,102,103,103, 92,227,100,100,100,100,100,225,217,146,147,147,147,147,147,147,147
byte	103,103,103,103,103,103,103,104,  2,  3,  3,  2,102,103,103,104,227,100,100,100,100,100,100,229,146,147,147,147,147,147,147,147
