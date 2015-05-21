---
version: 0.0.0
layout: learnpage
title: "Step 1: Title"
section: "Section : "

next_file: "02_Intro.spin.html"
next_name: "Step 2: Intro"

---

title: Welcome To Pikemanz

brief: Learn to draw your own Pikemanz and title screen and show them on the console.

authors: Brett Weir

Welcome to the exciting world of Pikemanz! Here, everything is awesome and there are no limits other than your imagination! (Okay, you've heard that before).

But still, unlike in other monster battling games,

To get there, we're going to be building Pikemanz piece by piece, section by section, until we have a fully functional game prototype. Now, doesn't that just sound awesome?

First we add some regular LameStation setup code.

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        lcd         :   "LameLCD"
        gfx         :   "LameGFX"
        ctrl        :   "LameControl"

Now we're gonna add a couple other files.

        state       :   "PikeState"

        menu        :   "PikeMenu"

Now let's have some graphics. Then we need to add some

        title       :   "gfx_title"
        font_text   :   "gfx_font6x6_b"
        nash        :   "gfx_nash_fetchum"

    PUB Main
        lcd.Start(gfx.Start)
        View

    PUB View
        gfx.ClearScreen(gfx#WHITE)
        gfx.LoadFont(font_text.Addr, " ", 0, 0)

        gfx.Sprite(title.Addr,1,10,0)
        gfx.PutString(string("lame version"), 17, 53)
        gfx.Sprite(nash.Addr, 100,14,0)

        lcd.DrawScreen

        ctrl.WaitKey

        state.SetState(state#_INTRO)
