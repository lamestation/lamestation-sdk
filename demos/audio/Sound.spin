CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio : "LameAudio"

PUB Main
    audio.Start
    audio.PlaySound(1,50)
