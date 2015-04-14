---
date: 2015-04-14
version: 0.0.0
layout: learnpage
title: "Step 1: Test Box Collision"
section: "Section 7: Collision"

next_file: "02_TestMapCollision.spin.html"
next_name: "Step 2: Test Map Collision"

---

Add the basic building blocks.

    CON

        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

You will need `LameLCD`, `LameGFX`, `LameControl`, and `LameFunctions` for this demo.

    OBJ
        lcd  :               "LameLCD"
        gfx  :               "LameGFX"
        ctrl :               "LameControl"
        fn   :               "LameFunctions"

Plus a little something extra. Add some slick graphics for a box, because how cool are you!

        box  :               "gfx_box"
        boxo :               "gfx_box_o"

Basic collision requires a bounding box, or the square that defines an object's location. All we need to know is the position of the top-left and the bottom-right corners of the image to know the bounding box. Then, we need this information for both objects that will interact with each other.

We'll store these values in their own variables. Since we're not making a full game and the size of the screen is very small, we'll store the positions in bytes, because we're cool.

*In reality though, we should be using the `long` data type, because then we won't have to worry about sign errors if our program gets even slightly complicated.*

    VAR
        byte    x1, y1
        byte    x2, y2

We're going to be adding a large square to the screen, but to do collision, we really need to know how big the image is. There's a few way to do this. The LameGFX image format contains the width and height of an image, but it's slower to use the access functions than to use a hard-coded value. Since we know the size of the image in advantage, oh, whatever! Just define some constants!

    CON
        w = 24
        h = 24

Now for the main function.

    PUB Main

Business as usual.

        lcd.Start(gfx.Start)

Now we need to initialize the position of the second object.

        x2 := 52
        y2 := 20

Let's start up a program loop so we can move around.

        repeat

Clear the screen to black so that moving around won't leave a trail on the screen.

            gfx.ClearScreen(0)

Let's take box #1 (which has the position `(x1, y1)`) and allow the player to move it around on the screen. **BUT!** We will be careful and not let the box move off the screen (because who wants *that*!).

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

Let's invert the colors of the boxes if they are overlapping. This will provide a very obvious visual cue that something has happened.

            if fn.TestBoxCollision(x1, y1, w, h, x2, y2, w, h)
                gfx.InvertColor(True)

Now we draw the boxes to the drawing buffer using the `Sprite` command.

            gfx.Sprite(boxo.Addr,x1,y1,0)
            gfx.Sprite(boxo.Addr,x2,y2,0)

This extra sprite gives us the nice overlapping box effect we like.

            gfx.Sprite(box.Addr,x1,y1,0)

Always remember to turn off color inversion when you're done with it, so the rest of your program behaves the way that you expect it to.

            gfx.InvertColor(False)

Finally take the drawing buffer and copy it to the screen.

            lcd.DrawScreen

Now run our program and see how awesome it is!
