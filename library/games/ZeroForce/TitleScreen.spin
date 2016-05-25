OBJ
    lcd         : "LameLCD"
    gfx         : "LameGFX"
    txt         : "LameText"
    music       : "LameMusic"
    ctrl        : "LameControl"
    
    star        : "StarEffect"

    song_zeroforce      : "song_zeroforce"

    gfx_logo_zeroforce  : "gfx_logo_zeroforce_inv"

PUB Run

    music.Load(song_zeroforce.Addr)
    music.Loop
    
    star.Init
    
    gfx.Blit (gfx_logo_zeroforce.Addr)
'    gfx.WaitToDraw
    lcd.Draw
    
    ctrl.WaitKey          
              
    music.Stop
    