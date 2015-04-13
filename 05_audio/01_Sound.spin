' 05_audio/01_Sound.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio : "LameAudio"

PUB Main
    audio.Start
    audio.PlaySound(1,50)

