---
version: 0.0.0
layout: learnpage
title: "Step 3: Test Map Move"
section: "Section 7: Collision"

next_file: "04_BallBouncing.spin.html"
next_name: "Step 4: Ball Bouncing"

prev_file: "02_TestMapCollision.spin.html"
prev_name: "Step 2: Test Map Collision"
---

Now let's take collision to the next level. Let's do more than detect that a collision has occurred; we are going to use that information to make sure that the ball stays outside of the map. This is the starting point for any game that might potentially have walls or obstacles that the player can't cross.

Add the usual set up, with a box and map.

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000
    OBJ
        lcd  : "LameLCD"
        gfx  : "LameGFX"
        map  : "LameMap"
        ctrl : "LameControl"

        box  : "gfx_box"

        map1 : "map_map"
        tile : "gfx_box_s"

    CON
        w = 24
        h = 24

Now we're really going to need those long values. Add the `x` and `y` constants like in the previous tutorial.

    VAR
        long    x, y

But this time we need to add a little something extra. We need to keep track of some extra information.

`oldx`, `oldy` will be used to save the last position of the `x` and `y` variables before they were changed.

        long    oldx, oldy

`adjust` will be a temporary variable that we will explain a few lines from now. For now, define it.

        long    adjust

A setup similar to the previous tutorial.

    PUB Main

        lcd.Start(gfx.Start)
        map.Load(tile.Addr, map1.Addr)

        x := 12
        y := 12

        repeat
            gfx.ClearScreen(0)

We were going to save the `x` and `y` position at the start of every loop. Here's where we do that.

            oldx := x
            oldy := y

Now we want to move the box with the joystick. The movement code is the same as in the previous tutorial. However, we will be splitting it up horizontally and vertically so that we can apply corrections to the movement.

Left and right movement.

            ctrl.Update
            if ctrl.Left
                if x > 0
                    x--
            if ctrl.Right
                if x < gfx#res_x
                    x++

Now the `adjust` variable comes into play. `TestMoveX` returns an integer offset that equals the number of pixels that your box has cross over into the map tile. This number is calculated based on:

* The old `x` and `y` positions

* The width and height of the object

* Finally, the **new** horizontal position

We will store the result of this command in the `adjust` variable.

            adjust := map.TestMoveX(oldx, oldy, word[box.Addr][1], word[box.Addr][2], x)

If `adjust` is not zero, we will use it to apply a correction to the object's position.

            if adjust
                x += adjust

So you can see it, let's invert the colors.

                gfx.InvertColor(True)

Now we are basically doing to the same thing, but changing it for up and down movement.

            if ctrl.Up
                if y > 0
                    y--
            if ctrl.Down
                if y < gfx#res_y
                    y++

            adjust := map.TestMoveY(oldx, oldy, word[box.Addr][1], word[box.Addr][2], y)
            if adjust
                y += adjust
                gfx.InvertColor(True)

Draw the map and sprite to the screen.

            map.Draw(0,0)
            gfx.Sprite(box.Addr,x, y,0)

            gfx.InvertColor(False)
            lcd.DrawScreen

And now you can't do crazy things like travel through walls!
