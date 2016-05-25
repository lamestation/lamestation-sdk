CON
    STAR_COUNT_MAX = 100
    STAR_METER_MAX = 140
    STAR_METER_SPEED = 2

DAT

    star_meter      word    0
    star_count      byte    0
    star_speed      byte    0
    star_frame      byte    0
        
    star_x          long    0[STAR_COUNT_MAX]
    star_y          byte    0[STAR_COUNT_MAX]
        
    random          long    0
        
    lightspeed      byte    0
    
OBJ
    
    gfx         : "LameGFX"

    gfx_star    : "gfx_star"
    
PUB Init | i

    random := cnt

    star_meter := 20
    star_frame := 0
    
    repeat i from 0 to constant(STAR_COUNT_MAX-1)
        New(i)
            

PUB SetLightSpeed(enabled)

    lightspeed := enabled
    
PUB SetMeter(value)

    if value => 0 and value < STAR_METER_MAX
        star_meter := value

PUB New(i) 
    
    star_x[i] := (||random? // 144)
    star_y[i] := (random? & $3F)
    
    if star_y[i] > 24 and star_y[i] =< 32
        star_y[i] := (random? & $F)
        
    elseif star_y[i] > 32 and star_y[i] < 40
        star_y[i] := 48 + (random? & $F)

PUB Handle | i

    if lightspeed
        if star_meter < STAR_METER_MAX
            star_meter += STAR_METER_SPEED
    else
        if star_meter > 20
            star_meter -= STAR_METER_SPEED
            
    if star_meter < STAR_COUNT_MAX
        star_count := star_meter
    else
        star_count := STAR_COUNT_MAX
       
    
    star_frame := star_meter >> 5    
    star_speed := 2 + star_frame << 1
    
    if star_frame > 3
        star_frame := 3

    repeat i from 0 to constant(STAR_COUNT_MAX-1)
        if star_x[i] > -16
            star_x[i] -= star_speed
        else
            New(i)
            star_x[i] := 128 + (random? & $7)

        if i < star_count
            gfx.Sprite (gfx_star.Addr, star_x[i], star_y[i], star_frame)

