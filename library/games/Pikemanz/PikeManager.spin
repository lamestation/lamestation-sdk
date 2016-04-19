{{
    Functions for controlling a Pikemanz
}}

OBJ
    gfx     :   "LameGFX"

CON
    PIKEZ   = 16
    #0, INACTIVE, FAINTED, GOOD
    
DAT
    sprit   word    0[PIKEZ]
    nm      word    0[PIKEZ]
        
    ox      byte    0[PIKEZ]
    oy      byte    0[PIKEZ]
    
    hp      byte    0[PIKEZ]
    hp_max  byte    0[PIKEZ]
    atk     byte    0[PIKEZ]
    def     byte    0[PIKEZ]
    spd     byte    0[PIKEZ]
    
    status  byte    0[PIKEZ]
    
    count   byte    0
    total   byte    0

PUB SetPikeman(id, name, maxhealth, attack, defense, speed, sprite)
    nm[id]      := name
    sprit[id]   := sprite
    
    hp[id]      := maxhealth
    hp_max[id]  := maxhealth
    atk[id]     := attack
    def[id]     := defense
    spd[id]     := speed
    
    status[id] := GOOD
    
    return id
    
PUB Hurt(id, damage)
    if hp[id] - damage > 0
        hp[id] -= damage
    else
        hp[id] := 0
        status[id] := FAINTED
        
PUB Heal(id, health)
    if status[id] == FAINTED
        status[id] := GOOD
        
    if hp[id] + health =< hp_max[id]
        hp[id] += health
    else
        hp[id] := hp_max[id]
        
PUB Draw(id, x, y)
    gfx.Sprite(sprit[id], x, y, 0)
    
PUB GetName(id)
    return nm[id]

PUB GetHealth(id)
    return hp[id]
    
PUB GetMaxHealth(id)
    return hp_max[id]
