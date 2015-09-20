CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"

VAR
    long    volume
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start

    volume:= 1

    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update
        audio.SetFrequency(1,freq)

        if ctrl.A
            if freq > 4000
                freq -= 20

            volcount++
            if (volcount >> 2) // 2 == 1
                volume := 127
            else
                volume := 0

            audio.SetVolume(1,volume)
        else
            freq := 40000
            audio.SetVolume(1,0)
