{{
LameAudio Synthesizer
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}

'' LameControl? More like Game Control!

'' This library is a simple wrapper around the
'' buttons and joystick used by the LameStation
'' to both show how the controls work and make
'' managing controls easier.


CON

    J_U = 1 << 12
    J_D = 1 << 13
    J_R = 1 << 14
    J_L = 1 << 15
   
    SW1 = 1 << 24
    SW2 = 1 << 25
    SW3 = 1 << 26
     
VAR

    long controls

PUB Start

    dira[24..26]~
    dira[12..15]~
    
    
PUB Update
    controls := ina
    
PUB Menu
    return controls & SW1
    
PUB A
    return controls & SW2
    
PUB B
    return controls & SW3

PUB Left
    return controls & J_L    
    
PUB Right
    return controls & J_R

PUB Up
    return controls & J_U

PUB Down
    return controls & J_D