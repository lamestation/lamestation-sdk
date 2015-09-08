' LameSerial Serial Driver
' -------------------------------------------------
' Version: 1.0
' Copyright (c) 2013-2014 LameStation LLC
' See end of file for terms of use.
'
' This is a modified version of the Parallax Serial
' Terminal, with some functionality removed to
' save space.
' 
' Authors: Jeff Martin, Andy Lindsay, Chip Gracey
' -------------------------------------------------

CON
' Control Character Constants

    CS = 16                             ' CS: Clear Screen      
    CE = 11                             ' CE: Clear to End of line     
    CB = 12                             ' CB: Clear lines Below 
    
    HM =  1                             ' HM: HoMe cursor       
    PC =  2                             ' PC: Position Cursor in x,y          
    PX = 14                             ' PX: Position cursor in X         
    PY = 15                             ' PY: Position cursor in Y         
    
    NL = 13                             ' NL: New Line        
    LF = 10                             ' LF: Line Feed       
    ML =  3                             ' ML: Move cursor Left          
    MR =  4                             ' MR: Move cursor Right         
    MU =  5                             ' MU: Move cursor Up          
    MD =  6                             ' MD: Move cursor Down
    TB =  9                             ' TB: TaB          
    BS =  8                             ' BS: BackSpace          
                                        
    BP =  7                             ' BP: BeeP speaker          

CON
    BUFFER_LENGTH = 128                 ' Recommended as 64 or higher, but can be 2, 4, 8, 16, 32, 64, 128 or 256.
    BUFFER_MASK   = BUFFER_LENGTH - 1
    MAXSTR_LENGTH = 49                  ' Maximum length of received numerical string (not including zero terminator).

VAR
  long  cog                             ' Cog flag/id

  long  rx_head                         ' 9 contiguous longs (must keep order)
  long  rx_tail
  long  tx_head
  long  tx_tail
  long  rx_pin
  long  tx_pin
  long  rxtx_mode
  long  bit_ticks
  long  buffer_ptr
                     
  byte  rx_buffer[BUFFER_LENGTH]        ' Receive and transmit buffers
  byte  tx_buffer[BUFFER_LENGTH]

  byte  str_buffer[MAXSTR_LENGTH+1]     ' String buffer for numerical strings

PUB Start

    return StartRxTx(31, 30, 0, 115200)

PUB StartRxTx(rxpin, txpin, mode, baudrate) : okay
    Stop
    longfill(@rx_head, 0, 4)
    longmove(@rx_pin, @rxpin, 3)
    bit_ticks := clkfreq / baudrate
    buffer_ptr := @rx_buffer
    okay := cog := cognew(@entry, @rx_head) + 1

PUB Char(bytechr)

    repeat until (tx_tail <> ((tx_head + 1) & BUFFER_MASK))
    tx_buffer[tx_head] := bytechr
    tx_head := (tx_head + 1) & BUFFER_MASK
    
    if rxtx_mode & %1000
        CharIn

PUB Dec(value) | i, x

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    Char("-")                                                                   'and output sign

  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i                                                               
      Char(value / i + "0" + x*(i == 1))                                        'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      Char("0")                                                                 'If zero digit (or only digit) output it
    i /= 10                                                                     'Update divisor

PUB Bin(value, digits)

  value <<= 32 - digits
  repeat digits
    Char((value <-= 1) & 1 + "0")

PUB Hex(value, digits)

  value <<= (8 - digits) << 2
  repeat digits
    Char(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))
    
PUB Str(stringptr)

  repeat strsize(stringptr)
    Char(byte[stringptr++])

PUB Clear
  
  Char(CS)
  
PUB CharIn : bytechr

    repeat while (bytechr := RxCheck) < 0

PUB RxCount : count

  count := rx_head - rx_tail
  count -= BUFFER_LENGTH*(count < 0)

PUB RxFlush

  repeat while rxcheck => 0
  
PUB Stop

    if cog
        cogstop(cog~ - 1)
    longfill(@rx_head, 0, 9)
    
PRI RxCheck : bytechr
{Check if character received; return immediately.
  Returns: -1 if no byte received, $00..$FF if character received.}

  bytechr~~
  if rx_tail <> rx_head
    bytechr := rx_buffer[rx_tail]
    rx_tail := (rx_tail + 1) & BUFFER_MASK

PRI StrToBase(stringptr, base) : value | chr, index
{Converts a zero terminated string representation of a number to a value in the designated base.
Ignores all non-digit characters (except negative (-) when base is decimal (10)).}

  value := index := 0
  repeat until ((chr := byte[stringptr][index++]) == 0)
    chr := -15 + --chr & %11011111 + 39*(chr > 56)                              'Make "0"-"9","A"-"F","a"-"f" be 0 - 15, others out of range     
    if (chr > -1) and (chr < base)                                              'Accumulate valid values into result; ignore others
      value := value * base + chr                                                  
  if (base == 10) and (byte[stringptr] == "-")                                  'If decimal, address negative sign; ignore otherwise
    value := - value
       
DAT

                        org     0

entry                   mov     t1,par                'get structure address
                        add     t1,#4 << 2            'skip past heads and tails

                        rdlong  t2,t1                 'get rx_pin
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#4                 'get tx_pin
                        rdlong  t2,t1
                        mov     txmask,#1
                        shl     txmask,t2

                        add     t1,#4                 'get rxtx_mode
                        rdlong  rxtxmode,t1

                        add     t1,#4                 'get bit_ticks
                        rdlong  bitticks,t1

                        add     t1,#4                 'get buffer_ptr
                        rdlong  rxbuff,t1
                        mov     txbuff,rxbuff
                        add     txbuff,#BUFFER_LENGTH

                        test    rxtxmode,#%100  wz    'init tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_ne_c       or      outa,txmask
        if_z            or      dira,txmask

                        mov     txcode,#transmit      'initialize ping-pong multitasking
'
'
' Receive
'
receive                 jmpret  rxcode,txcode         'run chunk of tx code, then return

                        test    rxtxmode,#%001  wz    'wait for start bit on rx pin
                        test    rxmask,ina      wc
        if_z_eq_c       jmp     #receive

                        mov     rxbits,#9             'ready to receive byte
                        mov     rxcnt,bitticks
                        shr     rxcnt,#1
                        add     rxcnt,cnt                          

:bit                    add     rxcnt,bitticks        'ready next bit period

:wait                   jmpret  rxcode,txcode         'run chunk of tx code, then return

                        mov     t1,rxcnt              'check if bit receive period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        test    rxmask,ina      wc    'receive bit on rx pin
                        rcr     rxdata,#1
                        djnz    rxbits,#:bit

                        shr     rxdata,#32-9          'justify and trim received byte
                        and     rxdata,#$FF
                        test    rxtxmode,#%001  wz    'if rx inverted, invert byte
        if_nz           xor     rxdata,#$FF

                        rdlong  t2,par                'save received byte and inc head
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        sub     t2,rxbuff
                        add     t2,#1
                        and     t2,#BUFFER_MASK
                        wrlong  t2,par

                        jmp     #receive              'byte done, receive next byte
'
'
' Transmit
'
transmit                jmpret  txcode,rxcode         'run chunk of rx code, then return

                        mov     t1,par                'check for head <> tail
                        add     t1,#2 << 2
                        rdlong  t2,t1
                        add     t1,#1 << 2
                        rdlong  t3,t1
                        cmp     t2,t3           wz
        if_z            jmp     #transmit

                        add     t3,txbuff             'get byte and inc tail
                        rdbyte  txdata,t3
                        sub     t3,txbuff
                        add     t3,#1
                        and     t3,#BUFFER_MASK
                        wrlong  t3,t1

                        or      txdata,#$100          'ready byte to transmit
                        shl     txdata,#2
                        or      txdata,#1
                        mov     txbits,#11
                        mov     txcnt,cnt

:bit                    test    rxtxmode,#%100  wz    'output bit on tx pin 
                        test    rxtxmode,#%010  wc    'according to mode
        if_z_and_c      xor     txdata,#1
                        shr     txdata,#1       wc
        if_z            muxc    outa,txmask        
        if_nz           muxnc   dira,txmask
                        add     txcnt,bitticks        'ready next cnt

:wait                   jmpret  txcode,rxcode         'run chunk of rx code, then return

                        mov     t1,txcnt              'check if bit transmit period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        djnz    txbits,#:bit          'another bit to transmit?

                        jmp     #transmit             'byte done, transmit next byte
'
'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1

rxtxmode                res     1
bitticks                res     1

rxmask                  res     1
rxbuff                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxcode                  res     1

txmask                  res     1
txbuff                  res     1
txdata                  res     1
txbits                  res     1
txcnt                   res     1
txcode                  res     1


DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
