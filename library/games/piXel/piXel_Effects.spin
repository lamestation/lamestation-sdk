OBJ
    gfx         : "LameGFX"
    sfx         : "piXel_Sound"
 
    gfx_boom    : "gfx_boom"
    
CON 
    EFFECTS = 6
    #1, EXPLOSION
  
DAT
    effect      word    0
    effectx     long    0[EFFECTS]
    effecty     long    0[EFFECTS]
    effecton    byte    0[EFFECTS]
    effectframe byte    0[EFFECTS]
    effecttime  word    0[EFFECTS]

PUB Init | index
    effect := 0
    repeat index from 0 to constant(EFFECTS-1)
        effecton[index] := 0 
        effectx[index] := 0
        effecty[index] := 0
        effectframe[index] := 0
        effecttime[index] := 0
    
PUB Spawn(x, y, type)

    effecton[effect] := type
    effectx[effect] := x
    effecty[effect] := y
    effectframe[effect] := 0
    effecttime[effect] := 0
                                
    effect++
    if effect > constant(EFFECTS-1)
        effect := 0
        
    sfx.RunSound(3, sfx#_BOOM)

PUB Handle(xoffset, yoffset) | effectxtemp, effectytemp, index

    repeat index from 0 to constant(EFFECTS-1)
        if effecton[index]
        
            effecttime[index]++
            if effecttime[index] > 4
                effecttime[index] := 0
                effectframe[index]++
                
            if effectframe[index] > 2
                effecton[index] := 0
            else
                effectxtemp := effectx[index] - xoffset
                effectytemp := effecty[index] - yoffset
      
                if (effectxtemp => 0) and (effectxtemp =< gfx#SCREEN_W-1) and (effectytemp => 0) and (effectytemp =< gfx#SCREEN_H - 1)          
                    gfx.Sprite(gfx_boom.Addr, effectxtemp , effectytemp, effectframe[index])
                else
                    effecton[index] := 0
