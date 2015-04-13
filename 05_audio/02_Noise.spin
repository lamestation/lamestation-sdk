' 05_audio/02_Noise.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :               "LameAudio"

PUB Noise
    audio.Start

    audio.SetWaveform(1, 4)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.PlaySound(1,50)

