---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 1: Draw Map"
section: "Section 3: Maps"

next_file: "02_MapScrolling.spin.html"
next_name: "Step 2: Map Scrolling"

---

One of the most useful things ever in 2D game programming is the tilemap, so naturally, LameStation has a set of functions for drawing completely epic tile-based maps into games that you can use for whatever you want.

Add the usual settings.

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

Include the necessary objects.

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        map     :   "LameMap"

        cavemap :   "map_cave"
        tileset :   "gfx_cave"

Create a public main function.

    PUB Main

Set up the LCD and graphics systems.

        lcd.Start(gfx.Start)

Load the necessary graphics and map data into `LameMap`.

        map.Load(tileset.Addr, cavemap.Addr)

Draw your map to the screen buffer.

        map.Draw(0,64)

Draw to the screen.

        lcd.DrawScreen

And here's what it'll look like when you run it.

![The resulting display.](screenshots/pic1.png)
