CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   :   "LameAudio"
    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    
    tail    :   "gfx_tailrotor"
    top     :   "gfx_toprotor"
    body    :   "gfx_body"
    
    msl     :   "gfx_missile"
    
    mtn     :   "map_mountain"
    mtn_gfx :   "gfx_mountain"
       
DAT
    volume      long    10000
    volume_inc  long    100
    freq        long    1800
    hx          long    0
    hy          long    20<<4
    hvx         long    0
    hvy         long    0
    
    SFXStack    long    0[20]
    
    frame       byte    0
    frame_cnt   byte    20
    
    xoffset     long    0
    yoffset     long    0
    
    mx          long    0
    my          long    0

PUB Main
    lcd.Start(gfx.Start)
    audio.Start
    ctrl.Start
    
    cognew(SFXEngine, @SFXStack)

    repeat
        ctrl.Update
        gfx.ClearScreen(gfx#BLACK)
            
        xoffset++
                
        yoffset := (hy ~> 8) - 25  
        if yoffset < 0
            yoffset := 0
        if yoffset > 64
            yoffset := 64 
            
        if ctrl.Left
            if hvx > -200
                hvx -= 5
        elseif ctrl.Right
            if hvx < 200
                hvx += 5
        else
            if hvx > 0
                hvx -= 2
            elseif hvx < 0
                hvx += 2
        
        hx += hvx
        

        
        if ctrl.A
            if hvy > -200
                hvy -= 8
            frame_cnt++
            if volume_inc < 1000
                volume_inc += 20
                freq += 40
        else
            if volume_inc > 200
                volume_inc -= 10
                freq -= 20     
           
        if hvy < 150
            hvy += 4     ' gravity
        hy += hvy       
        
        frame_cnt++
        if frame_cnt > 5
            frame_cnt := 0
            frame := (frame + 1) // 3

    
    
        gfx.Map(mtn_gfx.Addr, mtn.Addr, xoffset & $7F, yoffset, 0, 0,128-(xoffset & $7F), 64)
        gfx.Map(mtn_gfx.Addr, mtn.Addr, 0, yoffset, 128 - (xoffset & $7F), 0,128, 64)
    
        DrawCopter(hx~>8, hy~>8 - yoffset, frame)
 
        lcd.DrawScreen                           
    
PUB DrawCopter(x, y, f)
    
    gfx.Sprite(body.Addr, x, y+2, 0)
    gfx.Sprite(top.Addr, x+4, y, f)
    gfx.Sprite(tail.Addr, x+1, y+9, f)
    
PUB SFXEngine    
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1,0)

    repeat
        volume += volume_inc

        audio.SetFrequency(1,freq)
        audio.SetVolume(1,(volume >> 10) // 127)
        
      '  if hy~>8 > 100
       '     audio.SetWaveform(2, audio#_NOISE)
        '    audio.StartEnvelope(2)
        
'        fn.Sleep(2)
