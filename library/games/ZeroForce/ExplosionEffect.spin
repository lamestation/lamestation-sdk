CON 
    EXPLOSION_COUNT_MAX = 10
    EXPLOSION_GFX_MAX = 1

OBJ
    gfx : "LameGFX"
   
DAT
    explosion       byte    0
    explosion_on    byte    0[EXPLOSION_COUNT_MAX]
    explosion_x     long    0[EXPLOSION_COUNT_MAX]
    explosion_y     long    0[EXPLOSION_COUNT_MAX]
    explosion_frame byte    0[EXPLOSION_COUNT_MAX]
    explosion_time  byte    0[EXPLOSION_COUNT_MAX]
    explosion_gfx   word    0[EXPLOSION_GFX_MAX]

PUB Init
    explosion := 0
    bytefill(@explosion_on,     0, EXPLOSION_COUNT_MAX)
    bytefill(@explosion_x,      0, EXPLOSION_COUNT_MAX)
    bytefill(@explosion_y,      0, EXPLOSION_COUNT_MAX)
    bytefill(@explosion_frame,  0, EXPLOSION_COUNT_MAX)
    bytefill(@explosion_time,   0, EXPLOSION_COUNT_MAX)
    
PUB SetGraphics(index, addr)

    explosion_gfx[index] := addr
    
PUB Spawn(x, y, type)

    explosion_on[explosion]     := type + 1
    explosion_x[explosion]      := x - gfx.Width (explosion_gfx[type])>>1
    explosion_y[explosion]      := y - gfx.Height (explosion_gfx[type])>>1
    explosion_frame[explosion]  := 0
    explosion_time[explosion]   := 0
                                
    explosion++
    if explosion > constant(EXPLOSION_COUNT_MAX-1)
        explosion := 0

PUB Handle(xoffset, yoffset) | dx, dy, i

    repeat i from 0 to constant(EXPLOSION_COUNT_MAX-1)
        if explosion_on[i]
        
            explosion_time[i]++
            if explosion_time[i] > 4
                explosion_time[i] := 0
                explosion_frame[i]++
                
            if explosion_frame[i] > 4
                explosion_on[i] := 0
            else
                dx := explosion_x[i] - xoffset
                dy := explosion_y[i] - yoffset
      
                if (dx => 0) and (dx =< gfx#SCREEN_W-1) and (dy => 0) and (dy =< gfx#SCREEN_H - 1)          
                    gfx.Sprite(explosion_gfx[explosion_on[i]-1], dx , dy, explosion_frame[i])
                else
                    explosion_on[i] := 0
