OBJ
    pin : "LamePinout"

CON
    LED_PIN = pin#LED
    COUNT   = 10000

PUB Main
    dira[LED_PIN]~~
    repeat
        outa[LED_PIN]~
        repeat COUNT

        outa[LED_PIN]~~

        repeat COUNT
