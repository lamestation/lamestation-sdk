---
version: 0.0.0
layout: learnpage
title: "Step 5: Propally  Awesome"
section: "Section 6: Music"


prev_file: "04_JukeBox.spin.html"
prev_name: "Step 4: Juke Box"
---

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"

        song    : "song_proppaly_awesome"

    PUB Main
        audio.Start
        music.Start
        music.Load(song.Addr)
        music.Play
