CON
    #0, _TITLE, _OVERWORLD, _BATTLE, _TRANSITION
DAT
   gamestate    byte    0 
    
PUB State
    return gamestate

PUB SetState(newstate)
    gamestate := newstate