'' LameControl
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2013 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' -------------------------------------------------
''
'' LameControl? More like Game Control!
''
'' This library is a simple wrapper around the
'' buttons and joystick used by the LameStation
'' to both show how the controls work and make
'' managing controls easier.

OBJ
    pin  :   "Pinout"
    
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

    dira[24..26]~
    dira[12..15]~
    
    
PUB Update
    controls := ina
    

' 'On' is a logic low for every control pin coming
' from the hardware, so they must all be inverted.
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
