CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    pin : "LamePinout"

CON
    LED_PIN = pin#AUDIO
    COUNT   = 2000

PUB Main

    dira[LED_PIN]~~

    repeat
        outa[LED_PIN]~
        repeat COUNT

        outa[LED_PIN]~~

        repeat COUNT
