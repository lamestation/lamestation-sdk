{{
PWM Output Driver With MIDI Interface
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON     _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

        PERIOD1 = 2000         ' 'FS = 80MHz / PERIOD1'
        FS      = 40000
        SAMPLES = 512
        PERVOICE = 1
        VOICES = 4
        OSCILLATORS = VOICES*PERVOICE
        REGPEROSC = 4

        OUTPUTPIN_LMONO = 27
        OUTPUTPIN_R = 27

'        OUTPUTPIN_LMONO = 15
 '       OUTPUTPIN_R = 15

'        MIDIPIN = 25
'        MIDIPIN = 23

        MIDIPIN = 9

        
        KEYBITS = $180
        HELDBIT = $80
        KEYONBIT = $100
        SUSPEDALBIT = $800000

        NOTEBITS = $7F
        'VELOCITYBITS = $7F00
        VOLUMEBITS = $FFFFFF

        ADSRBITS = $3000000 'new
        ATTACKBIT = $1000000
        SUSTAINBIT = $2000000

        'ADSR register
'       4bit      7bit       7bit       7bit       7bit
'       0000    0000000    0000000    0000000    0000000
'        W         R          S          D          A


        A_OFFSET = 0
        D_OFFSET = 7
        S_OFFSET = 14
        R_OFFSET = 21
        W_OFFSET = 28

        A_MASK = !($7F << A_OFFSET)
        D_MASK = !($7F << D_OFFSET)
        S_MASK = !($7F << S_OFFSET)
        R_MASK = !($7F << R_OFFSET)
        W_MASK = !($F << W_OFFSET)
        

        
        
        '0 - note (last 8 bits)
        '1 - target volume         
        '2 - phase inc
        '3 - phase acc

'NEW NOTE REGISTER

        'note registers
        ' $           ----------- 16 bits ----------
        ' $0000      0000000      0       0    0000000
        '            velocity   keyon    held  notenum




        'target volume register
        ' --- 6bits ---     2bit            --------- 24 bits ----------
        '    %0000_00       00             0000_0000 0000_0000 0000_0000
        '               ADSR state               current volume

        'phase inc and acc registers
        ' ----------------- 32 bits -------------
        ' %0000_0000 0000_0000 0000_0000 0000_0000       value to increment
        ' %0000_0000 0000_0000 0000_0000 0000_0000       accumulator
         



'CHANNEL PARAM REGISTER

        
        OSCREGS = OSCILLATORS*REGPEROSC
        OSCBITMASK = (OSCILLATORS-1) << 2
        INITVAL = 127


VAR

'ASM data structure (do not mess up)
long    parameter
long    outputlong

long    channelparam  'volume   'waveform LSB
long    channelADSR

long    oscRegister[OSCREGS]


byte    oscindexer
byte    oscindexcounter
byte    oscoffindexer

byte    newbyte
byte    statusbyte
byte    statusnibble
byte    statuschannel

byte    databyte1
byte    databyte2


OBJ
        pst   :       "lame_serial"
        pst2   :       "lame_serial"       


PRI ControlNote

            databyte1 := newbyte
            databyte2 := pst.CharIn

            pst2.Dec(databyte1)
            pst2.Char(" ")
            pst2.Dec(databyte2)
            pst2.Char(" ")

            'TURN NOTE ON
            if statusnibble == $90

                 if databyte1 < 128
                      oscindexcounter := 0
                      repeat while oscRegister[oscindexer+1] & ADSRBITS <> 0 and oscindexcounter < OSCILLATORS
                           oscindexcounter += 1
                           oscindexer += 4
                           oscindexer &= OSCBITMASK

                      if oscRegister[oscindexer] & HELDBIT == 0
                        oscRegister[oscindexer] := databyte1 + KEYBITS
                      else
                           oscindexcounter := 0
                           repeat while oscRegister[oscindexer] & HELDBIT <> 0 and oscindexcounter < OSCILLATORS
                               oscindexcounter += 1
                               oscindexer += 4
                               oscindexer &= OSCBITMASK
                           oscRegister[oscindexer] := databyte1 + KEYBITS

                      oscindexer += 4
                      oscindexer &= OSCBITMASK

            'TURN NOTE OFF
            if statusnibble == $80 or databyte2 == 0
                ' pst.Str(String("noteoff "))
                 if channelADSR & SUSPEDALBIT == 0
                     repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
                          if oscRegister[oscoffindexer] & NOTEBITS == databyte1
                                oscRegister[oscoffindexer] &= !KEYBITS
                 else
                     repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
                          if oscRegister[oscoffindexer] & NOTEBITS == databyte1
                                oscRegister[oscoffindexer] &= !HELDBIT           '9th bit


PRI ControlKnob

            databyte1 := newbyte
            databyte2 := pst.CharIn

            pst2.Hex(databyte1,2)
            pst2.Char(" ")
            pst2.Hex(databyte2,2)
            pst2.Char(" ")

            'modulation wheel
           if databyte1 == $01




            'ADSR controls
           elseif databyte1 == $4A          'attack
               channelADSR := (channelADSR & A_MASK) + (databyte2 << A_OFFSET)

           elseif databyte1 == $47          'decay
               channelADSR := (channelADSR & D_MASK) + (databyte2 << D_OFFSET)

           elseif databyte1 == $0A          'sustain
               channelADSR := (channelADSR & S_MASK) + (databyte2 << S_OFFSET)

           elseif databyte1 == $07          'release
               channelADSR := (channelADSR & R_MASK) + (databyte2 << R_OFFSET)


            'waveform control
           elseif databyte1 == $49          'waveform
               channelADSR := (channelADSR & W_MASK) + (databyte2 << W_OFFSET)

           'same knobs with assign button pressed
           elseif databyte1 == $48
               channelparam := (channelparam & $FFFF00FF) + (databyte2 << 8) 'adjust volume

           elseif databyte1 == $5B

           elseif databyte1 == $5D

             'SUSTAIN PEDAL
           elseif databyte1 == $40
                if databyte2 <> 0
                    channelADSR |= SUSPEDALBIT
                else
                    channelADSR &= !SUSPEDALBIT
                    repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
                          if oscRegister[oscoffindexer] & HELDBIT == 0           'if note is not being held
                                oscRegister[oscoffindexer] &= !KEYONBIT        '9th bit
                pst2.Hex(channelADSR, 8)


           else

PRI ControlPitchBend

            databyte1 := newbyte
            databyte2 := pst.CharIn

            pst2.Dec(databyte1)
            pst2.Char(" ")
            pst2.Dec(databyte2)
            pst2.Char(" ")
            
            pst2.Char(pst#NL)

PRI InitPlugin


PUB go | x                                                 
  pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)
  pst2.StartRxTx(31, 30, 0, 115200)
  pst2.Clear
    
  parameter := @sine
  channelparam := (INITVAL << 8)
  channelADSR := LONG[@instruments][0]
  
  repeat oscindexer from 0 to OSCREGS-1 step REGPEROSC
      oscRegister[oscindexer] := 0
      oscRegister[oscindexer+1] := 0
      oscRegister[oscindexer+2] := 0
      oscRegister[oscindexer+3] := 0
  oscindexer := 0
  oscindexcounter := 0
     
  cognew(@oscmodule, @parameter)    'start assembly cog
  repeat
        'system control messages begin with $FF
      'status byte, data bytes (1-2)

      newbyte := pst.CharIn

      if newbyte & $80
         statusbyte := newbyte
         statusnibble := statusbyte & $F0
         statuschannel := statusbyte & $0F
         pst2.Char(pst#NL)
         pst2.Hex(statusbyte, 2)
         pst2.Char(" ")

      else
         if statusnibble == $E0
           ControlPitchBend

         elseif statusnibble == $B0
           ControlKnob

         elseif statusnibble == $90 or statusnibble == $80
           ControlNote

         'ACTIVE SENSING GARBAGE
         elseif statusbyte == $FE

         else


DAT

instruments
'tubular bells
long    (127 + (4 << D_OFFSET) + (80 << S_OFFSET) + (0 << R_OFFSET) + (3 << W_OFFSET))
   
'jarn harpsichord
long    (127 + (41 << D_OFFSET) + (60 << S_OFFSET) + (0 << R_OFFSET) + (0 << W_OFFSET))

'super square
long    (10 + (127 << D_OFFSET) + (0 << S_OFFSET) + (0 << R_OFFSET) + (1 << W_OFFSET))

'attack but no release....
long    (127 + (12 << D_OFFSET) + (0 << S_OFFSET) + (0 << R_OFFSET) + (0 << W_OFFSET))

'POWER
long    (127 + (12 << D_OFFSET) + (127 << S_OFFSET) + (0 << R_OFFSET) + (0 << W_OFFSET))

'accordion
long    (127 + (12 << D_OFFSET) + (127 << S_OFFSET) + (64 << R_OFFSET) + (5 << W_OFFSET))





'quarter sine table
sine 
byte    0,1,3,4,6,7,9,10,12,13,15,17,18,20,21,23
byte    24,26,27,29,30,32,33,35,36,38,39,41,42,44,45,47
byte    48,50,51,52,54,55,57,58,59,61,62,63,65,66,67,69
byte    70,71,73,74,75,76,78,79,80,81,82,84,85,86,87,88
byte    89,90,91,93,94,95,96,97,98,99,100,101,102,102,103,104
byte    105,106,107,108,108,109,110,111,112,112,113,114,114,115,116,116
byte    117,117,118,119,119,120,120,121,121,121,122,122,123,123,123,124
byte    124,124,125,125,125,125,126,126,126,126,126,126,126,126,126,126



freqTable
long    1071, 1135, 1202, 1274, 1350, 1430, 1515, 1605
long    1700, 1802, 1909, 2022, 2143, 2270, 2405, 2548
long    2700, 2860, 3030, 3210, 3401, 3604, 3818, 4045
long    4286, 4540, 4810, 5097, 5400, 5721, 6061, 6421
long    6803, 7208, 7636, 8090, 8572, 9081, 9621, 10194
long    10800, 11442, 12122, 12843, 13607, 14416, 15273, 16181
long    17144, 18163, 19243, 20388, 21600, 22884, 24245, 25687
long    27214, 28833, 30547, 32363, 34288, 36327, 38487, 40776
long    43200, 45769, 48491, 51374, 54429, 57666, 61095, 64727
long    68576, 72654, 76974, 81552, 86401, 91539, 96982, 102749
long    108859, 115332, 122190, 129455, 137153, 145309, 153949, 163104
long    172802, 183078, 193964, 205498, 217718, 230664, 244380, 258911
long    274307, 290618, 307899, 326208, 345605, 366156, 387929, 410996
long    435436, 461328, 488760, 517823, 548614, 581237, 615799, 652416
long    691211, 732313, 775858, 821993, 870872, 922656, 977520, 1035647
long    1097229, 1162474, 1231598, 1304833, 1382423, 1464626, 1551717, 1643987





piano
byte    130, 141, 154, 168, 200, 217, 230, 242, 240, 237, 233, 230, 226, 222, 212, 208
byte    204, 198, 197, 195, 193, 192, 190, 185, 182, 179, 176, 171, 168, 166, 161, 159
byte    157, 154, 153, 151, 150, 149, 150, 152, 157, 160, 162, 166, 168, 169, 170, 170
byte    170, 169, 168, 169, 169, 171, 172, 173, 173, 173, 172, 171, 170, 170, 170, 172
byte    174, 175, 178, 179, 179, 176, 174, 171, 168, 160, 157, 153, 147, 145, 142, 138
byte    136, 134, 133, 131, 131, 130, 129, 129, 128, 127, 126, 126, 125, 125, 125, 125
byte    125, 125, 125, 127, 127, 128, 130, 131, 132, 133, 133, 134, 134, 134, 135, 135
byte    136, 137, 138, 138, 138, 139, 139, 139, 139, 138, 137, 136, 134, 131, 129, 128
byte    125, 124, 123, 123, 123, 123, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122
byte    122, 122, 121, 121, 121, 120, 120, 119, 118, 117, 116, 114, 113, 113, 111, 111
byte    111, 110, 110, 111, 111, 114, 116, 119, 128, 134, 141, 148, 147, 142, 128, 121
byte    114, 108, 98, 95, 92, 90, 90, 90, 91, 92, 92, 93, 93, 93, 93, 93
byte    94, 94, 96, 96, 97, 98, 98, 98, 98, 100, 101, 102, 104, 105, 106, 108
byte    109, 110, 111, 113, 114, 114, 114, 114, 114, 113, 112, 112, 111, 111, 110, 110
byte    108, 107, 107, 105, 104, 103, 99, 97, 95, 93, 90, 89, 89, 89, 89, 89
byte    91, 92, 93, 97, 100, 102, 104, 107, 107, 108, 107, 107, 107, 108, 110, 112
byte    119, 124, 130, 138, 157, 168, 180, 202, 208, 209, 197, 191, 184, 177, 161, 152
byte    144, 133, 130, 128, 128, 129, 130, 132, 132, 132, 131, 129, 128, 126, 123, 121
byte    119, 115, 113, 111, 109, 105, 104, 103, 103, 104, 106, 108, 109, 110, 110, 110
byte    110, 110, 109, 108, 108, 109, 110, 111, 113, 115, 116, 116, 117, 118, 119, 122
byte    124, 127, 133, 137, 140, 145, 147, 148, 148, 146, 144, 143, 139, 137, 135, 132
byte    131, 129, 128, 126, 125, 125, 125, 125, 125, 126, 126, 126, 127, 128, 129, 130
byte    132, 133, 135, 138, 140, 141, 146, 149, 152, 155, 161, 164, 166, 170, 170, 169
byte    164, 161, 157, 149, 145, 141, 137, 132, 129, 127, 122, 119, 116, 112, 110, 108
byte    105, 104, 104, 103, 103, 103, 104, 104, 105, 105, 106, 107, 107, 107, 108, 108
byte    108, 107, 106, 106, 105, 105, 105, 103, 103, 102, 101, 99, 98, 97, 95, 95
byte    95, 95, 96, 96, 97, 100, 102, 105, 111, 115, 120, 134, 141, 146, 147, 144
byte    138, 132, 121, 117, 113, 109, 108, 108, 109, 110, 112, 113, 116, 118, 119, 122
byte    124, 126, 130, 133, 135, 139, 141, 143, 144, 147, 148, 148, 150, 150, 151, 151
byte    150, 150, 149, 147, 145, 144, 139, 137, 134, 128, 125, 122, 117, 114, 112, 110
byte    105, 103, 101, 97, 95, 93, 89, 88, 86, 84, 80, 78, 76, 74, 73, 73
byte    73, 74, 74, 77, 80, 82, 85, 91, 93, 95, 98, 100, 101, 105, 108, 112



                        org

oscmodule               mov       dira, diraval       'set APIN to output
                        mov       ctra, ctraval       'establish counter A mode and APIN
                        mov       frqa, #1            'set counter to increment 1 each cycle

                        mov       time, cnt           'record current time
                        add       time, period        'establish next period

'ESTABLISH COMMUNICATION LINK BETWEEN SPIN AND PASM              

                        'get address of sine table
                        mov       Addr, par
                        rdlong    tableAddr, Addr

              
              
                        'get address of frequency table
                        mov       freqAddr, tableAddr
                        add       freqAddr, #128

                        mov       organAddr, freqAddr
                        add       organAddr, fivetwelve

                        

                        'get address to write out to
                        mov       outputAddr, Addr
                        add       outputAddr, #4

                        'get address of channel parameters
                        mov       paramAddr, outputAddr
                        add       paramAddr, #4
                        mov       adsrAddr, paramAddr
                        add       adsrAddr, #4

                        'get address of oscillator registers
                        mov       oscAddr, adsrAddr
                        add       oscAddr, #4

 

'MAIN LOOP START       
mainloop                waitcnt   time, period        'wait until next period
                        neg       phsa, output         'back up phsa so that it trips "value cycles from now

                        'UPDATE CHANNEL PARAMETERS BEFORE ANYTHING ELSE 


                        rdlong    adsrtemp, adsrAddr
              
              
                        'attack
                        mov       attack, adsrtemp
                        and       attack, #$7F
                        'decay
                        shr       adsrtemp, doffset
                        mov       decay, adsrtemp
                        and       decay, #$7F
                        'sustain 
                        shl       adsrtemp, #3
                        mov       sustain, adsrtemp
                        and       sustain, bigsusmask
                        'release               
                        shr       adsrtemp, #17
                        mov       release, adsrtemp
                        and       release, #$7F  
                        
                        'waveform               
                        shr       adsrtemp, #7
                        mov       waveform, adsrtemp
                        and       waveform, #$F  


              

                        'INITIALIZE OSCILLATOR LOOP
                        mov       output, #0
                        mov       oscIndex, oscTotal
                        mov       oscPtr, oscAddr
              
oscloop                 'READ NOTE VALUE AND FIND FREQUENCY FROM LOOKUP
                        rdlong    noteAddrtemp, oscPtr

                        and       noteAddrtemp, keyonmask     nr, wz 'SET Z FLAG FOR LATER OPERATION, REMEMBER!!!

                        and       noteAddrtemp, #$7F
                        shl       noteAddrtemp, #2
                        add       noteAddrtemp, freqAddr
                        add       oscPtr, #4
                        




                        
                        'ADSR FILTER (or in this case, ADS filter?)
                        rdlong    voltemp, oscPtr
                        mov       vollongtemp, voltemp

                        'since Z flag still set from previous operation, no extra instructions needed
                        and       vollongtemp, ADSRmask
if_z                    mov       vollongtemp, #0
if_nz                   cmp       vollongtemp, #1               wc
if_nz_and_c             or        vollongtemp, attackmask



                            

                        and       vollongtemp, attackmask       nr, wz  'ATTACK  
if_nz                   mov       targetvol, sustainfull
if_nz                   jmp       #attackjump

                        and       vollongtemp, sustainmask      nr, wz  'CHECK IF SHOULD BE SUSTAINING
if_nz                   mov       targetvol, sustain
if_z                    mov       targetvol, #0
attackjump


                        and       voltemp, volmask
                        cmps      voltemp, targetvol        wc
if_c                    adds      voltemp, attack
if_nc                   subs      voltemp, decay
if_nc                   and       vollongtemp, attackmask        nr, wz
if_nc_and_nz            add       vollongtemp, attackmask

                      
                        cmps      voltemp, #0           wc
if_c                    mov       voltemp, #0

                        add       voltemp, vollongtemp
                        wrlong    voltemp, oscPtr

                        add       oscPtr, #4




              
                        'UPDATE PHASEINC OF OSC FROM FREQUENCY
                        rdlong    phaseinc, noteAddrtemp      
                        wrlong    phaseinc, oscPtr
                        add       noteAddrtemp, #4
                        add       oscPtr, #4

                        'ADD PHASEINC TO PHASEACC OF OSC          
                        rdlong    phase, oscPtr
                        add       phase, phaseinc
                        wrlong    phase, oscPtr
                        add       oscPtr, #4





              
'PHASE ACCUMULATOR
                        'shift and truncate phase to 512 samples
                        shr     phase, #12
                        and     phase, #$1FF


'WAVEFORM SELECTOR
        'jumps the program counter to the appropriate
        'waveform
                        cmp     waveform, #1            wc, wz
if_c                    jmp     #:rampwave
if_nc_and_z             jmp     #:squarewave
                        cmp     waveform, #3            wc, wz
if_c                    jmp     #:triwave
if_nc_and_z             jmp     #:sinewave
                        cmp     waveform, #5            wc, wz
if_c                    jmp     #:whitenoise
if_nc_and_z             jmp     #:screechwave 

 
'RAMP WAVE
        'if ramp wave, fit the truncated phase accumulator into
        'the proper 8-bit scaling and output as waveform
:rampwave               mov     osctemp, phase
                        subs    osctemp, #256
                        sar     osctemp, #1
                        jmp     #:oscOutput

  
'SQUARE WAVE
        'if square wave, compare truncated phase with 128
        '(half the height of 8 bits) and scale
:squarewave             cmp     phase, #256             wc
if_nc                   mov     osctemp, #0
if_c                    mov     osctemp, #256
                        subs    osctemp, #128   
                        jmp     #:oscOutput


'TRIANGLE WAVE
        'if triangle wave, double the amplitude of a square
        'wave and add truncated phase for first half, and
        'subtract truncated phase for second half of cycle
:triwave                cmp     phase, #256             wc
if_c                    mov     osctemp, phase
if_nc                   mov     osctemp, #511
if_nc                   subs    osctemp, phase
                        subs    osctemp, #128
                        jmp     #:oscOutput


'SINE WAVE
        'if sine wave, use truncated phase to read values
        'from sine table in main memory.  This requires
        'the most time to complete, with the exception
        'of noise generation
:sinewave               mov     Addrtemp, phase
                        and     Addrtemp, #$FF
                        cmp     Addrtemp, #128          wc
if_nc                   xor     Addrtemp, #$FF
                        and     Addrtemp, #$7F

                        shl     Addrtemp, #5
                        add     Addrtemp, sineAddr
                        rdword  osctemp, Addrtemp
                        shr     osctemp, #9

                        cmp     phase, #256             wc              
if_nc                   neg     osctemp, osctemp

                        jmp     #:oscOutput           



'ORGAN GENERATION
:screechwave            mov     Addrtemp, phase
                        add     Addrtemp, organAddr
                        rdbyte  osctemp, Addrtemp
                        subs    osctemp, #128

                        jmp     #:oscOutput         




'WHITE NOISE GENERATOR
        'pseudo-random number generator truncated to 8 bits.
:whitenoise             sar     rand, #1
                        mov     rand2, rand
                        and     rand2, #$FF
                        mov     rand3, rand2
                        shl     rand3, #2
                        xor     rand3, rand2
                        shl     rand3, #24
                        add     rand, rand3

                        mov     osctemp, rand
                        and     osctemp, #$FF



:oscOutput
'UNROLLED ADSR MULTIPLIER   (calculates proper volume of this oscillator's sample)
                        mov     multtemp, osctemp
                        mov     osctemp, #0
                        shr     voltemp, #13 'shift right 10 for sustain then 3 for multiplier
                        
                        and     voltemp, #%00001      nr, wz
if_nz                   add     osctemp, multtemp                             
                        shl     multtemp, #1
                        and     voltemp, #%00010      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%00100      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%01000      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%10000      nr, wz
if_nz                   add     osctemp, multtemp
                            
                        sar     osctemp, #3     '5-2





'ADDS OUTPUT OF THIS OSCILLATOR TO OUTPUT VALUE    
                        adds    output, osctemp
                        djnz    oscIndex, #oscloop


'FINAL VOLUME ADJUSTMENT AND OUTPUT TO SOUND         
                        adds    output, outputoffset


                        wrlong    output, outputAddr
      
'LOOP BACK FOR NEXT SAMPLE
                        jmp       #mainloop






diraval       long      |< OUTPUTPIN_LMONO               'APIN=0
ctraval       long      %00100 << 26 + OUTPUTPIN_LMONO   'NCO/PWM APIN=0
period        long      PERIOD1               '800kHz period (_clkfreq / period)
time          long      0

waveform      long      3     '0 = ramp    1 = square    2 = triangle    3 = sine    4 = pseudo-random noise    5 = sine perversion
volume        long      127

multarg       long      3
multtemp      long      2

attack        long      0
decay         long      0
sustain       long      127 << 10
sustainfull   long      127 << 10
release       long      0
adsrtemp      long      0
targetvol     long      0
volAddrtemp   long      0
voltemp       long      0
vollongtemp   long      0
volmask       long      VOLUMEBITS

keyonmask     long      KEYONBIT
heldmask      long      HELDBIT
ADSRmask      long      ADSRBITS
sustainmask   long      SUSTAINBIT
attackmask    long      ATTACKBIT
bigsusmask    long      $1FC00


aoffset       long      A_OFFSET
doffset       long      D_OFFSET
soffset       long      S_OFFSET
roffset       long      R_OFFSET
woffset       long      W_OFFSET

amask         long      !A_MASK
dmask         long      !D_MASK
smask         long      !S_MASK
rmask         long      !R_MASK
wmask         long      !W_MASK


fivetwelve    long      512

'variables for oscillator controller
oscPtr        long      0
oscIndex      long      0

phaseinc      long      0
phase         long      0
noteAddrtemp  long      0
notelongtemp  long      0

'oscillator data                                                                                      
oscAddr       long      0
oscTotalRegs  long      OSCREGS
oscTotal      long      OSCILLATORS

'volumeshift   long      1

osctemp       long      0
outputoffset  long      PERIOD1/2
output        long      0

Addr          long      0
Addrtemp      long      0
tableAddr     long      0
freqAddr      long      0
outputAddr    long      0
sineAddr      long      $E000
organAddr     long      0

paramAddr     long      0
adsrAddr      long      0

rand          long      203943
rand2         long      0
rand3         long      0
              fit 496


   
DAT


                        org

outputmodule            mov       dira, outputdir       'set APIN to output
                        mov       ctra, outputctr       'establish counter A mode and APIN
                        mov       frqa, #1            'set counter to increment 1 each cycle

                        mov       time, cnt           'record current time
                        add       time, outputper     'establish next period


'MAIN LOOP START       
outputloop              waitcnt   time, outputper      'wait until next period
                        neg       phsa, adurrr         'back up phsa so that it trips "value cycles from now




                        

outputdir     long      |< OUTPUTPIN_LMONO               'APIN=0
outputctr     long      %00100 << 26 + OUTPUTPIN_LMONO   'NCO/PWM APIN=0
outputper     long      PERIOD1               '800kHz period (_clkfreq / period)
outputtime    long      0

adurrr        long      34

              fit 496
              
              
{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
