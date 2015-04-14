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
