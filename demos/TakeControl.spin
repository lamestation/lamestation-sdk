'' Take Control
'' ─────────────────────────────────────────────────
'' Version: 1.0
'' Copyright (c) 2014 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' ─────────────────────────────────────────────────
''
'' This app verifies the on-board controls of the LS
'' are working by blinking the test LED whenever the joystick
'' or buttons are pressed.
''

CON
  '_clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
 ' _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

    LED_PIN = 24
    LED_PERIOD = 10

OBJ
    ctrl    :               "LameControl"

PUB TakeControl | x

    dira[LED_PIN]~~

    repeat
        ctrl.Update

        if ctrl.A or ctrl.B or ctrl.Up or ctrl.Down or ctrl.Left or ctrl.Right
            outa[LED_PIN]~~
        else
            outa[LED_PIN]~
