---
version: 0.0.0
layout: learnpage
title: "Step 1: Sound"
section: "Section 5: Audio"

next_file: "02_Noise.spin.html"
next_name: "Step 2: Noise"

---

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

    OBJ
        audio : "LameAudio"

    PUB Main
        audio.Start
        audio.PlaySound(1,50)
