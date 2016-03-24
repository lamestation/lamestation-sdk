{{
    #### LameStation Full Game Template
    
    This template is ideal for creating full-fledged
    games for the LameStation. It initializes all the main
    libraries and adds a more elaborate game skeleton.  
}}
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     : "LameLCD"
    gfx     : "LameGFX"
    audio   : "LameAudio"
    music   : "LameMusic"
    ctrl    : "LameControl"
    fn      : "LameFunctions"

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    GameInit
    
    repeat
        GameLoop

PUB GameTitleScreen

    ' add code for a title screen here

    lcd.DrawScreen
    ctrl.WaitKey

PUB GameInit

    ' initialize your game here

PUB GameLoop

    gfx.ClearScreen(0)
    ctrl.Update

   ' add code for your game loop here

    lcd.DrawScreen