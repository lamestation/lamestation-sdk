{{
Pikemanz - PikeManager
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}  
OBJ
    gfx     :   "LameGFX"

CON
    PIKEZ   = 2
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
DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT
