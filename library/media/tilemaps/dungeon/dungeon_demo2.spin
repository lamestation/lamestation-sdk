' *********************************************************
' dungeon_demo2.spin
' Level conversion by map2dat
' *********************************************************
PUB Addr
    return @map_data

DAT

map_data
word	 32, 32  'width, height

byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
byte	129,129,129,129,129,129,134,135,135,136,129,129,134,135,135,136,129,129,129,129,129,129,129,129,129,134,135,  9,135,136,129,129
byte	129,129,129,129,134,135,155, 12, 12,154,135,135,155, 12, 12,154,135,136,129,134,135,133,135,132,135,155, 12, 12, 12,141,129,129
byte	129,129,129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129
byte	129,129,129,134,155, 12, 12, 12, 12, 12, 12, 14, 12, 12, 12, 12, 12,154,136,139, 12, 12, 12,149,145,150, 12, 12, 12,141,129,129
byte	129,129,129,139, 12, 12, 12,149,150, 12, 12, 12, 12,149,150, 12, 12, 12,141,139, 12, 12, 12,141,129,144,150, 12, 12,141,129,129
byte	129,129,129,139, 12, 12, 12,154,155, 12, 12, 12, 12,154,155, 12, 12, 12,141,139, 12, 12, 12,141,129,129,139, 12, 12,141,129,129
byte	129,129,129,144,150, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,149,146,139, 12, 12, 12,141,129,129,139, 12, 12,141,129,129
byte	129,129,129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,139, 12, 12, 12,141,129,129,139, 12,149,146,129,129
byte	129,129,129,129,139, 12, 12, 12, 12, 12,147,148, 12, 12, 12, 12, 12,141,129,139, 12, 12, 12,141,129,129,139, 12,141,129,129,129
byte	129,129,129,134,155, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,154,136,139, 12, 12, 12,141,129,129,139, 12,141,129,129,129
byte	129,129,129,139, 12, 12, 12,149,150, 12, 12, 12, 12,149,150, 12, 12, 12,141,139, 12, 12, 12,141,129,129,139, 12,141,129,129,129
byte	129,129,129,139, 12, 12, 12,154,155, 12, 12, 12, 12,154,155, 12, 12, 12,141,144,150, 12,149,146,129,129,139, 12,141,129,129,129
byte	129,129,129,144,150, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,149,146,129,139, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,139, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,129,129,144,145,150, 12, 12,149,145,145,150, 12, 12, 12, 12,141,129,129,139, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,129,129,129,129,144,145,145,146,129,129,144,145,150, 12, 12,141,129,129,139, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,134,135,135,  9,135,135,135,135,135,135,135,133,155, 12, 12,154,133,135,155, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,141,129,129,129,139, 12,141,129,129,129
byte	129,129,139, 12, 12, 12, 12, 12,149,145,145,145,150, 12, 12, 12, 12, 12, 12,149,145,145,146,129,129,129,139, 12,141,129,129,129
byte	129,129,144,145,150, 12,149,145,146,129,129,129,144,145,145,145,145,145,145,146,129,129,129,129,129,129,139, 12,141,129,129,129
byte	129,129,129,129,139, 12,141,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,139, 12,141,129,129,129
byte	129,129,129,129,139, 12,141,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,134,135,155, 12,154,136,129,129
byte	129,129,134,135,155, 12,154,135,136,129,129,129,134,135,133,135,138,135,133,135,136,129,129,129,139, 12, 12, 12, 12,141,129,129
byte	129,129,139, 12, 12, 12, 12, 12,154,135,133,135,155, 12, 12, 12, 12, 12, 12, 12,154,135,133,135,155, 12, 12, 12, 12,141,129,129
byte	129,129,139, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 15, 12,141,129,129
byte	129,129,139, 12, 12, 12, 12, 12,149,145,145,145,150, 12, 12, 12, 12, 12, 12, 12,149,145,145,145,150, 12, 12, 12, 12,141,129,129
byte	129,129,144,145,145,145,145,145,146,129,129,129,144,145,145,145,145,145,145,145,146,129,129,129,144,145,145,145,145,146,129,129
byte	129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129,129