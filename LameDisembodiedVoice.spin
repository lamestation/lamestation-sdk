''''''''''''''
'' Prop-Talker - JT Cook - www.avalondreams.com - 11-29-10
''
'' This is a front end for speech synthesizer code by Philip C. Pilgrim and Chip Gracey
'' and inspired by the Gadget Gangster tutorial
'' 
'' Just load it up and type away and be amazed as your Propeller talks back!
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
 talkie  : "talk"

PUB start | n, Tile_Map_a, temp_key

talkie.start(27)
talkie.set_speaker(0,140) '

'talkie.say(string("This es thu laem stae shon")) 'play text

'talkie.say(string("laem --stae --shon ++is ++mae +++best frend")) 'play text

talkie.say(string("%110-------laemstaesh%200on")) 'play text

'talkie.say(string("%60thu +++hyoomans +++++ar -ded...."))
'talkie.say(string("%60+++thu ++++hyoomans +ar -de --ed...."))
'talkie.say(string("%60+++wi yoosd ++++poyson +us -ga ----ses...."))
'talkie.say(string("%60+++and wi ++++poysond +their -as --ses...."))

'talkie.say(string("_ae ++will ++des+++troy --you")) 'play text

repeat