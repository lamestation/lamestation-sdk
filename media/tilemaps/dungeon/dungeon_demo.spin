' *********************************************************
' dungeon_demo.spin
' Level conversion by map2dat
' *********************************************************
PUB Addr
    return @map_data

DAT

map_data
word	 32, 32  'width, height

byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,134,135,135,132,135,135,133,135,135,133,135,135,136,129
byte	129,129,134,133,136,129,134,133,136,129,134,133,136,129,134,133,136,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129
byte	129,134,155, 12,154,135,155, 12,154,135,155, 12,154,135,155, 12,154,135,155, 12, 12, 12, 12,149,150, 12, 12,149,150, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,139, 12, 15,141,139, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,144,145,145,146,139, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,139, 12,141,129
byte	129,139, 12, 12,149,145,145,145,145,145,145,145,150, 12, 12, 12,149,145,145,150, 12, 12, 12,154,135,135,135,135,155, 12,141,129
byte	129,139, 12, 12,141,129,129,129,129,129,129,129,139, 12,149,145,146,129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129
byte	129,139, 12, 12,141,134,135,  9,135,135,  9,135,155, 12,154,135,135,136,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,144,145,145,145,145,145,145,145,150, 12, 12,141,129
byte	129,139, 12, 12,141,139,147,148, 12,147,148, 12, 12, 12, 12,147,148,141,129,129,129,129,129,129,129,129,129,139, 12, 12,141,129
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,129,129,129,129,144,150, 12,141,129
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,129,129,129,129,129,139, 12,141,129
byte	129,139, 12, 12,141,139,147,148, 12,147,148, 12, 12, 12, 12,147,148,141,129,129,129,129,129,134,135,135,135,136,139, 12,141,129
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,139, 12, 12, 12,141,139, 12,141,129
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,139, 12, 12, 12,141,139, 12,141,129
byte	129,139, 12, 12,141,139,147,148, 12,147,148, 12, 12, 12, 12,147,148,141,129,129,129,129,129,139, 12, 12, 12,154,155, 12,154,136
byte	129,139, 12, 12,141,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,139, 12, 12, 12, 12, 12, 12, 12,141
byte	129,139, 12, 12,141,144,145,145,145,145,145,145,150, 12, 12, 12,149,146,129,129,129,129,129,139, 12, 12, 12,149,150, 12,149,146
byte	129,139, 12, 12,154,135,135,  9,135,135,  9,135,155, 12, 12, 12,141,129,129,129,129,129,129,139, 12, 12, 12,141,139, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,129,144,145,145,145,146,139, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,129,129,129,129,129,129,129,129,139, 12,141,129
byte	129,139, 12,  3,  3,  3,  3,  3, 12,149,145,145,150, 12, 12, 12,141,134,133,136,129,129,129,129,129,129,129,129,139, 12,141,129
byte	129,139, 12,  3,  2,  2,  2,  3, 14,141,134,135,155, 12, 12, 12,154,155, 12,154,136,129,129,134,138,136,129,129,139, 12,141,129
byte	129,139, 12,  3,  3,  3,  3,  3, 12,154,155, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,134,155, 12,154,136,129,139, 12,141,129
byte	129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,139, 12, 12, 12,141,129,139, 12,141,129
byte	129,144,145,145,145,145,145,145,145,145,150, 12, 12, 12, 12, 12, 12, 12, 12, 12,154,135,155, 12, 12, 12,154,135,155, 12,141,129
byte	129,129,129,129,129,129,129,129,129,129,144,145,150, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,144,145,145,145,145,145,145,145,145,145,145,145,145,145,145,145,145,145,146,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
