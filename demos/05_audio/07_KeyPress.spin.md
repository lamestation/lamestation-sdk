---
version: 0.0.0
layout: learnpage
title: "Step 7: Key Press"
section: "Section 5: Audio"


prev_file: "06_Waveform.spin.html"
prev_name: "Step 6: Waveform"
---

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        audio   :   "LameAudio"
        ctrl    :   "LameControl"

    VAR
        byte    clicked
        byte    note
        byte    volume
        byte    noting

    PUB Noise
        audio.Start
        ctrl.Start

        audio.SetNote(0, note := 80)
        audio.SetVolume(0, volume := 127)
        audio.SetWaveform(0, audio#_SINE)
        audio.SetADSR(0,127, 100, 0, 127)

        audio.SetEnvelope(0, 1)

        repeat
            ctrl.Update

            if ctrl.A
                if not noting
                    audio.PlaySound(0,note)
                    noting := 1
            else
                audio.StopSound(0)
                noting := 0

            if ctrl.Left
                if note > 40
                    note--
            if ctrl.Right
                if note < 80
                    note++
