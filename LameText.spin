CON

    NL = 10
    LF = 13

OBJ
    gfx :   "LameGFX"

DAT

font            word    0
lock            byte    0
startingchar    byte    0
tile_w          byte    0
tile_h          byte    0

PUB Load(font_addr, start_char, tile_width, tile_height)

    font := font_addr
    startingchar := start_char
    ifnot tile_w := tile_width
      tile_w := word[font][gfx#SX]
    ifnot tile_h := tile_height
      tile_h := word[font][gfx#SY]

PUB Char(char_byte, x, y)

    gfx.Sprite(font, x, y, char_byte - startingchar)
    
PUB Hex(value, digits, x, y)

  value <<= (8 - digits) << 2
  repeat digits
    Char(lookupz((value <-= 4) & $F : "0".."9", "A".."F"), x, y)
    x += tile_w
    
PUB Dec(value, x, y) | i, d

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

  value <<= 32 - digits
  repeat digits
    Char((value <-= 1) & 1 + "0", x, y)
    x += tile_w

PUB Str(stringvar, origin_x, origin_y)

    repeat strsize(stringvar)
        gfx.Sprite(font, origin_x, origin_y, byte[stringvar++] - startingchar)
        origin_x += tile_w

PUB Box(stringvar, origin_x, origin_y, w, h) | c, x, y

    x := origin_x
    y := origin_y

    repeat strsize(stringvar)
        c := byte[stringvar++]
        if c == NL or c == LF
            y += tile_h
            x := origin_x
        elseif c == " "
            x += tile_w
        else
            gfx.Sprite(font, x, y, c - startingchar)
            if x+tile_w => origin_x+w
                y += tile_h
                x := origin_x
            else
                x += tile_w
