---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 3: Sampler"
section: "Section 5: Audio"

next_file: "04_Volume.spin.html"
next_name: "Step 4: Volume"

prev_file: "02_Noise.spin.html"
prev_name: "Step 2: Noise"
---

This demo shows how to use the built-in sampler as well as a simple chord playback.

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        audio   :   "LameAudio"
        fn      :   "LameFunctions"
        sample  :   "ins_hammond"

    PUB Main
        audio.Start
        audio.SetSample(sample.Addr)
        audio.SetWaveform(0, audio#_SAMPLE)
        audio.SetWaveform(1, audio#_SAMPLE)
        audio.SetWaveform(2, audio#_SAMPLE)
        audio.SetWaveform(3, audio#_SAMPLE)

        audio.PlaySound(0,50)
        fn.Sleep(1000)
        audio.PlaySound(1,54)
        fn.Sleep(1000)
        audio.PlaySound(2,57)
        fn.Sleep(1000)
        audio.PlaySound(3,62)
        fn.Sleep(2000)
        audio.StopAllSound
