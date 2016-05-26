' *********************************************************
'  Enemies
' *********************************************************
CON
    MAX_ENEMIES = 16
    MAX_ENEMY_TYPES = 5
    
    FP_OFFSET = 3

OBJ

    gfx : "LameGFX"
    
    gfx_blackhole   : "gfx_blackhole"
    gfx_krakken     : "gfx_krakken"
    gfx_spacetank   : "gfx_spacetank"
    gfx_rocket      : "gfx_rocket"

DAT
    nextenemy       byte    0
    enemy_count     byte    0

    enemy_type      byte    0[MAX_ENEMIES]
    enemy_x         long    0[MAX_ENEMIES]
    enemy_y         long    0[MAX_ENEMIES]
    enemy_frame     byte    0[MAX_ENEMIES]
    enemy_health    byte    0[MAX_ENEMIES]
    enemy_speedx    byte    0[MAX_ENEMIES]
    enemy_speedy    byte    0[MAX_ENEMIES]

    enemy_gfx       word    0[MAX_ENEMY_TYPES]
    enemy_speed     byte    0[MAX_ENEMY_TYPES]
    enemy_accel     byte    0[MAX_ENEMY_TYPES]
    enemy_maxhealth byte    0[MAX_ENEMY_TYPES]
    enemy_shoots    byte    0[MAX_ENEMY_TYPES]
    enemy_score     byte    0[MAX_ENEMY_TYPES]

PUB Init | i

    enemy_gfx[0] := gfx_spacetank.Addr
    enemy_gfx[1] := gfx_krakken.Addr
    enemy_gfx[2] := gfx_blackhole.Addr
    enemy_gfx[3] := gfx_rocket.Addr

    enemy_speed[0] := 6
    enemy_speed[1] := 3
    enemy_speed[2] := 2
    enemy_speed[3] := 6
    
   ' currentenemiesoffset := 0
    enemy_count := 0
    
    repeat i from 0 to constant(MAX_ENEMIES-1)
        enemy_type[i] := 0
        enemy_x[i] := 0
        enemy_y[i] := 0
        
                
PUB Handle | i

    repeat i from 0 to constant(MAX_ENEMIES-1)
        if enemy_type[i]
            enemy_x[i] -= enemy_speed[enemy_type[i]-1]
            if enemy_x[i] => -(24 << FP_OFFSET)
                gfx.Sprite(enemy_gfx[enemy_type[i]-1], enemy_x[i] >> FP_OFFSET, enemy_y[i] >> FP_OFFSET, 0)
            else
                enemy_type[i] := 0
                enemy_count--


PUB Spawn(dx, dy, type)
    if enemy_count < MAX_ENEMIES-1
        enemy_type[nextenemy] := type
        enemy_x[nextenemy] := dx << FP_OFFSET
        enemy_y[nextenemy] := dy << FP_OFFSET
        enemy_health[nextenemy] := enemy_maxhealth[type]
        
        nextenemy++
        if nextenemy => MAX_ENEMIES
            nextenemy := 0
            
        enemy_count++
        
        
{PUB CreateFixedEnemies | x
        currentenemies := word[@level1][currentenemiesoffset]
        currentenemiestmp := currentenemies
        repeat x from 0 to 5
            currentenemiestmp := currentenemies & $3
            if currentenemiestmp > 0
                SpawnEnemy(gfx#SCREEN_W, x << 3, currentenemiestmp)
            currentenemies >>= 2
}
PUB CreateRandomEnemies | ran, x, currentenemies, currentenemiestmp
    ran := cnt
    
    currentenemies := ran? & ran?
    repeat x from 0 to 7
        currentenemiestmp := currentenemies & $3
        if currentenemiestmp > 0
            Spawn(gfx#SCREEN_W,x << 3,currentenemiestmp)    
        currentenemies >>= 2
