
Watch how a makeshift mod filter can DESTROY YOUR EARS WITH AN EPIC BATTLE LIKE NONE YOU'VE EVER SEEN!

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

    OBJ
        audio   : "LameAudio"
        ctrl    : "LameControl"

    VAR
        long    frequency
        long    frequency_inc

    PUB Main
        audio.Start
        ctrl.Start

        frequency := 10000
        frequency_inc := 100

        audio.SetEnvelope(0, 0)
        audio.SetEnvelope(1, 0)
        audio.SetEnvelope(2, 0)
        audio.SetEnvelope(3, 0)

        audio.SetWaveform(0, audio#_SINE)
        audio.SetWaveform(1, audio#_SAW)
        audio.SetWaveform(2, audio#_SQUARE)
        audio.SetWaveform(3, audio#_SINE)

        repeat
            ctrl.Update

            if ctrl.Left
                frequency_inc -= 1
            if ctrl.Right
                frequency_inc += 1

            frequency += frequency_inc

            audio.SetFreq(0, frequency // 100000)
            audio.SetFreq(1, frequency >> 1  // 100000)
            audio.SetFreq(2, frequency // 100000)
            audio.SetFreq(3, frequency >> 2  // 100000)