---
version: 0.0.0
layout: learnpage
title: "Step 1: Draw Map"
section: "Section 3: Maps"

next_file: "02_MapScrolling.spin.html"
next_name: "Step 2: Map Scrolling"

---

One of the most useful things ever in 2D game programming is the tilemap, so naturally, LameStation has a set of functions for drawing completely epic tile-based maps into games that you can use for whatever you want.

Add the usual setup; clock settings and graphics.

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"

But this time, we're going to add something new. Check out `LameMap`, a map engine for LameStation.

        map     :   "LameMap"

## What is a map engine?

LameStation maps consist of two components: a level map and a tile map.

### Tile maps

A **tile map** is a collection of small images (for LameStation, usually 8x8 pixels in size) that can be used to assemble a larger image. Think of it like putting together a puzzle, that's really easy because there's no jagged edges! I mean, whose idea was that anyway?

Here is the tile map that we will use for this example.

![](gfx/cavemountain.png)

It's tiny, right? But look at what we can make with it! Here is an example of what a complete level map looks like.

![](gfx/cave.png)

Whoa! It's like playing with LEGOs. You can use tiny pieces to build enormous things. In this case, you're building a large picture out of tiny ones.

But why do this? Because it saves memory *and time*! Imagine if for every game you want to make, you had to paint a giant picture of each and every level. It would be a huge drain on your time, but it would also result in some pretty massive images, which is crazy. Especially on the LameStation, where you only have 32kB of RAM to work with.

Anyway, let's use these in our game. But they can't be used directly! Like in the previous section, tile maps are just regular images, so they must be converted to code with `img2dat` or `lspaint` first. But once there, we can just add it. In the example directory, this is saved as `gfx_cave.spin`, so let's include it.

        tileset :   "gfx_cave"

### Level maps

Level maps are different. You don't need to store the entire graphics in every single square, but you do need the tell the tile map engine which graphics to use. It'd be too big to print the text here, but you can [view it here](map_cave.spin) (Hint: you'll need to zoom out a *lot* to see it correctly).

Let's include that one too!

        cavemap :   "map_cave"

## Let's get drawing!

The usual, create a public main function and set up the LCD and graphics systems.

    PUB Main

        lcd.Start(gfx.Start)

`LameMap` requires you to load a map before you use it. Nothing is actually loaded though; it takes no time at all. You're just telling `LameMap` to use this tile map and that level map.

        map.Load(tileset.Addr, cavemap.Addr)

Now you're ready; you can draw your map to the screen with the `Draw` command.  It takes two parameters: a vertical and horizontal offset. These values control which part of the map is shown. As you might have noticed, the map size (480x128) is way larger than the screen (128x64), so you can only display a small portion of it at a time.

Starting from the top-left, the offset moves the map pixel by pixel to the place you want. Something interesting seems to be in the bottom-left corner of the map, so let's set an offset that'll put the screen there.

        map.Draw(0,64)

Now draw to the screen.

        lcd.DrawScreen

The completed code will look like this:

    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        map     :   "LameMap"

        tileset :   "gfx_cave"
        cavemap :   "map_cave"

    PUB Main

        lcd.Start(gfx.Start)
        map.Load(tileset.Addr, cavemap.Addr)
        map.Draw(0,64)
        lcd.DrawScreen

## Run it

Here is what you will see!

![The resulting display.](screenshots/pic1.png)

Hmm... that looks like the little spot in the bottom-left, remember? =P

![](gfx/cave.png)

It still doesn't do anything interesting yet though. That will have to wait until the next tutorial.
