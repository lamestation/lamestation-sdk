OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main | x
    lcd.Start(gfx.Start)
    
    repeat
        repeat x from 0 to 11
            gfx.Sprite(@data, 0,0, x)
            lcd.Draw
        
            repeat 1000

PUB Addr
    return @data

DAT

data
word    64 
word    16, 16

word    %%00002222,%%22203330 
word    %%11110222,%%22031100 
word    %%11110222,%%22033130 
word    %%00000022,%%22003310 
word    %%11133022,%%23333001 
word    %%11133022,%%23111101 
word    %%00000000,%%23333300 
word    %%33333330,%%23111103 
word    %%11111110,%%20131301 
word    %%33333330,%%23111303 
word    %%00000000,%%20333300 
word    %%00000122,%%20000000 
word    %%30013032,%%21013001 
word    %%00030012,%%23030003 
word    %%00000322,%%22100000 
word    %%13131222,%%22231313 

word    %%00002222,%%22203330 
word    %%11110222,%%22031100 
word    %%11110222,%%22033130 
word    %%00000022,%%22003310 
word    %%11133022,%%23333001 
word    %%11133022,%%23111101 
word    %%00000000,%%23333300 
word    %%33333330,%%23111103 
word    %%11111110,%%20131301 
word    %%33333330,%%23111303 
word    %%00000000,%%20333300 
word    %%00000322,%%20000000 
word    %%30013012,%%23013001 
word    %%00030032,%%21030003 
word    %%00000122,%%22300000 
word    %%31313222,%%22213131 

word    %%00002222,%%22203330 
word    %%11110222,%%22031100 
word    %%11110222,%%22033130 
word    %%00000022,%%22003310 
word    %%11133022,%%33330031 
word    %%11133022,%%31111031 
word    %%00000002,%%33333000 
word    %%33333302,%%31111033 
word    %%11111102,%%01313011 
word    %%33333302,%%31113033 
word    %%00000002,%%03333000 
word    %%00000322,%%00000000 
word    %%30013012,%%23013001 
word    %%00030032,%%21030003 
word    %%00000122,%%22300000 
word    %%31313222,%%22213131 

word    %%03330222,%%22220000 
word    %%00113022,%%22201111 
word    %%03133022,%%22201111 
word    %%01330022,%%22000000 
word    %%10033332,%%22033111 
word    %%10111132,%%22033111 
word    %%00333332,%%00000000 
word    %%30111132,%%03333333 
word    %%10313102,%%01111111 
word    %%30311132,%%03333333 
word    %%00333302,%%00000000 
word    %%00000002,%%22100000 
word    %%10031012,%%23031003 
word    %%30003032,%%21003000 
word    %%00000122,%%22300000 
word    %%31313222,%%22213131 

word    %%03330222,%%22220000 
word    %%00113022,%%22201111 
word    %%03133022,%%22201111 
word    %%01330022,%%22000000 
word    %%10033332,%%22033111 
word    %%10111132,%%22033111 
word    %%00333332,%%00000000 
word    %%30111132,%%03333333 
word    %%10313102,%%01111111 
word    %%30311132,%%03333333 
word    %%00333302,%%00000000 
word    %%00000002,%%22300000 
word    %%10031032,%%21031003 
word    %%30003012,%%23003000 
word    %%00000322,%%22100000 
word    %%13131222,%%22231313 

word    %%03330222,%%22220000 
word    %%00113022,%%22201111 
word    %%03133022,%%22201111 
word    %%01330022,%%22000000 
word    %%13003333,%%22033111 
word    %%13011113,%%22033111 
word    %%00033333,%%20000000 
word    %%33011113,%%20333333 
word    %%11031310,%%20111111 
word    %%33031113,%%20333333 
word    %%00033330,%%20000000 
word    %%00000000,%%22300000 
word    %%10031032,%%21031003 
word    %%30003012,%%23003000 
word    %%00000322,%%22100000 
word    %%13131222,%%22231313 

word    %%11023132,%%23132011 
word    %%11103130,%%03130111 
word    %%00003130,%%03130000 
word    %%11130330,%%03331111 
word    %%11133100,%%03133111 
word    %%11330130,%%31113111 
word    %%33300330,%%31330333 
word    %%00000100,%%33100000 
word    %%30000330,%%31100003 
word    %%33000330,%%31100031 
word    %%30000330,%%03300001 
word    %%00000000,%%00000000 
word    %%13001111,%%11110031 
word    %%30003333,%%33330003 
word    %%00201111,%%11110200 
word    %%22223333,%%33332222 

word    %%11023132,%%23132011 
word    %%11103130,%%03130111 
word    %%00003130,%%03130000 
word    %%11130330,%%03331111 
word    %%11133100,%%03133111 
word    %%11330130,%%31113111 
word    %%33300330,%%31330333 
word    %%00000100,%%33100000 
word    %%30000330,%%31100003 
word    %%33000330,%%31100031 
word    %%30000330,%%03300001 
word    %%00000000,%%00000000 
word    %%13003333,%%33330031 
word    %%30001111,%%11110003 
word    %%00203333,%%33330200 
word    %%22221111,%%11112222 

word    %%11022222,%%22222011 
word    %%11103132,%%23130111 
word    %%00003130,%%03130000 
word    %%11130130,%%03131111 
word    %%11133330,%%03333111 
word    %%11330100,%%03113111 
word    %%33300130,%%31130333 
word    %%00000330,%%31300000 
word    %%30000100,%%33100003 
word    %%33000330,%%31100031 
word    %%30000330,%%31100001 
word    %%00000330,%%03300000 
word    %%13000000,%%00000031 
word    %%30001111,%%11110003 
word    %%00203333,%%33330200 
word    %%22221111,%%11112222 

word    %%13002222,%%22220031 
word    %%00003002,%%21300000 
word    %%11301130,%%11100311 
word    %%11101130,%%11130111 
word    %%11103300,%%13300111 
word    %%11001330,%%31330011 
word    %%00003300,%%03300300 
word    %%33003130,%%03130313 
word    %%30003130,%%03130013 
word    %%00001130,%%01130000 
word    %%33010003,%%10003033 
word    %%30010000,%%10000003 
word    %%00030000,%%30000000 
word    %%22003003,%%33000022 
word    %%22201111,%%11110222 
word    %%22223333,%%33332222 

word    %%13002222,%%22220031 
word    %%00003002,%%21300000 
word    %%11301130,%%11100311 
word    %%11101130,%%11130111 
word    %%11103300,%%13300111 
word    %%11001330,%%31330011 
word    %%00003300,%%03300300 
word    %%33003130,%%03130313 
word    %%30003130,%%03130013 
word    %%00001130,%%01130000 
word    %%33010003,%%10003033 
word    %%30010000,%%10000003 
word    %%00030000,%%30000000 
word    %%22003001,%%13000022 
word    %%22203333,%%33330222 
word    %%22221111,%%11112222 

word    %%13003002,%%21300031 
word    %%00001130,%%11100000 
word    %%11301130,%%11130311 
word    %%11103300,%%13300111 
word    %%11101330,%%31330111 
word    %%11003300,%%03300011 
word    %%00003130,%%03130300 
word    %%33003130,%%03130313 
word    %%30001130,%%01130013 
word    %%00010003,%%10003000 
word    %%33010000,%%10000033 
word    %%30030000,%%30000003 
word    %%00003003,%%33000000 
word    %%22001111,%%11110022 
word    %%22203333,%%33330222 
word    %%22221111,%%11112222 

