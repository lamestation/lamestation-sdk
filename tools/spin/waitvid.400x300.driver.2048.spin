''
'' VGA scanline driver 400x300 (single cog) - video driver and pixel generator
''
''        Author: Marko Lukat
'' Last modified: 2013/01/11
''       Version: 0.10
''
'' - timing signalled as SVGA 800x600
'' - vertical blank start sets frame indicator (FI) to 0
'' - once the Nth scanline has been fetched the FI is set to N+1       
''
'' 20121007: added minimal translation table
'' 20121229: now capable of using 64/256 colours (RRGGBBHV / RRGGBBgr + xxxxxxHV)
''           -  64c: $FC/2/2 (vpin/vgrp/sgrp)
''           - 256c: $FF/2/3
'' 20121230: simplified vertical blanking code
''
'' Note: With idle state being %00 {%hv} the switch code can be further simplified.
''       As this was the first converted driver I left the generic solution intact
''       so it can easily be adapted for other drivers (with non-zero idle state).
''
OBJ
  system: "core.con.system"
  
PUB null
'' This is not a top level object.

PUB init(ID, mailbox)

  return system.launch(ID, @driver, mailbox)
  
DAT             org     0                       ' cog binary header

header_2048     long    system#ID_2             ' magic number for a cog binary
                word    header_size             ' header size
                word    system#MAPPING          ' flags
                word    0, 0                    ' start register, register count

                word    @__table - @header_2048 ' translation table byte offset

header_size     fit     16
                
DAT             org     0                       ' video driver

driver          jmpret  $, #setup               '  -4   once

                mov     dira, mask              ' drive outputs

' horizontal timing 400(800) 20(40) 64(128) 44(88)
'   vertical timing 300(600)  1(1)   4(4)   23(23)

vsync           mov     lcnt, #0                ' |
                wrlong  lcnt, blnk              ' reset line counter (once)

                mov     vscl, full              ' 32/528
                
'               mov     ecnt, #1
                waitvid sync, #%%0011           ' front porch
'               djnz    ecnt, #$-1

                xor     sync, #$0101            ' active

                mov     ecnt, #4
                waitvid sync, #%%0011           ' vertical sync
                djnz    ecnt, #$-1

                xor     sync, #$0101            ' inactive

                mov     ecnt, #23
                waitvid sync, #%%0011           ' back porch
                djnz    ecnt, #$-1
                                                                                    
' Vertical sync chain done, do visible area.

                mov     scnt, #res_y

:loop           call    #prefix                 ' sync and back porch
                jmpret  suffix_ret, #emit_0     ' visible line and front porch

                call    #prefix                 ' sync and back porch
                jmpret  suffix_ret, #emit_1     ' visible line and front porch

                djnz    scnt, #:loop            ' repeat for all lines

                jmp     #vsync                  ' next frame


prefix          mov     vscl, slow              ' 32/108
                waitvid sync, #%%2011           ' latch sync and back porch

                mov     cnt, cnt                ' cover sync pulse period               (%%)
                add     cnt, #9{14}+(64 * 4)    ' because we drive sync lines
                waitcnt cnt, #135               ' manually next                         (%%)

                mov     outa, idle              ' take over sync lines                  (##)
prefix_ret      ret


suffix          mov     vscl, hs_f              ' 1/20
                waitvid sync, #%%02             ' latch front porch

'                       waitvid                          
'            | S   D   e   .   .   .   R |   mov vcfg    |   mov outa    |
' clock  
'                          │               │               │               │
'   PLL  
' pixel  1:4 │+4
'                          │               │   pixel %%2   │   pixel %%0   |
'  outa  

                mov     vcfg, vcfg_sync         ' drive/change sync lines               (##)
                mov     outa, #0                ' stop interfering

        if_nc   wrlong  lcnt, blnk              ' report current line
suffix_ret      ret

' Even line emitter (fetch & emit).

emit_0          waitcnt cnt, #0                 ' re-sync after back porch              (%%)

' At this point the video h/w is driving the sync lines low (colour %%2).
' outa has taken over long ago so we can switch configuration here.

                mov     vcfg, vcfg_norm         ' -12   disconnect sync from video h/w  (##)
                mov     addr, base              '  -8   working copy
                mov     vscl, hvis              '  -4   1/4

                rdlong  pal+$00, addr           '  +0 =
                cmp     pal+$00, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$01, addr           '  +0 =
                cmp     pal+$01, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$02, addr           '  +0 =
                cmp     pal+$02, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$03, addr           '  +0 =
                cmp     pal+$03, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$04, addr           '  +0 =
                cmp     pal+$04, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$05, addr           '  +0 =
                cmp     pal+$05, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$06, addr           '  +0 =
                cmp     pal+$06, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$07, addr           '  +0 =
                cmp     pal+$07, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$08, addr           '  +0 =
                cmp     pal+$08, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$09, addr           '  +0 =
                cmp     pal+$09, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0A, addr           '  +0 =
                cmp     pal+$0A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0B, addr           '  +0 =
                cmp     pal+$0B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0C, addr           '  +0 =
                cmp     pal+$0C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0D, addr           '  +0 =
                cmp     pal+$0D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0E, addr           '  +0 =
                cmp     pal+$0E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$0F, addr           '  +0 =
                cmp     pal+$0F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           0..63

                rdlong  pal+$10, addr           '  +0 =
                cmp     pal+$10, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$11, addr           '  +0 =
                cmp     pal+$11, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$12, addr           '  +0 =
                cmp     pal+$12, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$13, addr           '  +0 =
                cmp     pal+$13, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$14, addr           '  +0 =
                cmp     pal+$14, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$15, addr           '  +0 =
                cmp     pal+$15, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$16, addr           '  +0 =
                cmp     pal+$16, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$17, addr           '  +0 =
                cmp     pal+$17, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$18, addr           '  +0 =
                cmp     pal+$18, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$19, addr           '  +0 =
                cmp     pal+$19, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1A, addr           '  +0 =
                cmp     pal+$1A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1B, addr           '  +0 =
                cmp     pal+$1B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1C, addr           '  +0 =
                cmp     pal+$1C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1D, addr           '  +0 =
                cmp     pal+$1D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1E, addr           '  +0 =
                cmp     pal+$1E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$1F, addr           '  +0 =
                cmp     pal+$1F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           64..127

                rdlong  pal+$20, addr           '  +0 =
                cmp     pal+$20, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$21, addr           '  +0 =
                cmp     pal+$21, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$22, addr           '  +0 =
                cmp     pal+$22, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$23, addr           '  +0 =
                cmp     pal+$23, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$24, addr           '  +0 =
                cmp     pal+$24, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$25, addr           '  +0 =
                cmp     pal+$25, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$26, addr           '  +0 =
                cmp     pal+$26, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$27, addr           '  +0 =
                cmp     pal+$27, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$28, addr           '  +0 =
                cmp     pal+$28, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$29, addr           '  +0 =
                cmp     pal+$29, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2A, addr           '  +0 =
                cmp     pal+$2A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2B, addr           '  +0 =
                cmp     pal+$2B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2C, addr           '  +0 =
                cmp     pal+$2C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2D, addr           '  +0 =
                cmp     pal+$2D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2E, addr           '  +0 =
                cmp     pal+$2E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$2F, addr           '  +0 =
                cmp     pal+$2F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           128..191

                rdlong  pal+$30, addr           '  +0 =
                cmp     pal+$30, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$31, addr           '  +0 =
                cmp     pal+$31, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$32, addr           '  +0 =
                cmp     pal+$32, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$33, addr           '  +0 =
                cmp     pal+$33, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$34, addr           '  +0 =
                cmp     pal+$34, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$35, addr           '  +0 =
                cmp     pal+$35, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$36, addr           '  +0 =
                cmp     pal+$36, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$37, addr           '  +0 =
                cmp     pal+$37, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$38, addr           '  +0 =
                cmp     pal+$38, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$39, addr           '  +0 =
                cmp     pal+$39, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$3A, addr           '  +0 =
                cmp     pal+$3A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$3B, addr           '  +0 =
                cmp     pal+$3B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$3C, addr           '  +0 =
                cmp     pal+$3C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$3D, addr           '  +0 =
                cmp     pal+$3D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$3E, addr           '  +0 =
                cmp     pal+$3E, #%%3210        '  +8   WHOP
                add     addr,#4                 '  -4
                rdlong  pal+$3F, addr           '  +0 =
                cmp     pal+$3F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           192..255

                rdlong  pal+$40, addr           '  +0 =
                cmp     pal+$40, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$41, addr           '  +0 =
                cmp     pal+$41, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$42, addr           '  +0 =
                cmp     pal+$42, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$43, addr           '  +0 =
                cmp     pal+$43, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$44, addr           '  +0 =
                cmp     pal+$44, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$45, addr           '  +0 =
                cmp     pal+$45, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$46, addr           '  +0 =
                cmp     pal+$46, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$47, addr           '  +0 =
                cmp     pal+$47, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$48, addr           '  +0 =
                cmp     pal+$48, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$49, addr           '  +0 =
                cmp     pal+$49, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4A, addr           '  +0 =
                cmp     pal+$4A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4B, addr           '  +0 =
                cmp     pal+$4B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4C, addr           '  +0 =
                cmp     pal+$4C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4D, addr           '  +0 =
                cmp     pal+$4D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4E, addr           '  +0 =
                cmp     pal+$4E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$4F, addr           '  +0 =
                cmp     pal+$4F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           256..319

                rdlong  pal+$50, addr           '  +0 =
                cmp     pal+$50, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$51, addr           '  +0 =
                cmp     pal+$51, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$52, addr           '  +0 =
                cmp     pal+$52, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$53, addr           '  +0 =
                cmp     pal+$53, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$54, addr           '  +0 =
                cmp     pal+$54, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$55, addr           '  +0 =
                cmp     pal+$55, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$56, addr           '  +0 =
                cmp     pal+$56, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$57, addr           '  +0 =
                cmp     pal+$57, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$58, addr           '  +0 =
                cmp     pal+$58, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$59, addr           '  +0 =
                cmp     pal+$59, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5A, addr           '  +0 =
                cmp     pal+$5A, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5B, addr           '  +0 =
                cmp     pal+$5B, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5C, addr           '  +0 =
                cmp     pal+$5C, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5D, addr           '  +0 =
                cmp     pal+$5D, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5E, addr           '  +0 =
                cmp     pal+$5E, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$5F, addr           '  +0 =
                cmp     pal+$5F, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4           320..383

                rdlong  pal+$60, addr           '  +0 =
                cmp     pal+$60, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$61, addr           '  +0 =
                cmp     pal+$61, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$62, addr           '  +0 =
                cmp     pal+$62, #%%3210        '  +8   WHOP
                add     addr, #4                '  -4
                rdlong  pal+$63, addr           '  +0 =
                cmp     pal+$63, #%%3210        '  +8   WHOP
                add     lcnt, #1                '  -4           384..399, line has been fetched

                jmpret  $, #suffix wc,nr        '  +0 = chain call (carry clear)

' Odd line emitter (emit only).

emit_1          waitcnt cnt, #0                 ' re-sync after back porch              (%%)

' At this point the video h/w is driving the sync lines low (colour %%2).
' outa has taken over long ago so we can switch configuration here.

                mov     vcfg, vcfg_norm         ' -12   disconnect sync from video h/w  (##)
                movd    :vid, #pal+$00          '  -8   colour buffer
                mov     vscl, hvis              '  -4   1/4

                mov     ecnt, #100 -1           '  +0 = quad pixel count (last one separate)
                test    $, #1 wc                '  +4   set carry
:vid            cmp     0-0, #%%3210            '  +8   WHOP
                addx    $-1, #511{+C}           '  -4
                djnz    ecnt, #:vid -1          '  +0 = maintain 16 cycle loop

                cmp     pal+$63, #%%3210        '  +8   WHOP

                jmpret  zero, #suffix wc,nr     '  -4   chain call (carry set)

' initialised data and/or presets

idle            long    (hv_idle & $00FF) << (sgrp * 8)
sync            long    (hv_idle ^ $0200)  & $FFFF
                        
hvis            long     1 << 12 | 4            '   1/4
hs_f            long     1 << 12 | 20           '   1/20
slow            long    32 << 12 | 108          '  32/108
full            long    32 << 12 | 528          '  32/528

vcfg_norm       long    %0_01_1_00_000 << 23 | vgrp << 9 | vpin
vcfg_sync       long    %0_01_1_00_000 << 23 | sgrp << 9 | %11

mask            long    vpin << (vgrp * 8) | %11 << (sgrp * 8)

blnk            long    -4
base            long    +0

' Stuff below is re-purposed for temporary storage.

setup           rdlong  cnt, #0                 '  +0 = clkfreq

                add     blnk, par               '  +8   frame indicator
                neg     href, cnt               '  -4   hub window reference
                add     base, par               '  +0 = scanline buffer

' Upset video h/w and relatives.

                movi    ctra, #%0_00001_101     ' PLL, VCO/4
                movi    frqa, #%0001_00000      ' 5MHz * 16 / 4 = 20MHz

                mov     vscl, hvis              ' 1/4
                mov     vcfg, vcfg_sync         ' VGA, 4 colour mode

                shr     cnt, #10                ' ~1ms
                add     cnt, cnt               
                waitcnt cnt, #0                 ' PLL needs to settle

' The first issued waitvid is a bit of a gamble if we don't know where the WHOP
' is located. We could do some fancy math or simply issue a dummy waitvid.

                waitvid zero, #0                ' dummy (first one is unpredictable)
                waitvid zero, #0                ' point of reference

                add     href, cnt               ' get current sync slot
                shr     href, #2                ' 4 system clocks per pixel
                neg     href, href              ' |
                and     href, #%11              ' calculate adjustment

' WHOP is reasonably far away so we can update vscl without re-sync.

                add     vscl, href              ' |
                waitvid zero, #0                ' stretch frame
                sub     vscl, href              ' |
                waitvid zero, #0                ' restore frame

' Setup complete, do the heavy lifting upstairs ...

                jmp     %%0                     ' return

' uninitialised data and/or temporaries

                org     setup
                
href            res     1                       ' hub window reference

ecnt            res     1                       ' element count
lcnt            res     1                       ' line counter
scnt            res     1                       ' scanlines
addr            res     1                       ' colour buffer reference

pal             res     100                     ' colour buffer

tail            fit
                
DAT                                             ' translation table

__table         word    (@__names - @__table)/2

                word    res_x
                word    res_y
                
__names         byte    "res_x", 0
                byte    "res_y", 0

CON
  zero    = $1F0                                ' par (dst only)
  vpin    = $0FC                                ' pin group mask
  vgrp    = 2                                   ' pin group
  sgrp    = 2                                   ' pin group sync
  hv_idle = $01010101 * %00 {%hv}               ' h/v sync inactive

  res_x   = 400                                 ' |
  res_y   = 300                                 ' UI support

DAT