OBJ
    lcd     : "LameLCD"
    gfx     : "LameGFX"
    audio   : "LameAudio"

PUB Static(buffer) | random, x
'' This command sprays garbage data onto the framebuffer
    gfx.WaitToDraw
    
    random := cnt
    repeat x from 0 to constant(gfx#SCREEN_W*gfx#SCREEN_H/8-1) step 1
         word[buffer][x] := random?

PUB Play(buffer, frames, channel) | x

    audio.SetWaveform(channel, 4)
    audio.SetADSR(channel, 127, 0, 127, 70)
    audio.PlaySound(channel, 50)
    
    repeat x from 0 to frames
        Static(buffer)
        lcd.Draw
        
    audio.StopSound(channel)
    