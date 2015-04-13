' 01_basics/ImAlive.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
OBJ
    pin : "Pinout"
CON
    LED_PIN = pin#LED
    LED_PERIOD = 1000

PUB Main 
    dira[LED_PIN]~~

    repeat
        outa[LED_PIN]~
        
        repeat LED_PERIOD
        outa[LED_PIN]~~
        
        repeat LED_PERIOD

