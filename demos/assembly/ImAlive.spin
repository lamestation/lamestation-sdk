'' I'm Alive
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2014 LameStation.
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' -------------------------------------------------
''
'' This tutorial demonstrates that the Propeller itself is
'' alive by blinking a connected LED
''
'' It verifies that the crystal oscillator is working too
''
OBJ
    pin : "Pinout"
    
CON
  '_clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
 ' _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

    LED_PIN = pin#LED
    LED_PERIOD = 1000

PUB ImAlive | x

    dira[LED_PIN]~~

    repeat
        outa[LED_PIN]~
        
        repeat x from 0 to LED_PERIOD
        
        outa[LED_PIN]~~
        
        repeat x from 0 to LED_PERIOD
