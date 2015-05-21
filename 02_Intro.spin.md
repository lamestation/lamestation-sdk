
title: Welcome To Pikemanz

brief: Learn to draw your own Pikemanz and title screen and show them on the console.

authors: Brett Weir

In this segment, we can see how a dialog sequence like the kind found in many kinds of video games might work.

## Setup

Set up your code in the usual way.

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        map     :   "LameMap"
        ctrl    :   "LameControl"
        fn      :   "LameFunctions"

        state   :   "PikeState"
        menu    :   "PikeMenu"

Let's add some graphics. We're going to need two.

 - `gfx_nash_fetchum` is our friendly main character!

 - `gfx_arrow_d` is a tiny little arrow graphic that will come in handy later!

        nash    :   "gfx_nash_fetchum"
        arrow   :   "gfx_arrow_d"

Again, we will create a main function that calls another function that contains the actual demo.

    PUB Main
        lcd.Start(gfx.Start)
        ctrl.Start
        Scene

Use it to pass text to functions.

    PUB Scene
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)
        gfx.Sprite(nash.Addr,52,4, 0)

In Spin, you can create a string on the fly with the `string` command.

    string("Some text goes here!")

Create the individual dialog is going to be super easy. `PikeMenu` has a nice function for displaying

## Adding the dialog

Let's start with something simple. `PikeMenu` defines some functions for drawing some nice Pikemanz boxes; you know, like the kind that display text.

        menu.Dialog(string("TEACH: Hi there!"))
        lcd.DrawScreen
        ctrl.WaitKey

`'10'` is the ASCII character for for a new line. It's the character that get spit out every time you press *Enter* on your keyboard. But you can't just press *Enter* in your code because strings can only fit on a single line, so you have to insert them manually.

[Click here](http://en.wikipedia.org/wiki/ASCII) to learn more about ASCII, or [here](http://web.cs.mun.ca/~michael/c/ascii-table.html) to see a complete ASCII table.

        menu.Dialog(string("My name",10,"is Mr. Pine, but"))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("you can call me",10,"TEACH."))
        lcd.DrawScreen
        ctrl.WaitKey

But why do we have to add `'10'` so often? The LameStation screen is very small. To make matters worse, this isn't a fancy operating system that automatically wraps your text when you get to the end of a line. You have to do it yourself.

        menu.Dialog(string("In the Pikemanz",10,"world, you make..."))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("the rules."))
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("You'll never play",10,"a game as good as"))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("the one you make",10,"yourself!"))
        lcd.DrawScreen
        ctrl.WaitKey

        state.SetState(state#_WORLD)

We can see the problem with this approach just by looking at the output.

### The code

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        map     :   "LameMap"
        ctrl    :   "LameControl"
        fn      :   "LameFunctions"

        state   :   "PikeState"
        menu    :   "PikeMenu"

        nash    :   "gfx_nash_fetchum"
        arrow   :   "gfx_arrow_d"

    PUB Main
        lcd.Start(gfx.Start)
        ctrl.Start
        Scene

    PUB Scene
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)
        gfx.Sprite(nash.Addr,52,4, 0)

        menu.Dialog(string("TEACH: Hi there!"))
        lcd.DrawScreen
        ctrl.WaitKey
        menu.Dialog(string("My name",10,"is Mr. Pine, but"))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("you can call me",10,"TEACH."))
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("In the Pikemanz",10,"world, you make..."))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("the rules."))
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("You'll never play",10,"a game as good as"))
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

        menu.Dialog(string("the one you make",10,"yourself!"))
        lcd.DrawScreen
        ctrl.WaitKey

        state.SetState(state#_WORLD)

Wow, that's a lot of code, and look how much of it is repeated! Surely, there must be a better way to do this? How can you shorten it?

## Shortening the code

Well, this is what functions are for. Let's define some functions that contains all that special stuff.

We need two. The first we'll call `DisplayWaitDialog` because that's what it does; it displays the dialog, then waits for user input.

    PUB DisplayWaitDialog(str)
        menu.Dialog(str)
        lcd.DrawScreen
        ctrl.WaitKey

Now we can display a dialog window in one line!

        DisplayWaitDialog(string("In the Pikemanz",10,"world, you make..."))

One problem though. Now there's no way to display that little arrow like we had before. So let's add one more function. that displays that too.

    PUB DisplayWaitDialogArrow(str)
        menu.Dialog(str)
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

We could have also added a parameter to the first function, which would have shortened the code even further. But then you have to remember that parameter every time you use the function, so it's a trade-off.

Here's what it would have looked like.

    PUB DisplayWaitDialog(str, arrow)
        menu.Dialog(str)

        if arrow
            gfx.Sprite(arrow.Addr, 115,54, 0)

        lcd.DrawScreen
        ctrl.WaitKey

It's a matter of preference really.

Okay, so now let's rewrite the existing code completely using the new function.

        DisplayWaitDialog(string("TEACH: Hi there!"))

        DisplayWaitDialogArrow(string("My name",10,"is Mr. Pine, but"))
        DisplayWaitDialog(string("you can call me",10,"TEACH."))

        DisplayWaitDialogArrow(string("In the Pikemanz",10,"world, you make..."))
        DisplayWaitDialog(string("the rules."))

        DisplayWaitDialogArrow(string("You'll never play",10,"a game as good as"))
        DisplayWaitDialog(string("the one you make",10,"yourself!"))

Wow, that is SO. MUCH. SHORTER.

Let's take a look at the code again.

### The code

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        lcd     :   "LameLCD"
        gfx     :   "LameGFX"
        map     :   "LameMap"
        ctrl    :   "LameControl"
        fn      :   "LameFunctions"

        state   :   "PikeState"
        menu    :   "PikeMenu"

        nash    :   "gfx_nash_fetchum"
        arrow   :   "gfx_arrow_d"

    PUB Main
        lcd.Start(gfx.Start)
        ctrl.Start
        Scene

    PUB Scene
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)
        gfx.Sprite(nash.Addr,52,4, 0)

        DisplayWaitDialog(string("TEACH: Hi there!"))

        DisplayWaitDialogArrow(string("My name",10,"is Mr. Pine, but"))
        DisplayWaitDialog(string("you can call me",10,"TEACH."))

        DisplayWaitDialogArrow(string("In the Pikemanz",10,"world, you make..."))
        DisplayWaitDialog(string("the rules."))

        DisplayWaitDialogArrow(string("You'll never play",10,"a game as good as"))
        DisplayWaitDialog(string("the one you make",10,"yourself!"))

    PUB DisplayWaitDialog(str)
        menu.Dialog(str)
        lcd.DrawScreen
        ctrl.WaitKey

    PUB DisplayWaitDialogArrow(str)
        menu.Dialog(str)
        gfx.Sprite(arrow.Addr, 115,54, 0)
        lcd.DrawScreen
        ctrl.WaitKey

