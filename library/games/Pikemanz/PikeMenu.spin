OBJ
    lcd         :   "LameLCD"
    gfx         :   "LameGFX"
    txt         :   "LameText"
    ctrl        :   "LameControl"
    fn          :   "LameFunctions"
    
    dia         :   "gfx_dialog"
    bar         :   "gfx_bar"
    
    hp          :   "gfx_healthbar"
    hp_box      :   "gfx_health"

    font_text   :   "gfx_font6x6_b"    
    
PUB YesNo(str)
    
PUB Dialog(str)
    txt.Load(font_text.Addr, " ", 0, 0)
    MessageBox(str,1,39,128,24,6,6)
    
PUB Box(x, y, w, h, tw, th) | dx, dy, x1, y1, w1, h1, frame

    x1 := x/tw
    y1 := y/th

    w1 := w/tw-1
    h1 := h/th-1

    repeat dy from 0 to h1
        repeat dx from 0 to w1
            frame := 0
            case dy
                0:      frame += 0
                h1:     frame += 6
                other:  frame += 3

            case dx
                0:      frame += 0
                w1:     frame += 2
                other:  frame += 1

            gfx.Sprite(dia.Addr,x+dx*tw,y+dy*th,frame)

PUB MessageBox(str, x, y, w, h, tw, th)
    txt.Load(font_text.Addr, " ", 0, 0)
    Box(x, y, w, h, tw, th) 
    txt.Box(str,x+tw, y+th, w-tw, h-th)
    
    
PUB AttackDialog(attack1, attack2, attack3, attack4)
    Box(1,40,72,24,6,6)
 '   dia.Dialog(string("JAKE wants",10,"to FIGHT"))
