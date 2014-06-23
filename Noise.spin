{{
Noise
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :               "LameAudio"

PUB Noise
    audio.Start
    audio.SetWaveform(4)
    audio.SetADSR(127, 0, 0, 70)
    audio.PlaySound(1,40)

    repeat