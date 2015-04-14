---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 2: Switch Songs"
section: "Section 6: Music"

next_file: "03_SpeedHack.spin.html"
next_name: "Step 3: Speed Hack"

prev_file: "01_PlaySong.spin.html"
prev_name: "Step 1: Play Song"
---

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
        fn      : "LameFunctions"

        song    : "song_pixeltheme"
        song2   : "song_lastboss"

    PUB Play
        audio.Start
        music.Start

        music.Load(song.Addr)
        music.Loop

        fn.Sleep(2000)

        music.Stop
        music.Load(song2.Addr)
        music.Loop

        fn.Sleep(2000)

        music.Stop
        music.Load(song.Addr)
        music.Play

        repeat until not music.IsPlaying

        music.Load(song2.Addr)
        music.Play
