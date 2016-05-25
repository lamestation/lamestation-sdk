CON
    MAX_BULLETS = 20
    MAX_GFX = 5
    
    BULLET_SPEED = 1
    BULLET_SPEED_MAX = 7 << 3
    BULLET_ACCEL = 3
   

OBJ

    gfx         : "LameGFX"
    fixed       : "LameFixed"
    
    explosion   : "ExplosionEffect"
    
DAT

    bullet_x        long    0[MAX_BULLETS]
    bullet_y        long    0[MAX_BULLETS]
    bullet_speedx   long    0[MAX_BULLETS]

    bullet_gfx      word    0[MAX_GFX]
    bullet_frame    byte    0[MAX_GFX]
    bullet_accels   byte    0[MAX_GFX]
    bullet_explodes byte    0[MAX_GFX]
    bullet_damage   byte    0[MAX_GFX]
    
    bullet_on       byte    0[MAX_BULLETS]
    bullet          byte    0
    
PUB Init

    bullet := 0

    bytefill(@bullet_on,    0, MAX_BULLETS)    
    longfill(@bullet_x,     0, MAX_BULLETS)    
    longfill(@bullet_y,     0, MAX_BULLETS)
    longfill(@bullet_speedx,0, MAX_BULLETS)
    
PUB SetType(index, addr, frame, accels, explodes, damage)

    bullet_gfx[index] := addr
    bullet_frame[index] := frame
    bullet_accels[index] := accels
    bullet_explodes[index] := explodes
    bullet_damage[index] := damage

PUB Spawn(x, y, type)

    bullet_on[bullet] := type + 1
    bullet_x[bullet] := fixed.Fixed(x)
    bullet_y[bullet] := y    
    bullet_speedx[bullet] := 0
    
    bullet++
    if bullet => MAX_BULLETS
        bullet := 0

PUB Handle | i, type

    repeat i from 0 to constant(MAX_BULLETS-1)
        if bullet_on[i]
            type := bullet_on[i]-1
            
            if bullet_accels[type]
    
                if ||bullet_speedx[i] < BULLET_SPEED_MAX
                    bullet_speedx[i] += BULLET_ACCEL
                
                bullet_x[i] += bullet_speedx[i]
                
            else
            
                bullet_x[i] += BULLET_SPEED_MAX
            
            if fixed.Integer(bullet_x[i]) => 100
                if bullet_explodes[type]
                    explosion.Spawn (fixed.Integer(bullet_x[i]) + 6, bullet_y[i] + 2, 0)
                bullet_on[i] := 0
            else
                gfx.Sprite(bullet_gfx[type], fixed.Integer(bullet_x[i]), bullet_y[i], bullet_frame[type])