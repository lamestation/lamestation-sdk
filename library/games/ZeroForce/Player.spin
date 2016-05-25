CON
    PRECISION = 3
    SPEED = 3
    
OBJ
    gfx     : "LameGFX"
    ctrl    : "LameControl"
    fixed   : "LameFixed"
    
    cc      : "Constants"
    
    bullets : "Bullets"
    
    gfx_zeroforce   : "gfx_zeroforce"

DAT
    player_x        long    0
    player_y        long    0
    
    bullettiming    byte    0
    
    pup_multiply    byte    1
    pup_weapon      byte    3

PUB Init

    SetPosition(3, 3)
    
PUB SetPosition(x, y)

    player_x := x
    player_y := y    

PUB Handle

    if ctrl.Left
        player_x -= SPEED
            
    if ctrl.Right
        player_x += SPEED
            
    if ctrl.Up
        player_y -= SPEED
            
    if ctrl.Down
        player_y += SPEED
    
    if player_x < 0
        player_x := 0
        
    if player_x > gfx#SCREEN_W - gfx.Width (gfx_zeroforce.Addr)
        player_x := gfx#SCREEN_W - gfx.Width (gfx_zeroforce.Addr)

    if player_y < 0
        player_y := 0
        
    if player_y > gfx#SCREEN_H - gfx.Height (gfx_zeroforce.Addr)
        player_y := gfx#SCREEN_H - gfx.Height (gfx_zeroforce.Addr)


    if ctrl.A
        if not bullettiming
            bullettiming := 1
            case pup_multiply
                0:      bullets.Spawn(player_x + 10, player_y + 5, pup_weapon)
                
                1:      bullets.Spawn(player_x + 10, player_y + 5, pup_weapon)
                        bullets.Spawn(player_x + 10, player_y - 2, pup_weapon)
                        
    else
        bullettiming := 0
        
    Draw

PUB Draw

    gfx.Sprite(gfx_zeroforce.Addr, player_x, player_y, 0)
    