''
'' LameControl over serial line
''
''        Author: Marko Lukat
'' Last modified: 2014/06/13
''       Version: 0.3
''
CON
  J_U  = |< 12
  J_D  = |< 13
  J_L  = |< 14
  J_R  = |< 15
   
  SW_A = |< 25
  SW_B = |< 26
     
  J_MASK = J_U|J_D|J_L|J_R
  S_MASK = SW_A|SW_B

OBJ
  serial: "FullDuplexSerial"
  
VAR
  long  cog, controls, shadow, stack[32]

PUB null
'' This is not a top level object.

PRI monitor

  serial.start(31, 30, %0000, 115200)
  repeat
    case serial.rxtime(50) | $20
        "a": shadow &= !SW_A
        "b": shadow &= !SW_B
        "l": shadow |= J_L
        "r": shadow |= J_R
        "u": shadow |= J_U
        "d": shadow |= J_D
      other: shadow := S_MASK
    
PUB Start

  shadow := S_MASK
  return cog := cognew(monitor, @stack{0}) +1

PUB Update

  ifnot cog
    Start
  controls := shadow

  return (controls & J_MASK) or (controls & S_MASK) <> S_MASK
  
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

DAT