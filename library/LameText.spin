CON
    NL = 10
    LF = 13

OBJ
    gfx : "LameGFX"

DAT

    font            word    0
    lock            byte    0
    startingchar    byte    0
    tile_w          byte    0
    tile_h          byte    0

PUB Load(source, start, w, h)
{{
    Load a font into LameText.

    - *source* - A LameGFX sprite containing the font character graphics.
    - *start* - The ASCII number of the first character in the character map.
    - *w*, *h* - The width and height of each character.
}}

    font := source 
    startingchar := start

    ifnot tile_w := w
        tile_w := word[font][gfx#SX]
    ifnot tile_h := h
        tile_h := word[font][gfx#SY]

PUB Char(char_byte, x, y)
{{
    Draw a character at position (x,y).
}}

    gfx.Sprite(font, x, y, char_byte - startingchar)

PUB Str(stringvar, x, y)
{{
    Draw a string at position (x,y).
}}

    repeat strsize(stringvar)
        gfx.Sprite(font, x, y, byte[stringvar++] - startingchar)
        x += tile_w

PUB Box(stringvar, x, y, w, h) | c, dx, dy
{{
    Draw text a position (x,y) with a width `w`.
}}

    dx := x
    dy := y

    repeat strsize(stringvar)
        c := byte[stringvar++]
        if c == NL or c == LF
            dy += tile_h
            dx := x
        elseif c == " "
            dx += tile_w
        else
            gfx.Sprite(font, dx, dy, c - startingchar)
            if dx + tile_w => x + w
                dy += tile_h
                dx := x
            else
                dx += tile_w

PUB Dec(value, x, y) | i, d
{{
    Draw a decimal number at position (x,y).
}}

    d := value == NEGX
    if value < 0
        value := ||(value+d)
        Char("-", x, y)
        x += tile_w
    
    i := 1_000_000_000
    
    repeat 10
        if value => i
            Char(value / i + "0" + d*(i == 1), x, y)
            x += tile_w
            value //= i
            result~~
        elseif result or i == 1
            Char("0", x, y)
            x += tile_w
        i /= 10
    
PUB Bin(value, digits, x, y)
{{
    Draw a binary number at position (X,y).
}}

    value <<= 32 - digits
    repeat digits
        Char((value <-= 1) & 1 + "0", x, y)
        x += tile_w

PUB Hex(value, digits, x, y)
{{
    Draw a hexadecimal number with `digits` digits at position (x,y).
}}

    value <<= (8 - digits) << 2
    repeat digits
        Char(lookupz((value <-= 4) & $F : "0".."9", "A".."F"), x, y)
        x += tile_w
