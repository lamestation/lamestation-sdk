---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 5: Amplitude"
section: "Section 5: Audio"

next_file: "06_Waveform.spin.html"
next_name: "Step 6: Waveform"

prev_file: "04_Volume.spin.html"
prev_name: "Step 4: Volume"
---

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
        volume_inc := 100

        audio.SetWaveform(1, audio#_SAW)
        audio.SetEnvelope(1, 0)

        repeat
            ctrl.Update

            if ctrl.Up
                freq++
            if ctrl.Down
                freq--

            if ctrl.Left
                if volume_inc > 0
                    volume_inc--
            if ctrl.Right
                volume_inc++

            volume += volume_inc

            audio.SetFreq(1,freq)
            audio.SetVolume(1,(volume >> 10) // 127)
