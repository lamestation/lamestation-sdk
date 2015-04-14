---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 2: Noise"
section: "Section 5: Audio"

next_file: "03_Sampler.spin.html"
next_name: "Step 3: Sampler"

prev_file: "01_Sound.spin.html"
prev_name: "Step 1: Sound"
---

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
