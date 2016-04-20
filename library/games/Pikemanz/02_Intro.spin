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

    nash    :   "gfx_mr_pine"
    arrow   :   "gfx_arrow_d"

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    Scene

PUB Scene
    state.SetState(state#_WORLD)

    ctrl.Update
    gfx.Fill(gfx#WHITE)
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
    lcd.Draw
    ctrl.WaitKey

PUB DisplayWaitDialogArrow(str)
    menu.Dialog(str)
    gfx.Sprite(arrow.Addr, 115,54, 0)
    lcd.Draw
    ctrl.WaitKey
