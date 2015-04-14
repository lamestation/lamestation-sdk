---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 3: Speed Hack"
section: "Section 6: Music"

next_file: "04_JukeBox.spin.html"
next_name: "Step 4: Juke Box"

prev_file: "02_SwitchSongs.spin.html"
prev_name: "Step 2: Switch Songs"
---

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"

        song    : "song_pixeltheme_speedhax"

    PUB Main
        audio.Start
        music.Start
        music.Load(song.Addr)
        music.Loop
