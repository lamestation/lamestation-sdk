---
version: 0.0.0
layout: learnpage
title: "Step 2: Test Map Collision"
section: "Section 7: Collision"

next_file: "03_TestMapMove.spin.html"
next_name: "Step 3: Test Map Move"

prev_file: "01_TestBoxCollision.spin.html"
prev_name: "Step 1: Test Box Collision"
---

In this tutorial, we're going to learn to check collision between a sprite and a `LameMap` level map.

Back to the basics.

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ
        lcd  : "LameLCD"
        gfx  : "LameGFX"
        ctrl : "LameControl"
        map  : "LameMap"

Load up some box graphics like in the previous tutorial.

        box  : "gfx_box"

Now we're going to add some map graphics. Remember, loading a map consists of two pieces: the level data and the tilemap data.

        map1 : "map_map"
        tile : "gfx_box_s"

Set up some variables to track the location of the box

    VAR
        byte    x1, y1

Define the width and height as constants.

    CON
        w = 24
        h = 24

Set up a main function like in the previous tutorial, with graphics and an initial box position.

    PUB Main
        lcd.Start(gfx.Start)
        x1 := 12
        y1 := 12

Now we're going to load a map with `LameMap`. Pass the addresses of the level and tilemap data.

        map.Load(tile.Addr, map1.Addr)

Let's add the same set up from the previous example.

        repeat
            gfx.Clear

            ctrl.Update
            if ctrl.Left
                if x1 > 0
                    x1--
            if ctrl.Right
                if x1 < gfx#res_x-24
                    x1++
            if ctrl.Up
                if y1 > 0
                    y1--
            if ctrl.Down
                if y1 < gfx#res_y-24
                    y1++

Unlike the last example though, now we're going to test to see if a map collision has occurred. This is done using the aptly named `TestCollision` command in the LameMap library. Pass the x- and y-position and the width and height of the sprite to use it. If a collision has occurred, invert the colors.

            if map.TestCollision(x1, y1, w, h)
                gfx.InvertColor(True)

Draw the map to the screen, and the sprite on top of it.

            map.Draw(0,0)
            gfx.Sprite(box.Addr,x1,y1,0)

Reset the colors and draw to the screen.

            gfx.InvertColor(False)
            lcd.Draw

