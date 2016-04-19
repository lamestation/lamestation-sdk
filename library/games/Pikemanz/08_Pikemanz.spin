CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    lcd         :   "LameLCD"
    gfx         :   "LameGFX"
    audio       :   "LameAudio"
    music       :   "LameMusic"
    ctrl        :   "LameControl"

    state       :   "PikeState"

    title       :   "01_Title"
    intro       :   "02_Intro"
    world       :   "03_World"
    battle      :   "04_Battle"

PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)
    audio.Start
    music.Start
    ctrl.Start

    world.Init

    state.SetState(state#_TITLE)
    repeat
        case state.State
            state#_TITLE:       title.View
            state#_INTRO:       intro.Scene
            state#_WORLD:       world.View
            state#_BATTLE:      battle.Wild
