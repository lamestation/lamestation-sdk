''
'' LameLCD to VGA
''
''        Author: Marko Lukat
'' Last modified: 2014/06/09
''       Version: 0.3
''
OBJ
  view: "LameView"
  
VAR
  long  screen[512]

PUB null
'' This is not a top level object.

PUB Start
    
  view.init(@screen{0})
    
  return @screen{0}   

DAT