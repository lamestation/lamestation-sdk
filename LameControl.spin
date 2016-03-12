OBJ
    pin     :   "LamePinout"
    fn      :   "LameFunctions"
    
CON

    J_U = |< pin#JOY_UP
    J_D = |< pin#JOY_DOWN
    J_L = |< pin#JOY_LEFT
    J_R = |< pin#JOY_RIGHT
   
    SW_A = |< pin#BUTTON_A
    SW_B = |< pin#BUTTON_B
     
DAT

    controls    long    0

PUB Start

    dira[pin#BUTTON_A..pin#BUTTON_B]~
    dira[pin#JOY_UP..pin#JOY_RIGHT]~
    
    
PUB Update
    controls := ina
    

' 'On' is a logic low for every control pin coming
' from the hardware, so they must all be inverted.
PUB A
    return ((!controls) & SW_A <> 0)
    
PUB B
    return ((!controls) & SW_B <> 0)

PUB Left
    return (controls & J_L <> 0)
    
PUB Right
    return (controls & J_R <> 0)

PUB Up
    return (controls & J_U <> 0)

PUB Down
    return (controls & J_D <> 0)
    
DAT
    click   byte    0
    
PUB WaitKey
    repeat
        Update
        if A or B
            if not click
                click := 1
                quit
        else
            click := 0
        fn.Sleep(20)
