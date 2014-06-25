''
'' multi buffer view (VGA)
''
''        Author: Marko Lukat
'' Last modified: 2014/06/20
''       Version: 0.8
''
'' 20140605: initial version
'' 20140609: documented init method
''
CON
  lcd_x = 128
  lcd_y = 64

  res_x = driver#res_x
  res_y = driver#res_y

  quads = res_x / 4

OBJ
  driver: "waitvid.400x300.driver.2048"
  
VAR
  long  insn                                    ' scan[-2]
  long  line                                    ' scan[-1]
  long  scan[quads]

PUB null
'' This is not a top level object.

PUB init(primary) | n
'' Initializes the viewer object and any underlying graphics driver.
''
'' parameters
''  primary: optional screen buffer (to be attached at index 0) or
''           NULL (internal screen buffer if available)
''
'' result
''   Aborts when any part of the initialization fails, otherwise an address
''   of an internal buffer which can be used as a screen buffer (DAT reuse)
''   or NULL of no such buffer is available.
        
  n := driver.init(-1, @scan{0})

  ifnot cognew(@entry, @scan{0}) +1
    cogstop(--n)
    abort

  setn(primary, 0)                                      ' make sure cog is running
                                                        ' before making DAT public

PUB setn(address, sidx)
'' Add or remove a screen buffer from display.
''
'' parameters
''  address: ... of 128x64 px buffer or NULL (remove)
''     sidx: screen index (0..3)

  sidx.word[1] := address
  insn := sidx|%100

  repeat
  while insn

PUB waitVBL
'' Block execution until vertical sync pulse starts.

  repeat
  until line == res_y                           ' last line has been fetched
  repeat
  until line <> res_y                           ' vertical blank starts (res_y/0 transition)
  
DAT             org     0                       ' multi screen driver

entry           jmp     #setup

                long               $000000AA, $000000C0, $00000055, $0000AA00, $0000AAAA, $0000AAC0, $0000AA55
                long    $0000C000, $0000C0AA, $0000C0C0, $0000C055, $00005500, $000055AA, $000055C0, $00005555
                long    $00AA0000, $00AA00AA, $00AA00C0, $00AA0055, $00AAAA00, $00AAAAAA, $00AAAAC0, $00AAAA55
                long    $00AAC000, $00AAC0AA, $00AAC0C0, $00AAC055, $00AA5500, $00AA55AA, $00AA55C0, $00AA5555
                long    $00C00000, $00C000AA, $00C000C0, $00C00055, $00C0AA00, $00C0AAAA, $00C0AAC0, $00C0AA55
                long    $00C0C000, $00C0C0AA, $00C0C0C0, $00C0C055, $00C05500, $00C055AA, $00C055C0, $00C05555
                long    $00550000, $005500AA, $005500C0, $00550055, $0055AA00, $0055AAAA, $0055AAC0, $0055AA55
                long    $0055C000, $0055C0AA, $0055C0C0, $0055C055, $00555500, $005555AA, $005555C0, $00555555
                long    $AA000000, $AA0000AA, $AA0000C0, $AA000055, $AA00AA00, $AA00AAAA, $AA00AAC0, $AA00AA55
                long    $AA00C000, $AA00C0AA, $AA00C0C0, $AA00C055, $AA005500, $AA0055AA, $AA0055C0, $AA005555
                long    $AAAA0000, $AAAA00AA, $AAAA00C0, $AAAA0055, $AAAAAA00, $AAAAAAAA, $AAAAAAC0, $AAAAAA55
                long    $AAAAC000, $AAAAC0AA, $AAAAC0C0, $AAAAC055, $AAAA5500, $AAAA55AA, $AAAA55C0, $AAAA5555
                long    $AAC00000, $AAC000AA, $AAC000C0, $AAC00055, $AAC0AA00, $AAC0AAAA, $AAC0AAC0, $AAC0AA55
                long    $AAC0C000, $AAC0C0AA, $AAC0C0C0, $AAC0C055, $AAC05500, $AAC055AA, $AAC055C0, $AAC05555
                long    $AA550000, $AA5500AA, $AA5500C0, $AA550055, $AA55AA00, $AA55AAAA, $AA55AAC0, $AA55AA55
                long    $AA55C000, $AA55C0AA, $AA55C0C0, $AA55C055, $AA555500, $AA5555AA, $AA5555C0, $AA555555
                long    $C0000000, $C00000AA, $C00000C0, $C0000055, $C000AA00, $C000AAAA, $C000AAC0, $C000AA55
                long    $C000C000, $C000C0AA, $C000C0C0, $C000C055, $C0005500, $C00055AA, $C00055C0, $C0005555
                long    $C0AA0000, $C0AA00AA, $C0AA00C0, $C0AA0055, $C0AAAA00, $C0AAAAAA, $C0AAAAC0, $C0AAAA55
                long    $C0AAC000, $C0AAC0AA, $C0AAC0C0, $C0AAC055, $C0AA5500, $C0AA55AA, $C0AA55C0, $C0AA5555
                long    $C0C00000, $C0C000AA, $C0C000C0, $C0C00055, $C0C0AA00, $C0C0AAAA, $C0C0AAC0, $C0C0AA55
                long    $C0C0C000, $C0C0C0AA, $C0C0C0C0, $C0C0C055, $C0C05500, $C0C055AA, $C0C055C0, $C0C05555
                long    $C0550000, $C05500AA, $C05500C0, $C0550055, $C055AA00, $C055AAAA, $C055AAC0, $C055AA55
                long    $C055C000, $C055C0AA, $C055C0C0, $C055C055, $C0555500, $C05555AA, $C05555C0, $C0555555
                long    $55000000, $550000AA, $550000C0, $55000055, $5500AA00, $5500AAAA, $5500AAC0, $5500AA55
                long    $5500C000, $5500C0AA, $5500C0C0, $5500C055, $55005500, $550055AA, $550055C0, $55005555
                long    $55AA0000, $55AA00AA, $55AA00C0, $55AA0055, $55AAAA00, $55AAAAAA, $55AAAAC0, $55AAAA55
                long    $55AAC000, $55AAC0AA, $55AAC0C0, $55AAC055, $55AA5500, $55AA55AA, $55AA55C0, $55AA5555
                long    $55C00000, $55C000AA, $55C000C0, $55C00055, $55C0AA00, $55C0AAAA, $55C0AAC0, $55C0AA55
                long    $55C0C000, $55C0C0AA, $55C0C0C0, $55C0C055, $55C05500, $55C055AA, $55C055C0, $55C05555
                long    $55550000, $555500AA, $555500C0, $55550055, $5555AA00, $5555AAAA, $5555AAC0, $5555AA55
                long    $5555C000, $5555C0AA, $5555C0C0, $5555C055, $55555500, $555555AA, $555555C0, $55555555
                
loop            rdlong  lcnt, blnk
                cmp     lcnt, vres wz
        if_ne   jmp     #$-2                    ' wait for vblank

                call    #update                 ' re/set screen

                mov     tgtL, #tl_y + lcd_y*0   ' first ...         
                mov     tgtH, #tl_y + lcd_y*1   ' last scanline     
                                                                    
                mov     idxL, eins              ' |                 
                mov     idxR, zwei              ' select buffers ...
                                                
                call    #display                ' ... and display them

                mov     tgtL, #tl_y + lcd_y*2   ' first ...           
                mov     tgtH, #tl_y + lcd_y*3   ' last scanline       
                                                                      
                mov     idxL, drei              ' |                   
                mov     idxR, vier              ' select buffers ...  
                                                                      
                call    #display                ' ... and display them

                jmp     #loop


display         call    #wait                   ' wait for first line

                mov     scrn, par
                add     scrn, #tl_x

                mov     bcnt, #lcd_x/4
                cmp     idxL, #0 wz             ' |
        if_z    movd    scrL, #colN             ' screen is off, show idle screen
        
                rdbyte  temp, idxL              '  +0 =
        if_nz   movd    $+2, temp               '  +8
        if_nz   add     idxL, #1                '  +4
                
scrL            wrlong  colN, scrn              '  +0 =
                add     scrn, #4                '  +8
                djnz    bcnt, #$-5              '  -4   insert line from left screen

                add     scrn, #lcd_y
                
                mov     bcnt, #lcd_x/4
                cmp     idxR, #0 wz             ' |
        if_z    movd    scrR, #colN             ' screen is off, show idle screen

                rdbyte  temp, idxR              '  +0 =
        if_nz   movd    $+2, temp               '  +8
        if_nz   add     idxR, #1                '  +4
                
scrR            wrlong  colN, scrn              '  +0 =
                add     scrn, #4                '  +8
                djnz    bcnt, #$-5              '  -4   insert line from right screen

                add     tgtL, #1
                cmp     tgtL, tgtH wz
        if_ne   jmp     #display                ' for all required scanlines

                call    #wait                   ' wait for last line to be fetched
                call    #block                  ' clear buffer to avoid ghost images

display_ret     ret


block           mov     scrn, par               ' reset scanline buffer to black
                add     scrn, #tl_x
                mov     bcnt, #lcd_x/4

                wrlong  zero, scrn
                add     scrn, #4
                djnz    bcnt, #$-2              ' for left screen

                add     scrn, #lcd_y
                mov     bcnt, #lcd_x/4

                wrlong  zero, scrn
                add     scrn, #4
                djnz    bcnt, #$-2              ' for right screen

block_ret       ret


wait            rdlong  lcnt, blnk              ' wait for scan line to be fetched
                cmp     lcnt, tgtL wz           ' (so it's safe to overwrite)     
        if_ne   jmp     #$-2

wait_ret        ret


update          rdlong  temp, cmnd wz
        if_z    jmp     update_ret
        
                andn    temp, #%1_11111100      ' extract screen ID ...
                wrlong  zero, cmnd              ' acknowledge
                add     temp, #eins             ' ... plus table base

                movd    $+2, temp
                shr     temp, #16               ' address only
                mov     0-0, temp

update_ret      ret

' initialised data and/or presets

vres            long    res_y

cmnd            long    -8                      ' @insn
blnk            long    -4                      ' @line

eins            long    0
zwei            long    0
drei            long    0
vier            long    0

colN            long    $54545454

' Stuff below is re-purposed for temporary storage.

setup           mov     $000, c000              ' replace first table entry

                add     cmnd, par
                add     blnk, par

                jmp     #loop

c000            long    $00000000               ' palette entry 0

                fit

' uninitialised data and/or temporaries

                org     setup

temp            res     1
scrn            res     1

lcnt            res     1
bcnt            res     1

idxL            res     1
idxR            res     1

tgtL            res     1
tgtH            res     1

tail            fit
                
CON
  zero = $1F0                                   ' par (dst only)

  tl_x = res_x/2 - lcd_y/2 - lcd_x
  tl_y = res_y/2 - lcd_y/2 - lcd_y

DAT