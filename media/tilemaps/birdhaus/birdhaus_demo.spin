' *********************************************************
' birdhaus_demo.spin
' Level conversion by map2dat
' *********************************************************
PUB Addr
    return @map_data

DAT

map_data
word	  8,  4  'width, height

byte	  2,  2,  2,  2,  8,  2,  2,  2
byte	  1,  1,  1,  1,  1,  1,  4,  1
byte	  3,  3,  3,  3,  4,  3,  6,  3
byte	  5,  5,  5,  5,  5,  5,  5,  5
