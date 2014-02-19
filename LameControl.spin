'' LameControl
'' ─────────────────────────────────────────────────
'' Version: 1.0
'' Copyright (c) 2013 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' ─────────────────────────────────────────────────
''
'' LameControl? More like Game Control!
''
'' This library is a simple wrapper around the
'' buttons and joystick used by the LameStation
'' to both show how the controls work and make
'' managing controls easier.


CON

    J_U = |< 12
    J_D = |< 13
    J_L = |< 14
    J_R = |< 15
   
    SW_A = |< 25
    SW_B = |< 26
     
VAR

    long controls

PUB Start

    dira[24..26]~
    dira[12..15]~
    
    
PUB Update
    controls := ina
    
PUB A
    return not controls & SW_A
    
PUB B
    return not controls & SW_B

PUB Left
    return controls & J_L    
    
PUB Right
    return controls & J_R

PUB Up
    return controls & J_U

PUB Down
    return controls & J_D
