'' Screen Capture Tool
'' -------------------------------------------------
'' Use this app to dump a screen buffer to a BASE64-
'' encoded BMP file
''
''        Author: Marko Lukat
'' Last modified: 2014/06/17
''       Version: 0.2
'' -------------------------------------------------
''
OBJ
    serial: "FullDuplexSerial"

VAR
    long  cog
    byte  buffer[124]
  
PUB null

PUB Capture(addr) | amount, length, screen

    if not cog
        cog := serial.start(31, 30, %0000, 115200)
        waitcnt(clkfreq*3 + cnt)
    
    serial.tx(0)
    serial.tx(13)
    serial.tx(10)
    Convert(@tail{0}, addr)                             ' 2bit/px -> 4bit/px
    
    length := 4096 + 70                                 ' image length
    screen := @image{0}                                 ' image start address
    
    repeat
        amount := 54 <# length                          ' 54/3*4 = 72 chars
        Encode(@buffer{0}, screen, amount)
        screen += amount                                ' |
        length := 0 #> (length - 54)                    ' advance
        
        serial.str(@buffer{0})
        serial.tx(13)                                   ' send off chip
        serial.tx(10)                                   ' LF needed for Linux compatibility
    while length

PRI Encode(dst, src, length)

    repeat while length
        length -= Small(dst, src, 3 <# length)
        dst    += 4
        src    += 3
    
    byte[dst++] := 0

PRI Small(dst, src, length) : n | data, index
    
    data := 0
    index := 18
    
    repeat length
        data.byte[2 - n++] := byte[src++]
    
    byte[dst++] := table[data >> index]
    
    repeat 3
        index -= 6
        if length
            byte[dst++] := table[(data >> index) & $3F]
            length--
            next
        byte[dst++] := "="
    
PRI Convert(dst, src) : y

    repeat y from 63 to 0
        dst := Expand(dst, src + y*32)

PRI Expand(dst, src) : v

    repeat 32                                           ' pixel order is bigendian(!)
        v := byte[src++]
        byte[dst++] := (v & %%0003) << 4 | (v & %%0030) >> 2
        byte[dst++] := (v & %%0300){>> 0}| (v & %%3000) >> 6
    
    return dst
  
DAT
table   byte    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

image   byte    "B", "M"
        byte    70, 16, 0, 0
        byte    0, 0, 0, 0
        byte    70, 0, 0 ,0

        byte    40, 0, 0, 0
        byte    128, 0, 0, 0
        byte    64, 0, 0, 0
        byte    1, 0
        byte    4, 0
        byte    0, 0, 0, 0
        byte    0, 16, 0, 0
        byte    $13, $0B, 0, 0
        byte    $13, $0B, 0, 0
        byte    4, 0, 0, 0
        byte    0, 0, 0, 0

        byte    $FE, $40, $71, $00          'black
        byte    $CC, $CC, $CC, $00          'gray
        byte    $FF, $00, $FF, $00          'transparent
        byte    $E1, $7D, $B1, $00          'white

tail    byte    0[4096]
