CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"

VAR
    long    volume
    long    volume_inc
    long    volcount
    long    freq

PUB Main
    audio.Start
    ctrl.Start

    volume:= 1
    volume_inc := 300

    audio.SetWaveform(1, audio#_SINE)
    audio.SetEnvelope(1, 0)

    repeat
        ctrl.Update

        audio.SetFrequency(1,freq)

        if ctrl.A
            if freq > 2000
                volcount++
                volume := 127
                if (volcount / volume_inc) // 2 == 1
                    volume := 127
                else
                    volume := 0
                freq -= 10
            else
                volume := 0

            audio.SetVolume(1,volume)
        else
            volcount := 30000
            freq := 40000
            audio.SetVolume(1,0)
