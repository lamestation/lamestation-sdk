CON
    DIR_LEFT = 0
    DIR_STRAIGHT = 1
    DIR_RIGHT = 2
    END_TRACK = 5
    
    MAX_LEVELS = 6
    
    #0, UP, RIGHT, DOWN, LEFT
    #0, DAY, NIGHT, DUSK

DAT
    levels  word    0[MAX_LEVELS]

PUB Start

    levels[0] := @level1
    levels[1] := @level2
    levels[2] := @level3
    levels[3] := @level4

PUB GetLevel(index)

    return levels[index]

PUB GetMax

    return MAX_LEVELS

DAT

level1
byte    10, 54, UP, DAY

byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    END_TRACK

level2
byte    16, 48, UP, DAY

byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    END_TRACK

level3
byte    5, 48, UP, NIGHT

byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    END_TRACK

level4
byte    16, 54, RIGHT, DAY

byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    END_TRACK
