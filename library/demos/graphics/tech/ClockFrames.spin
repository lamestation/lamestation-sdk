''
'' frame handler for clock demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/29
''       Version: 0.3
''
VAR
  word  eins[3 + 512], zwei[3 + 512]                    ' even/odd frames

PUB null
'' This is not a top level object.

PUB init(mailbox) : n

  repeat n from 0 to 58
    ctbl[n] := @@ctbl[n]                                ' fixup frame table

  wordfill(@eins[1], 64, 2)                             ' |
  wordfill(@zwei[1], 64, 2)                             ' minimal header

  long[mailbox][4] := @eins{0}                          ' |
  long[mailbox][5] := @zwei{0}                          ' override even/odd

  long[mailbox][6] := @ctbl                             ' complete mailbox

  ifnot cognew(@entry, mailbox) +1                      ' start frame handler
    abort

DAT                     org     0                       ' frame handler

entry                   jmpret  $, #setup

:loop                   rdbyte  time, base              ' get seconds
                        cmp     tref, time wz
                if_e    jmp     #$-2

                        mov     madr, time
                        shl     madr, #1                ' word offset
                        add     madr, ftbl              ' apply base address
                        rdword  madr, madr wz           ' source address

                        mov     tref, time
                if_z    jmp     #:loop                  ' frame 0 always exists

                        test    time, #1 wc
                        mov     dest, frmE
                if_nc   mov     dest, frmO              ' select target frame

                        mov     bcnt, #4                '                       void GDClass::uncompress(unsigned int addr, prog_uchar *src)
                        call    #get0                   '                       {
                        mov     b_off, rval             ' b_off := getn(4)        GDFB.begin(src);
                                                        '                         byte b_off = GDFB.getn(4);
                        mov     bcnt, #4                '                         byte b_len = GDFB.getn(4);
                        call    #getn                   '                         byte minlen = GDFB.getn(2);
                        mov     b_len, rval             ' b_len := getn(4)        unsigned short items = GDFB.getn(16);
                                                        '                         while (items--) {
                        mov     bcnt, #2                '                           if (GDFB.get1() == 0) {
                        call    #getn                   '                             GD.wr(addr++, GDFB.getn(8));
                        mov     m_len, rval             ' m_len := getn(2)          } else {
                                                        '                             int offset = -GDFB.getn(b_off) - 1;
                        mov     bcnt, #16               '                             int l = GDFB.getn(b_len) + minlen;
                        call    #getn                   '                             while (l--) {
                        mov     items, rval             ' items := getn(16)             GD.wr(addr, GD.rd(addr + offset));
                                                        '                               addr++;
:uncompress             rol     mmsk, #1 wc             ' |                           }
                if_c    rdbyte  mval, madr              ' |                         }
                        addx    madr, #0                ' get1                    }
                        test    mval, mmsk wc           ' |                     }

                if_c    jmp     #:offset

                        mov     bcnt, #8
                        call    #getn

                        add     rval, #btow             ' apply table offset
                        movd    $+2, rval
                        add     dest, #2                ' pre-increment (delay slot)
                        wrword  0-0, dest
                        jmp     #:next

:offset                 neg     offset, #1
                        mov     bcnt, b_off
                        call    #getn
                        sub     offset, rval            ' offset := -getn(b_off) -1

                        mov     length, m_len
                        mov     bcnt, b_len
                        call    #getn
                        add     length, rval            ' length := getn(b_len) + minlen

                        mov     temp, dest
                        add     temp, offset
                        add     temp, offset            ' word access

                        add     temp, #2                ' pre-increment
                        rdword  rval, temp
                        add     dest, #2                ' pre-increment
                        wrword  rval, dest
                        djnz    length, #$-4

:next                   djnz    items, #:uncompress

                        jmp     #:loop                  ' repeatedly

get0                    mov     mmsk, mask              ' mask initializer (1st call)
getn                    mov     rval, #0

:get                    rol     mmsk, #1 wc             ' |
                if_c    rdbyte  mval, madr              ' |
                        addx    madr, #0                ' get1
                        test    mval, mmsk wc           ' |

                        rcl     rval, #1
                        djnz    bcnt, #:get
getn_ret
get0_ret                ret

fill                    mov     bcnt, #256
                        mov     rval, #0

:loop                   or      rval, pmsk              ' increment even bits only
                        mov     btow, rval
                        add     $-1, dst1

                        add     rval, #1
                        djnz    bcnt, #:loop
fill_ret                ret

' initialised data and/or presets

base                    long    3                       ' @time.byte[3]

frmE{ven}               long    16                      '  time[4]
frmO{dd}                long    20                      '  time[5]
ftbl                    long    24                      '  time[6]

pmsk                    long    $AAAAAAAA
mask                    long    $80808080
dst1                    long    |< 9                    ' dst +/-= 1

tref                    long    -1

' Stuff below is re-purposed for temporary storage.

setup                   add     base, par               ' @byte[par][3]

                        add     frmE, par               ' @long[par][4]
                        rdlong  frmE, frmE
                        add     frmE, #6-2              ' skip header, pre-increment

                        add     frmO, par               ' @long[par][5]
                        rdlong  frmO, frmO
                        add     frmO, #6-2              ' skip header, pre-increment

                        add     ftbl, par               ' @long[par][6]
                        rdlong  ftbl, ftbl

' This is the first (and last) time we call fill() so its ret insn is a jmp #0. We can't
' come back here (res overlay) so we simply jump.

                        jmp     #fill                   ' initialise translation table

                        fit

' uninitialised data and/or temporaries

                        org     setup

bcnt                    res     1
rval                    res     1

dest                    res     1
madr                    res     1
mmsk                    res     1
mval                    res     1

time                    res     1
temp                    res     1

b_off                   res     1                       ' decompressor related
b_len                   res     1
m_len                   res     1
items                   res     1
offset                  res     1
length                  res     1

btow                    res     256

tail                    fit

DAT                                                     ' frame table

ctbl    word    @c_01, @c_02, @c_03, @c_04, @c_05, @c_06, @c_07, @c_08, @c_09, @c_10
        word    @c_11, @c_12, @c_13, @c_14, @c_15, @c_16, @c_17, @c_18, @c_19, @c_20
        word    @c_21, @c_22, @c_23, @c_24, @c_25, @c_26, @c_27, @c_28, @c_29, @c_30
        word    @c_31, @c_32, @c_33, @c_34, @c_35, @c_36, @c_37, @c_38, @c_39, @c_40
        word    @c_41, @c_42, @c_43, @c_44, @c_45, @c_46, @c_47, @c_48, @c_49, @c_50
        word    @c_51, @c_52, @c_53, @c_54, @c_55, @c_56, @c_57, @c_58, @c_59, 0

DAT                                                     ' frames 1..59 (compressed, two colours)
{
c_00    byte    $ca,  $01,  $f4,  $00,  $08,  $e0,  $df,  $7f,  $c2,  $08,  $0e,  $72,  $00,  $2f,  $e4,  $07
        byte    $7f,  $88,  $5c,  $2b,  $0f,  $09,  $80,  $df,  $c0,  $07,  $c0,  $8f,  $0f,  $1d,  $c4,  $f4
        byte    $50,  $53,  $00,  $f8,  $1e,  $3c,  $0c,  $f8,  $3f,  $01,  $2f,  $07,  $be,  $5c,  $7c,  $72
        byte    $c0,  $cf,  $e5,  $23,  $07,  $78,  $03,  $00,  $60,  $00,  $70,  $00,  $40,  $00,  $f0,  $5c
        byte    $06,  $00,  $1a,  $00,  $9c,  $1b,  $b0,  $83,  $12,  $3b,  $57,  $9c,  $e8,  $05,  $00,  $38
        byte    $07,  $00,  $b9,  $c1,  $f1,  $c8,  $03,  $0f,  $47,  $1e,  $38,  $78,  $f2,  $e0,  $81,  $93
        byte    $07,  $47,  $3e,  $70,  $7d,  $38,  $e4,  $ef,  $0b,  $3c,  $8f,  $83,  $fc,  $fd,  $0d,  $00
        byte    $80,  $01,  $00,  $c0,  $fe,  $bf,  $06,  $00,  $ff,  $31,  $e0,  $3f,  $00,  $00,  $1f,  $09
        byte    $f3,  $f7,  $f7,  $bf,  $ff,  $ff,  $8d,  $50,  $fb,  $f7,  $af,  $f4,  $17,  $63,  $17,  $ff
        byte    $fc,  $7d,  $fd,  $e4,  $c1,  $9f,  $bf,  $af,  $8f,  $3c,  $f0,  $f3,  $79,  $e8,  $03,  $de
        byte    $41,  $4e,  $00,  $01,  $f3,  $19,  $e8,  $2b,  $20,  $2f,  $80,  $1c,  $a1,  $00,  $e6,  $05
        byte    $00,  $c0,  $5f,  $27,  $fe,  $39,  $7c,  $e4,  $82,  $9f,  $c3,  $43,  $2e,  $f0,  $39,  $1c
        byte    $e4,  $02,  $9e,  $43,  $40,  $2e,  $80,  $39,  $00,  $e4,  $ca,  $08,  $c0,  $4f,  $01,  $fc
        byte    $b9,  $1c,  $e4,  $f8,  $78,  $38,  $21
}

c_01    byte    $42,  $02,  $c2,  $00,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $e0,  $7b
        byte    $c0,  $df,  $7f,  $14,  $53,  $05,  $01,  $8f,  $ae,  $0f,  $80,  $59,  $07,  $c0,  $f3,  $59
        byte    $0f,  $1b,  $40,  $05,  $01,  $e0,  $bb,  $3c,  $12,  $fe,  $ab,  $f0,  $ba,  $78,  $ba,  $83
        byte    $44,  $31,  $b1,  $34,  $de,  $e5,  $f0,  $05,  $9f,  $00,  $cc,  $20,  $e1,  $21,  $22,  $00
        byte    $78,  $df,  $01,  $40,  $03,  $97,  $7e,  $75,  $da,  $17,  $00,  $bc,  $d3,  $c8,  $00,  $e6
        byte    $90,  $09,  $74,  $b2,  $fd,  $0e,  $38,  $1e,  $ff,  $2f,  $3c,  $1c,  $fd,  $2e,  $9c,  $3e
        byte    $87,  $6e,  $63,  $f0,  $05,  $d8,  $ef,  $63,  $f8,  $81,  $fb,  $f5,  $38,  $f4,  $fb,  $5d
        byte    $03,  $00,  $7b,  $0c,  $80,  $01,  $e8,  $e2,  $c8,  $04,  $1c,  $00,  $ef,  $f7,  $fb,  $fd
        byte    $7e,  $cf,  $3f,  $70,  $03,  $00,  $71,  $74,  $0b,  $9d,  $80,  $f9,  $0a,  $8c,  $fe,  $b0
        byte    $ff,  $1b,  $74,  $7c,  $fc,  $7f,  $7e,  $32,  $00,  $ff,  $97,  $ee,  $c0,  $f8,  $33,  $d2
        byte    $6f,  $f5,  $db,  $fd,  $7e,  $bf,  $df,  $ef,  $f3,  $07,  $e0,  $a7,  $e5,  $2f,  $d3,  $2f
        byte    $f6,  $7f,  $87,  $7e,  $f6,  $bb,  $5d,  $00,  $e8,  $e1,  $ef,  $f7,  $fb,  $7d,  $1f,  $fe
        byte    $f9,  $03,  $e8,  $c1,  $ef,  $f7,  $3d,  $7c,  $f0,  $ff,  $c1,  $3b,  $e8,  $65,  $0b,  $c0
        byte    $fb,  $00,  $04,  $74,  $0d,  $fc,  $3a,  $41,  $c0,  $cb,  $f1,  $ac,  $11,  $e4,  $df,  $4a
        byte    $f8,  $1b,  $25,  $00,  $4e,  $fd,  $f4,  $f9,  $77,  $7d,  $f4,  $f1,  $77,  $3d,  $f4,  $c1
        byte    $77,  $1d,  $f4,  $81,  $77,  $05,  $f4,  $01,  $76,  $23,  $fd,  $56,  $c2,  $cf,  $10,  $7f

        byte    $df,  $41,  $17,  $78,  $3f,  $d3,  $6d,  $01

c_02    byte    $42,  $02,  $92,  $03,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $f0,  $47
        byte    $fb,  $8f,  $62,  $aa,  $20,  $00,  $7e,  $d7,  $07,  $c0,  $ac,  $03,  $e0,  $f9,  $ac,  $87
        byte    $0d,  $8f,  $82,  $00,  $f0,  $dd,  $aa,  $8f,  $2a,  $bc,  $2e,  $be,  $84,  $1f,  $ff,  $09
        byte    $3e,  $dd,  $25,  $1c,  $7f,  $80,  $7d,  $74,  $81,  $27,  $3a,  $0e,  $3a,  $1e,  $0a,  $02
        byte    $ba,  $60,  $32,  $1d,  $03,  $00,  $23,  $99,  $45,  $b7,  $e6,  $20,  $d3,  $01,  $f7,  $c9
        byte    $44,  $80,  $77,  $1a,  $5d,  $03,  $5b,  $f0,  $1c,  $fa,  $5d,  $70,  $3c,  $ba,  $c0,  $7e
        byte    $f0,  $70,  $74,  $81,  $77,  $b2,  $70,  $f0,  $f4,  $b3,  $8d,  $41,  $cf,  $41,  $16,  $47
        byte    $0f,  $70,  $1f,  $dc,  $b6,  $cf,  $a1,  $2b,  $a0,  $c3,  $60,  $db,  $ef,  $77,  $80,  $6f
        byte    $be,  $85,  $af,  $03,  $ff,  $5d,  $80,  $fd,  $0e,  $f8,  $4f,  $07,  $c3,  $7f,  $60,  $b0
        byte    $ef,  $a0,  $11,  $ec,  $e0,  $f8,  $f7,  $bb,  $06,  $7e,  $95,  $5f,  $bf,  $03,  $e3,  $ef
        byte    $3f,  $50,  $f1,  $03,  $30,  $f1,  $ef,  $c2,  $ef,  $ff,  $12,  $80,  $7f,  $fc,  $bf,  $9d
        byte    $8c,  $83,  $44,  $b6,  $57,  $70,  $de,  $f7,  $57,  $8c,  $f1,  $ff,  $f4,  $ff,  $fd,  $2c
        byte    $fe,  $3f,  $ff,  $fe,  $af,  $ff,  $f1,  $1f,  $ec,  $f8,  $c9,  $e0,  $ef,  $17,  $ba,  $f0
        byte    $fb,  $fd,  $7e,  $c7,  $87,  $ff,  $7f,  $b1,  $27,  $a0,  $12,  $3c,  $78,  $58,  $f6,  $c1
        byte    $3b,  $e8,  $24,  $00,  $f8,  $fb,  $02,  $ef,  $1b,  $e8,  $e5,  $00,  $02,  $f0,  $31,  $00
        byte    $2c,  $60,  $0b,  $bf,  $53,  $dc,  $76,  $8f,  $03,  $0f,  $fd,  $0e,  $ff,  $4e,  $c8,  $5f

        byte    $23,  $08,  $bc,  $e7,  $a3,  $97,  $e8,  $79,  $e8,  $83,  $1f,  $3a,  $e8,  $03,  $ef,  $0a
        byte    $e8,  $03,  $ee,  $46,  $fa,  $ad,  $84,  $9f,  $21,  $fe,  $be,  $83,  $2e,  $f0,  $7e,  $a6
        byte    $db,  $02

c_03    byte    $42,  $02,  $72,  $01,  $08,  $fa,  $e7,  $5f,  $4a,  $3a,  $e8,  $04,  $80,  $8f,  $fd,  $c0
        byte    $f7,  $11,  $e9,  $5f,  $8a,  $a9,  $82,  $80,  $93,  $0f,  $80,  $5b,  $07,  $c0,  $f3,  $59
        byte    $0f,  $9b,  $09,  $60,  $01,  $e0,  $bb,  $3c,  $12,  $1d,  $f8,  $09,  $7c,  $5d,  $3c,  $5d
        byte    $ff,  $09,  $3e,  $5d,  $78,  $09,  $0e,  $3e,  $80,  $27,  $0a,  $02,  $c0,  $77,  $0d,  $64
        byte    $3c,  $74,  $37,  $09,  $0c,  $11,  $70,  $0e,  $00,  $6e,  $00,  $57,  $70,  $74,  $ab,  $d3
        byte    $1e,  $30,  $01,  $c0,  $3b,  $8d,  $00,  $8c,  $48,  $25,  $ca,  $a1,  $0b,  $a7,  $07,  $8e
        byte    $47,  $1f,  $70,  $01,  $1e,  $8e,  $2e,  $18,  $01,  $5d,  $38,  $3d,  $70,  $bd,  $c6,  $e0
        byte    $db,  $05,  $58,  $e8,  $77,  $0c,  $f4,  $0a,  $5f,  $60,  $3d,  $0e,  $fc,  $ba,  $c0,  $3b
        byte    $d9,  $8e,  $3f,  $c0,  $85,  $3e,  $03,  $ff,  $f0,  $3b,  $13,  $07,  $df,  $44,  $27,  $20
        byte    $a0,  $df,  $13,  $de,  $61,  $f0,  $ff,  $04,  $00,  $72,  $e8,  $f7,  $fb,  $3d,  $0c,  $5d
        byte    $03,  $cd,  $48,  $05,  $47,  $7f,  $d8,  $ff,  $77,  $f0,  $fc,  $3f,  $fc,  $2b,  $7e,  $00
        byte    $26,  $7e,  $3d,  $f0,  $fd,  $5e,  $f2,  $87,  $ff,  $e0,  $cf,  $3f,  $60,  $07,  $89,  $40
        byte    $1f,  $7e,  $ff,  $77,  $e8,  $6d,  $3a,  $95,  $a0,  $73,  $7f,  $99,  $7e,  $81,  $7f,  $ff
        byte    $d7,  $03,  $2f,  $a0,  $ef,  $a7,  $d0,  $2f,  $e0,  $ef,  $ff,  $7a,  $c0,  $0d,  $f4,  $7d
        byte    $14,  $fa,  $05,  $f8,  $fd,  $5f,  $c7,  $43,  $01,  $b0,  $83,  $1e,  $f8,  $22,  $70,  $01
        byte    $fd,  $2e,  $7e,  $00,  $7e,  $86,  $07,  $03,  $59,  $80,  $39,  $c0,  $02,  $ba,  $e0,  $01

        byte    $f8,  $2b,  $6c,  $32,  $5d,  $fe,  $19,  $0f,  $bd,  $6d,  $01,  $b8,  $80,  $c4,  $22,  $e0
        byte    $27,  $13,  $c0,  $5f,  $e0,  $d3,  $1f,  $02,  $c4,  $d0,  $f5,  $d0,  $8c,  $80,  $6f,  $46
        byte    $1c,  $f4,  $f8,  $f7,  $04,  $f4,  $12,  $00,  $47,  $fd,  $56,  $c2,  $c7,  $10,  $7f,  $df
        byte    $41,  $17,  $78,  $3f,  $d3,  $6d,  $01

c_04    byte    $8c,  $02,  $7a,  $03,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $3e
        byte    $f0,  $ff,  $ec,  $bf,  $d6,  $6e,  $00,  $7e,  $f7,  $01,  $b0,  $3b,  $00,  $de,  $7b,  $f7
        byte    $00,  $b0,  $01,  $17,  $00,  $fe,  $f3,  $a8,  $f8,  $0b,  $bc,  $89,  $af,  $08,  $f0,  $5f
        byte    $f0,  $7c,  $78,  $df,  $23,  $60,  $1f,  $1f,  $78,  $31,  $60,  $10,  $bc,  $87,  $21,  $e0
        byte    $3f,  $80,  $f8,  $6a,  $02,  $0c,  $c0,  $41,  $c2,  $b1,  $07,  $c0,  $ff,  $05,  $00,  $7f
        byte    $23,  $70,  $48,  $30,  $12,  $f8,  $f9,  $13,  $9c,  $04,  $8e,  $47,  $09,  $18,  $7e,  $82
        byte    $87,  $e3,  $57,  $70,  $03,  $0e,  $9e,  $0f,  $a3,  $fc,  $c3,  $e7,  $c3,  $29,  $c0,  $13
        byte    $0e,  $3f,  $00,  $db,  $ff,  $cf,  $1f,  $f8,  $07,  $2e,  $01,  $4e,  $1c,  $1e,  $fe,  $2f
        byte    $e0,  $7f,  $ff,  $0f,  $f8,  $03,  $d8,  $de,  $09,  $80,  $9f,  $81,  $ef,  $e0,  $c3,  $07
        byte    $fc,  $01,  $7c,  $ff,  $e1,  $8d,  $f3,  $6f,  $02,  $f8,  $ff,  $ff,  $1c,  $ce,  $ff,  $ff
        byte    $3f,  $03,  $3f,  $0d,  $0c,  $e9,  $ff,  $8f,  $e3,  $1b,  $f8,  $fc,  $17,  $8c,  $ff,  $fd
        byte    $7f,  $3c,  $ff,  $3f,  $fc,  $cb,  $0f,  $c0,  $f2,  $ff,  $f0,  $07,  $bc,  $38,  $38,  $ff
        byte    $c3,  $ff,  $7f,  $36,  $fe,  $ff,  $ff,  $0e,  $d8,  $41,  $07,  $2f,  $a0,  $b7,  $e7,  $6f
        byte    $fc,  $8f,  $9f,  $c3,  $07,  $2e,  $e0,  $a7,  $5f,  $9e,  $81,  $9f,  $b8,  $fb,  $29,  $80
        byte    $7f,  $0b,  $f8,  $ff,  $73,  $70,  $ff,  $ff,  $ff,  $fb,  $28,  $00,  $3d,  $fc,  $04,  $ff
        byte    $ff,  $ff,  $3d,  $14,  $c0,  $b5,  $05,  $f0,  $13,  $be,  $81,  $fb,  $1d,  $14,  $fe,  $00

        byte    $7e,  $02,  $6e,  $60,  $02,  $f4,  $d3,  $01,  $0b,  $e8,  $c0,  $1d,  $74,  $80,  $00,  $3a
        byte    $7e,  $01,  $fd,  $fc,  $d9,  $fc,  $b5,  $ef,  $e7,  $03,  $f6,  $c1,  $ff,  $b7,  $0f,  $de
        byte    $00,  $fc,  $ef,  $e1,  $f3,  $5f,  $e0,  $bf,  $83,  $9f,  $00,  $02,  $f9,  $02,  $7e,  $02
        byte    $7e,  $f3,  $4f,  $f8,  $7f,  $f6,  $73,  $fe,  $cf,  $0e,  $3e,  $f0,  $9f,  $d3,  $9f,  $09

c_05    byte    $8c,  $02,  $fa,  $03,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $3e
        byte    $d2,  $cf,  $fe,  $6b,  $ed,  $02,  $e0,  $77,  $1f,  $00,  $bb,  $03,  $e0,  $bd,  $77,  $0f
        byte    $00,  $1b,  $0c,  $01,  $e0,  $3f,  $8f,  $ca,  $a7,  $e0,  $9b,  $78,  $aa,  $1f,  $80,  $7c
        byte    $26,  $fc,  $ea,  $0e,  $30,  $8f,  $21,  $00,  $fc,  $17,  $de,  $1c,  $7c,  $c0,  $1f,  $38
        byte    $be,  $07,  $d0,  $c0,  $17,  $50,  $7c,  $6c,  $07,  $00,  $01,  $7c,  $0f,  $02,  $81,  $bf
        byte    $13,  $0c,  $00,  $9c,  $8f,  $c3,  $7f,  $85,  $41,  $02,  $e7,  $e3,  $3b,  $28,  $1c,  $12
        byte    $bc,  $07,  $70,  $27,  $1c,  $09,  $8e,  $1f,  $e0,  $ff,  $e7,  $07,  $7f,  $27,  $38,  $ff
        byte    $f1,  $ff,  $bf,  $fb,  $f3,  $bf,  $13,  $b8,  $c4,  $e1,  $03,  $06,  $b3,  $80,  $fd,  $0f
        byte    $1e,  $dc,  $02,  $fe,  $fd,  $07,  $fc,  $4b,  $00,  $e0,  $e7,  $e0,  $f3,  $ff,  $ff,  $fb
        byte    $0f,  $cb,  $00,  $40,  $00,  $ff,  $ff,  $ff,  $ff,  $1a,  $00,  $c2,  $ff,  $8f,  $c3,  $37
        byte    $70,  $d3,  $fa,  $e5,  $1f,  $fe,  $03,  $47,  $fa,  $e7,  $ff,  $6f,  $e0,  $e3,  $5f,  $70
        byte    $fe,  $f7,  $ff,  $f9,  $fd,  $ff,  $e0,  $2f,  $7f,  $00,  $cb,  $7f,  $e0,  $47,  $01,  $5c
        byte    $1c,  $b4,  $ff,  $c1,  $ff,  $0f,  $5c,  $40,  $c3,  $ff,  $ff,  $ef,  $df,  $df,  $00,  $6c
        byte    $e0,  $03,  $e4,  $f0,  $9f,  $83,  $0f,  $fc,  $0f,  $80,  $bf,  $c1,  $7f,  $7e,  $1a,  $00
        byte    $0f,  $25,  $e0,  $c7,  $f1,  $ff,  $4f,  $9f,  $ff,  $f3,  $f1,  $13,  $fe,  $f9,  $7f,  $82
        byte    $ff,  $01,  $fb,  $f9,  $df,  $43,  $01,  $ee,  $e3,  $27,  $f0,  $0e,  $0a,  $fc,  $da,  $02

        byte    $f0,  $c9,  $df,  $c0,  $fd,  $b3,  $01,  $fc,  $09,  $b0,  $80,  $d9,  $fc,  $74,  $80,  $00
        byte    $3a,  $78,  $0f,  $fd,  $04,  $7f,  $03,  $bf,  $83,  $ff,  $3f,  $7f,  $01,  $af,  $7c,  $3f
        byte    $23,  $00,  $f4,  $07,  $ff,  $7b,  $f8,  $c0,  $fd,  $80,  $ff,  $0e,  $3e,  $7c,  $0f,  $c0
        byte    $bf,  $80,  $8f,  $df,  $00,  $c0,  $9f,  $7e,  $da,  $39,  $f9,  $39,  $01,  $f0,  $cd,  $0e
        byte    $3e,  $f0,  $9f,  $d3,  $9f,  $09

c_06    byte    $8e,  $01,  $12,  $01,  $08,  $e0,  $df,  $7f,  $c8,  $20,  $0e,  $c2,  $01,  $8f,  $08,  $c0
        byte    $0f,  $7c,  $1f,  $f8,  $c3,  $03,  $48,  $9d,  $11,  $80,  $00,  $f8,  $31,  $7c,  $00,  $cc
        byte    $9b,  $d3,  $41,  $70,  $0f,  $d1,  $08,  $08,  $00,  $1f,  $8f,  $4f,  $52,  $00,  $f0,  $42
        byte    $e0,  $0b,  $e2,  $01,  $30,  $9e,  $10,  $51,  $3d,  $00,  $f7,  $11,  $ae,  $28,  $0e,  $f0
        byte    $1e,  $da,  $84,  $87,  $83,  $c7,  $00,  $40,  $03,  $80,  $93,  $80,  $e3,  $11,  $ca,  $c1
        byte    $50,  $70,  $1e,  $04,  $02,  $77,  $10,  $1f,  $78,  $1c,  $e0,  $d5,  $8a,  $00,  $16,  $00
        byte    $18,  $9c,  $8f,  $3d,  $b1,  $c2,  $c1,  $7b,  $5e,  $13,  $20,  $1c,  $3f,  $cf,  $1c,  $00
        byte    $08,  $84,  $27,  $1c,  $40,  $0e,  $00,  $02,  $e1,  $08,  $07,  $38,  $3c,  $00,  $1e,  $fe
        byte    $fc,  $83,  $c7,  $01,  $20,  $10,  $87,  $70,  $f0,  $e1,  $00,  $08,  $14,  $1e,  $3f,  $b8
        byte    $bf,  $1c,  $fc,  $07,  $08,  $17,  $c8,  $41,  $f8,  $47,  $81,  $c2,  $fb,  $5f,  $3b,  $28
        byte    $7e,  $f8,  $f0,  $11,  $00,  $6e,  $08,  $1f,  $6e,  $2d,  $00,  $03,  $e9,  $d7,  $86,  $f7
        byte    $cf,  $3f,  $7c,  $78,  $ff,  $f8,  $d7,  $86,  $f7,  $0f,  $7f,  $6d,  $f8,  $f0,  $f8,  $00
        byte    $84,  $bf,  $07,  $80,  $5f,  $b8,  $f9,  $2b,  $fc,  $87,  $6f,  $37,  $67,  $d3,  $f8,  $10
        byte    $c3,  $ce,  $af,  $0d,  $d7,  $c4,  $81,  $bf,  $1c,  $c5,  $86,  $70,  $08,  $ef,  $61,  $69
        byte    $b8,  $35,  $3e,  $b2,  $73,  $f0,  $93,  $2c,  $3c,  $60,  $1c,  $e1,  $fd,  $c4,  $03,  $1e
        byte    $ae,  $5c,  $91,  $6d,  $78,  $52,  $00,  $0c,  $8f,  $1f,  $4e,  $38,  $c0,  $e1,  $fd,  $c3

        byte    $6b,  $01,  $3e,  $ff,  $8d,  $11,  $f0,  $eb,  $fb,  $07,  $3e,  $f3,  $79,  $b8,  $1d,  $fe
        byte    $83,  $de,  $10,  $30,  $33,  $88,  $7f,  $80,  $e1,  $81,  $37,  $04,  $00,  $20,  $46,  $c3
        byte    $19,  $00,  $5a,  $c1,  $7f,  $18,  $af,  $15,  $ff,  $ee,  $e1,  $62,  $34,  $04,  $1f,  $ae
        byte    $37,  $c0,  $3e,  $e1,  $1a,  $36,  $00,  $1c,  $ae,  $21,  $78,  $1f,  $61,  $1b,  $e2,  $c7
        byte    $10,  $1e,  $40,  $01,  $fe,  $61,  $33,  $4e,  $0a,  $09

c_07    byte    $8e,  $01,  $d2,  $01,  $08,  $e0,  $df,  $7f,  $c8,  $20,  $0e,  $c2,  $01,  $8f,  $08,  $c0
        byte    $0f,  $7c,  $1f,  $f8,  $c3,  $03,  $48,  $9d,  $11,  $80,  $00,  $f8,  $31,  $7c,  $00,  $cc
        byte    $9b,  $d3,  $41,  $70,  $0f,  $d1,  $05,  $80,  $8f,  $c7,  $a3,  $38,  $60,  $78,  $21,  $f0
        byte    $04,  $11,  $00,  $9c,  $4f,  $88,  $b2,  $06,  $c0,  $a7,  $c8,  $0a,  $c0,  $01,  $7c,  $0f
        byte    $6d,  $ea,  $3a,  $c0,  $e3,  $00,  $60,  $b2,  $2c,  $1c,  $38,  $18,  $00,  $9c,  $2c,  $1c
        byte    $0e,  $07,  $95,  $1c,  $6c,  $87,  $63,  $00,  $20,  $70,  $0f,  $db,  $c1,  $c5,  $01,  $e7
        byte    $c3,  $ff,  $bc,  $2a,  $e0,  $e1,  $85,  $03,  $2c,  $00,  $30,  $00,  $70,  $70,  $fc,  $f8
        byte    $07,  $5e,  $03,  $00,  $70,  $3c,  $e1,  $c0,  $f7,  $48,  $84,  $23,  $dc,  $cc,  $7a,  $38
        byte    $fc,  $f9,  $c7,  $cf,  $61,  $03,  $00,  $0e,  $e1,  $f8,  $e3,  $08,  $15,  $de,  $bf,  $7f
        byte    $38,  $00,  $ee,  $70,  $08,  $e3,  $1f,  $3c,  $00,  $3c,  $99,  $c2,  $8f,  $81,  $17,  $3e
        byte    $c2,  $dc,  $f0,  $e1,  $e6,  $44,  $72,  $90,  $1e,  $e0,  $c6,  $f0,  $0f,  $c6,  $00,  $30
        byte    $10,  $8f,  $ff,  $d8,  $f0,  $f3,  $c6,  $86,  $f7,  $0f,  $1f,  $c0,  $82,  $f0,  $63,  $c7
        byte    $84,  $ff,  $07,  $60,  $4c,  $78,  $ff,  $7d,  $f0,  $03,  $18,  $1f,  $4e,  $40,  $a3,  $f0
        byte    $fe,  $01,  $76,  $8b,  $df,  $2f,  $3b,  $c0,  $f8,  $63,  $8b,  $3a,  $f0,  $57,  $c2,  $43
        byte    $53,  $0e,  $fe,  $c6,  $f8,  $18,  $1a,  $1e,  $80,  $9f,  $ad,  $1c,  $fc,  $a4,  $f3,  $e7
        byte    $bf,  $18,  $0e,  $3f,  $c1,  $9a,  $7c,  $09,  $e7,  $5f,  $40,  $78,  $80,  $78,  $4a,  $08

        byte    $0c,  $0f,  $18,  $4e,  $38,  $c0,  $e1,  $81,  $c3,  $eb,  $01,  $be,  $5c,  $07,  $70,  $0e
        byte    $fc,  $c3,  $6f,  $17,  $0c,  $78,  $38,  $fc,  $59,  $fc,  $eb,  $07,  $7e,  $83,  $7f,  $96
        byte    $42,  $80,  $5b,  $47,  $09,  $f7,  $28,  $58,  $47,  $ff,  $e1,  $6a,  $75,  $5c,  $00,  $20
        byte    $1c,  $f0,  $83,  $00,  $6e,  $83,  $7f,  $18,  $ae,  $56,  $47,  $f0,  $e1,  $06,  $74,  $04
        byte    $1e,  $ae,  $63,  $94,  $3a,  $11,  $3a,  $18,  $ac,  $5b,  $d1,  $3f,  $60,  $fc,  $a1,  $0a
        byte    $fa,  $07,  $9e,  $37,  $f2,  $ad,  $90

c_08    byte    $8e,  $01,  $52,  $01,  $08,  $e0,  $df,  $7f,  $c8,  $20,  $0e,  $c2,  $01,  $8f,  $08,  $c0
        byte    $0f,  $7c,  $1f,  $f8,  $c3,  $03,  $48,  $9d,  $11,  $80,  $00,  $f8,  $31,  $7c,  $00,  $cc
        byte    $9b,  $d3,  $41,  $70,  $0f,  $d1,  $05,  $80,  $8f,  $c7,  $a7,  $38,  $00,  $78,  $21,  $f0
        byte    $85,  $07,  $81,  $27,  $44,  $54,  $00,  $70,  $7c,  $84,  $eb,  $0e,  $00,  $bf,  $87,  $36
        byte    $fc,  $a3,  $08,  $e0,  $6f,  $00,  $a0,  $81,  $e1,  $06,  $3c,  $1b,  $00,  $bc,  $ab,  $9d
        byte    $03,  $87,  $02,  $81,  $87,  $03,  $0c,  $c0,  $43,  $1a,  $e0,  $1e,  $fc,  $4f,  $e3,  $21
        byte    $00,  $30,  $38,  $1f,  $fe,  $a7,  $c1,  $01,  $00,  $1c,  $5e,  $b8,  $73,  $e0,  $00,  $80
        byte    $83,  $e3,  $c7,  $ff,  $80,  $4c,  $70,  $f0,  $84,  $6f,  $b1,  $00,  $47,  $38,  $fe,  $0e
        byte    $3a,  $81,  $c3,  $e1,  $cf,  $bf,  $ff,  $15,  $e5,  $38,  $84,  $e7,  $09,  $20,  $53,  $f8
        byte    $8a,  $99,  $38,  $a4,  $f1,  $df,  $21,  $d3,  $9a,  $08,  $13,  $78,  $00,  $08,  $bf,  $11
        byte    $4f,  $f8,  $78,  $6d,  $e0,  $85,  $0f,  $07,  $00,  $40,  $a6,  $f4,  $fc,  $01,  $dc,  $e9
        byte    $14,  $67,  $df,  $9f,  $f0,  $6d,  $17,  $1a,  $68,  $0b,  $a0,  $4d,  $fc,  $b6,  $6d,  $c2
        byte    $fb,  $07,  $0c,  $a0,  $4d,  $78,  $ff,  $6d,  $36,  $f4,  $6f,  $db,  $28,  $7c,  $db,  $28
        byte    $e1,  $53,  $4c,  $cb,  $12,  $6c,  $99,  $8f,  $a2,  $0e,  $fc,  $85,  $f3,  $e3,  $ff,  $12
        byte    $07,  $7f,  $e9,  $fc,  $75,  $0d,  $57,  $6e,  $09,  $70,  $00,  $1c,  $fc,  $f0,  $17,  $b0
        byte    $15,  $00,  $8e,  $1c,  $47,  $b3,  $85,  $0f,  $9f,  $0d,  $4f,  $0b,  $83,  $e9,  $26,  $c0

        byte    $09,  $27,  $38,  $dc,  $00,  $78,  $1e,  $de,  $85,  $07,  $08,  $6e,  $61,  $bf,  $09,  $c0
        byte    $c3,  $c1,  $6f,  $e2,  $5f,  $30,  $f0,  $5a,  $f8,  $8b,  $f8,  $37,  $0e,  $78,  $14,  $ff
        byte    $22,  $fe,  $dd,  $1f,  $2a,  $95,  $25,  $d8,  $a7,  $60,  $03,  $07,  $00,  $28,  $25,  $70
        byte    $62,  $bc,  $89,  $e1,  $0e,  $00,  $98,  $f8,  $30,  $de,  $c4,  $09,  $c0,  $c3,  $75,  $98
        byte    $d8,  $a6,  $e1,  $c4,  $50,  $81,  $fc,  $4c,  $f8,  $17,  $b1,  $80,  $83,  $bc,  $11,  $fd
        byte    $3b,  $0c,  $09

c_09    byte    $81,  $01,  $a2,  $00,  $08,  $c0,  $bf,  $ff,  $20,  $03,  $71,  $10,  $1c,  $f0,  $10,  $01
        byte    $f8,  $81,  $1f,  $50,  $f0,  $00,  $a2,  $8e,  $11,  $80,  $00,  $f8,  $61,  $f8,  $00,  $18
        byte    $6f,  $9c,  $0e,  $02,  $f7,  $10,  $ba,  $00,  $f0,  $91,  $27,  $0e,  $00,  $5e,  $10,  $7e
        byte    $82,  $07,  $c0,  $a7,  $e8,  $e8,  $11,  $f0,  $08,  $1e,  $70,  $60,  $1c,  $3c,  $64,  $e3
        byte    $3f,  $75,  $1f,  $0e,  $00,  $1a,  $08,  $1e,  $80,  $3f,  $03,  $80,  $eb,  $ca,  $dc,  $bc
        byte    $40,  $e0,  $c1,  $95,  $27,  $40,  $38,  $60,  $e0,  $1e,  $fc,  $e3,  $07,  $e0,  $20,  $1c
        byte    $70,  $3e,  $82,  $4f,  $0b,  $38,  $bc,  $e0,  $f8,  $17,  $0d,  $0e,  $8e,  $9f,  $b1,  $ab
        byte    $82,  $83,  $27,  $78,  $00,  $19,  $c1,  $c1,  $11,  $bc,  $c1,  $8a,  $70,  $e0,  $f0,  $17
        byte    $9d,  $e3,  $86,  $78,  $70,  $08,  $7e,  $6a,  $3c,  $c1,  $e7,  $98,  $10,  $87,  $68,  $fc
        byte    $57,  $58,  $6d,  $08,  $e9,  $38,  $68,  $36,  $b8,  $74,  $2a,  $38,  $d3,  $7f,  $ba,  $8d
        byte    $c4,  $3f,  $1e,  $be,  $e0,  $d3,  $ad,  $70,  $9c,  $74,  $05,  $cc,  $12,  $7c,  $ba,  $09
        byte    $05,  $9f,  $6e,  $42,  $c1,  $87,  $71,  $74,  $70,  $c3,  $5c,  $0d,  $20,  $b8,  $79,  $9e
        byte    $ce,  $be,  $2e,  $03,  $81,  $04,  $9f,  $99,  $83,  $48,  $82,  $0f,  $ce,  $47,  $f0,  $e7
        byte    $02,  $f0,  $93,  $aa,  $03,  $7f,  $71,  $4c,  $f2,  $71,  $70,  $02,  $76,  $06,  $30,  $1d
        byte    $fe,  $52,  $4b,  $e1,  $10,  $c7,  $43,  $fe,  $6b,  $e1,  $b1,  $5f,  $f0,  $99,  $1d,  $3f
        byte    $69,  $70,  $78,  $9e,  $33,  $b8,  $32,  $00,  $38,  $c1,  $19,  $0e,  $2e,  $37,  $78,  $71

        byte    $09,  $0e,  $ae,  $02,  $70,  $71,  $01,  $0f,  $7e,  $a1,  $1a,  $cb,  $e3,  $bf,  $50,  $51
        byte    $f0,  $5f,  $35,  $00,  $b8,  $2a,  $f8,  $85,  $f8,  $37,  $50,  $d1,  $7e,  $99,  $f8,  $77
        byte    $18,  $3c,  $ff,  $e0,  $7d,  $77,  $14,  $57,  $8d,  $03,  $c7,  $55,  $e3,  $c2,  $61,  $d5
        byte    $78,  $d9,  $c2,  $35,  $b6,  $70,  $70,  $8d,  $e9,  $a4,  $e0,  $bf,  $c6,  $a0,  $02,  $f2
        byte    $03,  $de,  $df,  $8e,  $c1,  $79,  $a8,  $21,  $d9,  $88,  $f1,  $fb,  $09,  $12

c_10    byte    $41,  $01,  $02,  $02,  $08,  $80,  $7f,  $ff,  $41,  $0c,  $84,  $83,  $e0,  $00,  $0f,  $91
        byte    $0f,  $f8,  $3e,  $f0,  $07,  $2f,  $aa,  $31,  $12,  $00,  $3f,  $0c,  $3e,  $00,  $c6,  $33
        byte    $8e,  $0e,  $02,  $eb,  $21,  $b0,  $02,  $c0,  $87,  $c7,  $4f,  $9a,  $e0,  $05,  $c7,  $5f
        byte    $68,  $01,  $e0,  $09,  $7e,  $10,  $78,  $94,  $35,  $bd,  $00,  $3c,  $00,  $10,  $e0,  $bf
        byte    $88,  $02,  $1c,  $02,  $34,  $10,  $3c,  $07,  $06,  $01,  $d7,  $85,  $7f,  $71,  $05,  $03
        byte    $0f,  $3e,  $1f,  $c0,  $c0,  $3d,  $74,  $0d,  $3e,  $70,  $70,  $3e,  $82,  $6b,  $20,  $18
        byte    $f0,  $82,  $0b,  $d0,  $03,  $40,  $70,  $70,  $fc,  $84,  $07,  $b0,  $0f,  $00,  $70,  $82
        byte    $8f,  $2f,  $38,  $38,  $c2,  $2b,  $bc,  $21,  $38,  $70,  $f8,  $8b,  $8e,  $73,  $c0,  $00
        byte    $30,  $70,  $08,  $ae,  $ff,  $b1,  $70,  $08,  $5e,  $05,  $3d,  $70,  $88,  $86,  $ff,  $0e
        byte    $f2,  $d9,  $a3,  $ff,  $11,  $e2,  $0b,  $5e,  $32,  $e6,  $13,  $bc,  $cd,  $76,  $d3,  $7f
        byte    $f7,  $00,  $0c,  $23,  $d9,  $c1,  $db,  $6e,  $46,  $c2,  $5b,  $94,  $ee,  $84,  $2f,  $19
        byte    $dd,  $09,  $ee,  $3a,  $bb,  $13,  $dc,  $a2,  $45,  $22,  $3e,  $45,  $2b,  $a8,  $ff,  $74
        byte    $38,  $88,  $64,  $79,  $82,  $e3,  $a1,  $85,  $c1,  $09,  $83,  $9f,  $e0,  $07,  $e1,  $e6
        byte    $fe,  $e0,  $3f,  $7c,  $3c,  $f8,  $6f,  $1e,  $dc,  $8b,  $01,  $e0,  $e0,  $87,  $7f,  $f0
        byte    $f7,  $c3,  $ff,  $a5,  $ad,  $38,  $6e,  $f0,  $71,  $44,  $c5,  $e1,  $43,  $6f,  $10,  $fc
        byte    $c6,  $c0,  $8b,  $8a,  $e1,  $f0,  $d4,  $06,  $5c,  $5e,  $04,  $07,  $a7,  $36,  $c0,  $83

        byte    $23,  $3c,  $b8,  $02,  $80,  $57,  $05,  $78,  $70,  $6a,  $03,  $58,  $c0,  $35,  $82,  $eb
        byte    $00,  $60,  $70,  $e0,  $ff,  $02,  $bf,  $87,  $89,  $1c,  $c7,  $4f,  $0f,  $78,  $04,  $c7
        byte    $0f,  $fe,  $e0,  $f0,  $e7,  $13,  $1c,  $1f,  $f8,  $5b,  $88,  $ef,  $88,  $1d,  $5a,  $59
        byte    $87,  $1e,  $9b,  $81,  $0e,  $67,  $b0,  $83,  $41,  $c9,  $a0,  $c1,  $0d,  $5d,  $b2,  $03
        byte    $f1,  $8c,  $a8,  $71,  $ff,  $41,  $04

c_11    byte    $8c,  $02,  $7a,  $03,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $09
        byte    $ff,  $cf,  $fe,  $6b,  $ed,  $02,  $e0,  $77,  $1f,  $00,  $bb,  $03,  $fc,  $bd,  $01,  $ef
        byte    $1e,  $fe,  $10,  $00,  $fe,  $fb,  $f8,  $13,  $5e,  $f5,  $c3,  $bf,  $27,  $3e,  $dd,  $ff
        byte    $9f,  $3c,  $fe,  $0b,  $3d,  $39,  $48,  $02,  $fe,  $ff,  $00,  $0d,  $fc,  $76,  $c2,  $02
        byte    $ec,  $e0,  $ff,  $27,  $1c,  $b8,  $87,  $0f,  $f8,  $18,  $38,  $ff,  $7f,  $0f,  $e0,  $c1
        byte    $f9,  $f8,  $df,  $df,  $f9,  $1f,  $b8,  $00,  $f8,  $70,  $82,  $9f,  $ff,  $1c,  $a4,  $83
        byte    $e7,  $fb,  $07,  $ef,  $03,  $20,  $0c,  $1c,  $ff,  $f3,  $07,  $70,  $82,  $bf,  $13,  $ec
        byte    $83,  $7f,  $18,  $38,  $fc,  $17,  $00,  $bf,  $f3,  $6f,  $3a,  $81,  $c1,  $bb,  $09,  $ff
        byte    $77,  $10,  $7e,  $02,  $ff,  $ff,  $4f,  $00,  $bf,  $0f,  $07,  $9f,  $ff,  $4d,  $fc,  $be
        byte    $7f,  $f8,  $df,  $40,  $fb,  $0f,  $f8,  $f7,  $00,  $d8,  $c0,  $09,  $37,  $f9,  $49,  $1f
        byte    $ff,  $4f,  $fd,  $83,  $ff,  $0e,  $fa,  $07,  $fc,  $7d,  $00,  $6c,  $1f,  $f8,  $e7,  $57
        byte    $ff,  $6f,  $f0,  $bf,  $03,  $ff,  $df,  $43,  $05,  $f0,  $c1,  $37,  $3f,  $f5,  $fb,  $9f
        byte    $f5,  $fc,  $01,  $df,  $41,  $fd,  $c3,  $df,  $f3,  $f1,  $3f,  $87,  $87,  $df,  $cf,  $2b
        byte    $ff,  $ff,  $ff,  $9f,  $1f,  $fe,  $3e,  $5e,  $f9,  $38,  $fe,  $ff,  $00,  $fe,  $f0,  $e0
        byte    $ff,  $3f,  $3c,  $3e,  $d6,  $2f,  $27,  $c0,  $f9,  $ff,  $3f,  $78,  $db,  $e1,  $09,  $00
        byte    $1f,  $38,  $07,  $e3,  $ff,  $07,  $fe,  $1b,  $3e,  $01,  $b0,  $00,  $e0,  $06,  $c6,  $ff

        byte    $0b,  $b0,  $80,  $21,  $3c,  $05,  $e0,  $0f,  $20,  $80,  $ff,  $9f,  $87,  $f3,  $c7,  $2f
        byte    $3e,  $be,  $3f,  $f0,  $bf,  $f0,  $f9,  $3e,  $be,  $ff,  $02,  $ef,  $7b,  $80,  $ef,  $ef
        byte    $c9,  $07,  $ff,  $1d,  $fc,  $17,  $80,  $7f,  $03,  $f8,  $fd,  $7c,  $80,  $3f,  $fd,  $7f
        byte    $33,  $1f,  $1f,  $0f,  $ff,  $cf,  $1c,  $3e,  $f0,  $9f,  $d3,  $9f,  $09

c_12    byte    $4c,  $02,  $4a,  $01,  $08,  $fd,  $f9,  $9f,  $4a,  $07,  $47,  $00,  $7c,  $4d,  $7d,  $c0
        byte    $4f,  $f0,  $ff,  $fe,  $c7,  $6a,  $10,  $30,  $f9,  $00,  $78,  $04,  $0e,  $9e,  $b1,  $01
        byte    $fe,  $7a,  $f8,  $04,  $80,  $7f,  $fd,  $7c,  $0b,  $bc,  $1f,  $f0,  $88,  $a7,  $f4,  $e7
        byte    $ff,  $e3,  $f1,  $1e,  $bf,  $07,  $80,  $02,  $5e,  $e0,  $00,  $02,  $07,  $8f,  $81,  $ff
        byte    $59,  $00,  $3b,  $f8,  $1f,  $01,  $c0,  $3f,  $f0,  $47,  $f8,  $78,  $f0,  $1f,  $7c,  $f0
        byte    $c0,  $f9,  $f8,  $0d,  $c0,  $87,  $f7,  $0d,  $00,  $86,  $02,  $8e,  $1f,  $ff,  $c1,  $5b
        byte    $e0,  $f8,  $1f,  $07,  $c9,  $13,  $f8,  $f1,  $1f,  $e0,  $6f,  $00,  $63,  $78,  $fc,  $bd
        byte    $fa,  $f9,  $03,  $e0,  $10,  $7c,  $fe,  $c1,  $ff,  $4b,  $08,  $f0,  $61,  $c0,  $e1,  $c2
        byte    $7f,  $04,  $0e,  $18,  $7c,  $c0,  $3f,  $07,  $df,  $99,  $18,  $f8,  $e0,  $ff,  $0e,  $fd
        byte    $07,  $80,  $3f,  $1f,  $06,  $0f,  $fe,  $57,  $b1,  $18,  $48,  $c0,  $7f,  $0e,  $e0,  $bf
        byte    $80,  $3f,  $3f,  $c3,  $0f,  $40,  $00,  $ff,  $e2,  $05,  $de,  $04,  $1e,  $c0,  $ff,  $af
        byte    $3f,  $80,  $7f,  $e3,  $00,  $7f,  $d1,  $fa,  $07,  $df,  $f8,  $01,  $fe,  $3f,  $02,  $fc
        byte    $ff,  $c3,  $e3,  $e1,  $77,  $30,  $c0,  $f7,  $57,  $80,  $07,  $10,  $3c,  $cb,  $ff,  $72
        byte    $f8,  $c1,  $ff,  $f8,  $fd,  $f8,  $87,  $ff,  $2d,  $ff,  $8b,  $e3,  $87,  $ff,  $f3,  $f7
        byte    $e1,  $1f,  $ff,  $b7,  $fc,  $2f,  $9c,  $1f,  $ff,  $0b,  $cf,  $83,  $ff,  $94,  $ff,  $0b
        byte    $ce,  $c1,  $ff,  $02,  $ff,  $f9,  $3f,  $02,  $1e,  $03,  $fe,  $1d,  $26,  $c1,  $b3,  $00

        byte    $16,  $f0,  $3f,  $0e,  $00,  $fe,  $fe,  $1f,  $0f,  $49,  $30,  $18,  $4e,  $02,  $80,  $1c
        byte    $5e,  $3f,  $3f,  $9f,  $d7,  $c7,  $8f,  $ef,  $f5,  $20,  $dc,  $7f,  $20,  $18,  $fc,  $eb
        byte    $e0,  $73,  $0c,  $fc,  $15,  $f0,  $f9,  $06,  $f8,  $26,  $e0,  $fd,  $87,  $57,  $01,  $e6
        byte    $c4,  $ff,  $37,  $2f,  $f0,  $ff,  $bb,  $00

c_13    byte    $42,  $02,  $32,  $02,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $f0,  $47
        byte    $fb,  $8f,  $6b,  $a2,  $27,  $a0,  $e7,  $03,  $e0,  $d0,  $41,  $07,  $7c,  $21,  $03,  $bc
        byte    $eb,  $a1,  $27,  $60,  $39,  $f0,  $d1,  $2b,  $c0,  $fb,  $fa,  $e9,  $f3,  $e9,  $36,  $02
        byte    $f0,  $8b,  $3c,  $fa,  $3d,  $07,  $1d,  $01,  $ff,  $4a,  $07,  $a0,  $81,  $7e,  $a7,  $02
        byte    $78,  $d2,  $ef,  $08,  $00,  $de,  $c3,  $df,  $08,  $76,  $3c,  $7c,  $fb,  $e0,  $7c,  $f4
        byte    $bf,  $fd,  $1f,  $1e,  $38,  $7e,  $fe,  $06,  $16,  $83,  $1e,  $7f,  $00,  $fe,  $12,  $38
        byte    $fa,  $1e,  $fc,  $73,  $ec,  $2c,  $32,  $81,  $43,  $04,  $3c,  $87,  $40,  $6f,  $08,  $80
        byte    $41,  $bf,  $03,  $b8,  $57,  $08,  $e2,  $6f,  $04,  $1c,  $04,  $7a,  $00,  $fb,  $5d,  $f8
        byte    $cd,  $ff,  $a0,  $95,  $30,  $e0,  $a0,  $01,  $bc,  $df,  $71,  $d8,  $01,  $dc,  $ef,  $fd
        byte    $17,  $1e,  $0c,  $7e,  $fa,  $02,  $2a,  $fd,  $4b,  $c0,  $0f,  $7f,  $03,  $ff,  $22,  $e0
        byte    $fe,  $63,  $03,  $3f,  $e1,  $20,  $03,  $3e,  $e3,  $21,  $93,  $e8,  $0b,  $58,  $f5,  $fd
        byte    $74,  $00,  $ff,  $c1,  $37,  $02,  $c0,  $fb,  $fd,  $9e,  $3f,  $f8,  $91,  $3f,  $87,  $3e
        byte    $f0,  $6f,  $ff,  $03,  $be,  $e7,  $07,  $be,  $bf,  $3e,  $8e,  $0e,  $fe,  $3e,  $80,  $de
        byte    $e4,  $8f,  $c7,  $c7,  $a7,  $ff,  $81,  $d3,  $87,  $df,  $08,  $c0,  $f3,  $f0,  $eb,  $81
        byte    $73,  $c0,  $df,  $8f,  $ff,  $1e,  $f8,  $ae,  $8f,  $9e,  $00,  $e0,  $06,  $3e,  $fd,  $0a
        byte    $e0,  $49,  $0f,  $3f,  $80,  $0e,  $c0,  $44,  $bf,  $e0,  $20,  $12,  $f0,  $ef,  $21,  $f2

        byte    $f5,  $d1,  $f5,  $d7,  $e7,  $d3,  $5d,  $74,  $f9,  $57,  $e0,  $75,  $1b,  $3d,  $01,  $e0
        byte    $bb,  $0e,  $3c,  $fa,  $ff,  $64,  $80,  $77,  $0d,  $38,  $ec,  $fa,  $00,  $d8,  $8d,  $f4
        byte    $26,  $ad,  $84,  $83,  $4a,  $00,  $7f,  $bf,  $07,  $bc,  $9f,  $f9,  $b6,  $00

c_14    byte    $ca,  $01,  $3c,  $00,  $08,  $e0,  $cf,  $7f,  $c2,  $08,  $0e,  $fc,  $fb,  $07,  $5e,  $c8
        byte    $07,  $fe,  $10,  $b9,  $fc,  $e3,  $07,  $70,  $48,  $40,  $4e,  $1f,  $00,  $3f,  $f1,  $07
        byte    $e0,  $00,  $78,  $0e,  $0f,  $fe,  $73,  $08,  $00,  $9f,  $c3,  $47,  $4e,  $00,  $f0,  $72
        byte    $f8,  $c9,  $85,  $27,  $87,  $bf,  $5c,  $3c,  $72,  $f8,  $cf,  $e5,  $01,  $80,  $80,  $dc
        byte    $0e,  $00,  $1a,  $c8,  $6d,  $00,  $b0,  $83,  $dc,  $02,  $80,  $e7,  $01,  $00,  $dc,  $43
        byte    $0f,  $ff,  $00,  $02,  $80,  $f3,  $91,  $07,  $5e,  $5e,  $38,  $7e,  $fa,  $e0,  $c9,  $c3
        byte    $01,  $47,  $ee,  $04,  $38,  $fc,  $ed,  $8c,  $c9,  $21,  $57,  $05,  $07,  $b9,  $f1,  $03
        byte    $c8,  $b1,  $31,  $43,  $0e,  $06,  $39,  $c0,  $03,  $08,  $60,  $c0,  $81,  $7f,  $e0,  $19
        byte    $01,  $e4,  $ef,  $bf,  $d7,  $60,  $7e,  $e0,  $00,  $02,  $1a,  $e8,  $eb,  $21,  $8f,  $0f
        byte    $ff,  $39,  $c0,  $6f,  $f0,  $1f,  $20,  $a7,  $80,  $8c,  $00,  $0c,  $f8,  $07,  $9f,  $81
        byte    $ff,  $04,  $07,  $b9,  $00,  $e7,  $07,  $d0,  $df,  $df,  $cf,  $9d,  $0c,  $f2,  $72,  $c8
        byte    $e7,  $67,  $27,  $70,  $00,  $00,  $70,  $f8,  $81,  $ef,  $df,  $7f,  $fe,  $9e,  $3e,  $e0
        byte    $fb,  $eb,  $05,  $27,  $2f,  $3c,  $0f,  $7d,  $c0,  $39,  $c8,  $03,  $3c,  $8f,  $00,  $e0
        byte    $06,  $7a,  $1b,  $00,  $2c,  $20,  $b7,  $03,  $80,  $00,  $f0,  $fb,  $f3,  $0f,  $1e,  $80
        byte    $07,  $00,  $00,  $f0,  $e5,  $f2,  $91,  $03,  $8f,  $9f,  $9e,  $7c,  $72,  $e0,  $c8,  $85
        byte    $2f,  $07,  $86,  $9c,  $02,  $c0,  $e7,  $40,  $90,  $d3,  $01,  $f0,  $1c,  $00,  $72,  $fa

        byte    $00,  $98,  $c7,  $7f,  $c6,  $9e,  $fe,  $f1,  $e7,  $72,  $e0,  $df,  $ff,  $a7,  $0a,  $39
        byte    $3a,  $02

c_15    byte    $ca,  $01,  $8c,  $00,  $08,  $e0,  $df,  $7f,  $c2,  $08,  $0e,  $72,  $00,  $2f,  $e4,  $c7
        byte    $bf,  $5f,  $fc,  $b9,  $3a,  $00,  $3c,  $24,  $20,  $a7,  $0f,  $80,  $9f,  $01,  $3a,  $00
        byte    $9e,  $c3,  $43,  $4f,  $01,  $e0,  $73,  $f8,  $c8,  $09,  $00,  $5e,  $0e,  $7f,  $b9,  $f8
        byte    $e4,  $c8,  $e0,  $1f,  $20,  $00,  $1f,  $79,  $3d,  $00,  $10,  $d0,  $db,  $01,  $40,  $03
        byte    $b9,  $0d,  $00,  $76,  $90,  $5b,  $00,  $f0,  $3c,  $00,  $80,  $7b,  $e8,  $0d,  $00,  $9c
        byte    $8f,  $3c,  $f0,  $f2,  $c2,  $f1,  $d3,  $07,  $4f,  $5e,  $1c,  $f9,  $fc,  $ed,  $e1,  $90
        byte    $ab,  $22,  $c7,  $7c,  $fe,  $81,  $03,  $08,  $68,  $c0,  $61,  $fe,  $fe,  $fb,  $ff,  $17
        byte    $30,  $e0,  $d0,  $ff,  $1f,  $83,  $f9,  $fb,  $bf,  $f8,  $b9,  $cf,  $a1,  $7f,  $e1,  $fe
        byte    $03,  $e5,  $ef,  $05,  $10,  $00,  $00,  $07,  $f9,  $7f,  $f6,  $f2,  $97,  $87,  $43,  $fe
        byte    $be,  $7e,  $f2,  $e0,  $c8,  $df,  $07,  $8f,  $8f,  $3c,  $70,  $f2,  $c2,  $f3,  $d0,  $07
        byte    $9c,  $83,  $3c,  $c0,  $f3,  $08,  $00,  $6e,  $a0,  $b7,  $01,  $c0,  $02,  $f2,  $00,  $04
        byte    $90,  $db,  $01,  $80,  $3c,  $3e,  $72,  $08,  $f3,  $ef,  $7f,  $01,  $9f,  $1c,  $42,  $72
        byte    $c1,  $cb,  $21,  $20,  $a7,  $00,  $f0,  $79,  $1c,  $00,  $cf,  $e3,  $03,  $60,  $0e,  $00
        byte    $3b,  $fd,  $67,  $04,  $e0,  $c7,  $bf,  $4f,  $fc,  $b9,  $1c,  $0c,  $f8,  $78,  $38,  $21

c_16    byte    $c2,  $02,  $42,  $00,  $08,  $f4,  $cf,  $bf,  $28,  $d1,  $41,  $47,  $00,  $f0,  $61,  $3f
        byte    $9d,  $f0,  $bb,  $1b,  $c1,  $27,  $74,  $09,  $e8,  $f2,  $01,  $70,  $d0,  $41,  $57,  $06
        byte    $f0,  $4e,  $0f,  $5d,  $02,  $c0,  $77,  $fa,  $e8,  $aa,  $80,  $d7,  $e9,  $a7,  $1b,  $4f
        byte    $a7,  $bf,  $6e,  $1e,  $9d,  $8d,  $11,  $e0,  $2b,  $3c,  $44,  $08,  $e8,  $02,  $5e,  $e1
        byte    $00,  $a0,  $81,  $9e,  $0a,  $c0,  $13,  $3d,  $02,  $80,  $f7,  $02,  $e8,  $f0,  $f0,  $d3
        byte    $01,  $ce,  $47,  $2f,  $bc,  $3e,  $38,  $7e,  $7e,  $f1,  $f4,  $e1,  $e8,  $06,  $0c,  $20
        byte    $a0,  $c3,  $9f,  $ff,  $c0,  $2e,  $0e,  $1d,  $e0,  $87,  $00,  $7e,  $74,  $65,  $2c,  $4c
        byte    $02,  $ee,  $c8,  $f8,  $e8,  $08,  $f0,  $31,  $e8,  $b0,  $7b,  $c0,  $41,  $85,  $e3,  $9e
        byte    $01,  $03,  $bf,  $1d,  $02,  $fa,  $fb,  $0d,  $fa,  $07,  $0e,  $20,  $c8,  $40,  $7f,  $7f
        byte    $a7,  $70,  $fc,  $00,  $02,  $0d,  $74,  $f9,  $0f,  $e8,  $1f,  $fc,  $ed,  $08,  $30,  $ec
        byte    $20,  $c1,  $78,  $a5,  $cf,  $c4,  $1e,  $80,  $1e,  $06,  $3a,  $0d,  $1f,  $76,  $00,  $30
        byte    $d0,  $e1,  $af,  $ab,  $21,  $90,  $43,  $7f,  $bf,  $1f,  $c3,  $fe,  $03,  $00,  $04,  $e2
        byte    $e8,  $ef,  $c3,  $e3,  $c3,  $b0,  $ff,  $00,  $00,  $81,  $70,  $3a,  $1c,  $f7,  $c0,  $f3
        byte    $d0,  $0b,  $ce,  $81,  $c3,  $0f,  $fe,  $00,  $02,  $81,  $f7,  $0a,  $e8,  $30,  $f0,  $d3
        byte    $01,  $38,  $a2,  $c7,  $01,  $c0,  $5e,  $0f,  $00,  $02,  $7e,  $78,  $74,  $3a,  $f0,  $cf
        byte    $bf,  $10,  $4f,  $a2,  $87,  $6e,  $78,  $bd,  $02,  $c0,  $77,  $3a,  $f8,  $32,  $00,  $bc

        byte    $73,  $a3,  $03,  $7f,  $81,  $0f,  $80,  $9d,  $11,  $5d,  $fe,  $9a,  $12,  $fc,  $7c,  $78
        byte    $88,  $e8,  $76,  $e0,  $3f,  $00,  $78,  $77,  $46,  $67,  $13

c_17    byte    $42,  $02,  $d2,  $03,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $ba,  $f8
        byte    $fb,  $4d,  $fe,  $89,  $9e,  $80,  $9e,  $0f,  $80,  $43,  $07,  $bd,  $0c,  $f0,  $ae,  $87
        byte    $9e,  $00,  $f0,  $5d,  $1f,  $bd,  $0a,  $bc,  $ae,  $bf,  $2e,  $fe,  $0a,  $9e,  $6e,  $33
        byte    $d2,  $f5,  $d1,  $ef,  $79,  $e8,  $08,  $f8,  $57,  $0c,  $00,  $8c,  $f4,  $e0,  $77,  $01
        byte    $3b,  $e8,  $77,  $04,  $00,  $ef,  $7f,  $07,  $1d,  $0f,  $ff,  $46,  $00,  $9c,  $8f,  $7e
        byte    $17,  $5e,  $1f,  $7c,  $17,  $8e,  $9f,  $5f,  $0f,  $4f,  $bf,  $87,  $a3,  $23,  $df,  $7f
        byte    $a0,  $ef,  $0f,  $be,  $87,  $3e,  $87,  $2e,  $80,  $ce,  $22,  $11,  $e8,  $3b,  $18,  $00
        byte    $ee,  $9e,  $fd,  $f0,  $ef,  $6c,  $c1,  $67,  $02,  $02,  $0e,  $c0,  $fb,  $43,  $0f,  $83
        byte    $7e,  $37,  $d2,  $71,  $1c,  $01,  $df,  $4a,  $3c,  $ba,  $c0,  $fb,  $02,  $fa,  $a3,  $8e
        byte    $61,  $ff,  $c2,  $01,  $f6,  $0d,  $76,  $f1,  $f7,  $bb,  $c6,  $27,  $c0,  $87,  $06,  $ba
        byte    $86,  $3b,  $81,  $9e,  $c3,  $42,  $0f,  $fc,  $e0,  $d3,  $5f,  $04,  $ba,  $0e,  $fe,  $fe
        byte    $e0,  $37,  $ba,  $8e,  $9f,  $06,  $12,  $85,  $ae,  $c3,  $2e,  $00,  $3f,  $99,  $8e,  $bf
        byte    $be,  $00,  $fe,  $1c,  $7a,  $85,  $4f,  $a0,  $d1,  $ef,  $0d,  $fd,  $78,  $f0,  $df,  $c7
        byte    $d1,  $bf,  $04,  $fb,  $f8,  $7b,  $78,  $7c,  $78,  $f0,  $df,  $87,  $d3,  $09,  $f4,  $01
        byte    $c0,  $e3,  $d0,  $6f,  $04,  $c0,  $f5,  $9b,  $11,  $e0,  $0c,  $be,  $f0,  $bb,  $02,  $3a
        byte    $04,  $fa,  $03,  $03,  $80,  $13,  $7e,  $fc,  $ff,  $1c,  $00,  $ec,  $67,  $02,  $9d,  $e4

        byte    $bf,  $e2,  $a3,  $0f,  $be,  $c8,  $a7,  $df,  $83,  $d7,  $f5,  $e0,  $bf,  $2b,  $60,  $e5
        byte    $a0,  $97,  $01,  $fe,  $dd,  $74,  $8a,  $3e,  $00,  $77,  $23,  $bd,  $44,  $2b,  $e1,  $07
        byte    $fe,  $03,  $7f,  $df,  $c1,  $25,  $00,  $bc,  $9f,  $e9,  $b6,  $00

c_18    byte    $8c,  $02,  $ba,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $0f,  $ff
        byte    $e7,  $9b,  $7f,  $12,  $f0,  $93,  $6f,  $80,  $27,  $38,  $f8,  $c9,  $31,  $f0,  $ef,  $e1
        byte    $27,  $c1,  $e0,  $bf,  $8f,  $9f,  $00,  $e2,  $fb,  $7e,  $fe,  $c7,  $f3,  $fd,  $fd,  $cf
        byte    $e3,  $09,  $b8,  $79,  $79,  $f8,  $ff,  $2f,  $07,  $00,  $0d,  $fc,  $ff,  $16,  $60,  $07
        byte    $3f,  $f1,  $7f,  $02,  $80,  $ff,  $f3,  $5f,  $78,  $1e,  $ee,  $ff,  $e0,  $7c,  $fc,  $84
        byte    $ff,  $c3,  $fb,  $e7,  $7f,  $38,  $8f,  $ff,  $c7,  $ff,  $f1,  $f8,  $19,  $3e,  $fc,  $c3
        byte    $ff,  $38,  $be,  $81,  $ff,  $9f,  $3f,  $fc,  $a3,  $c0,  $ff,  $1c,  $e6,  $f0,  $f0,  $db
        byte    $9f,  $02,  $f8,  $9f,  $ef,  $ff,  $0f,  $3f,  $80,  $8b,  $83,  $07,  $be,  $4d,  $fc,  $ff
        byte    $ff,  $34,  $00,  $3a,  $f8,  $3f,  $f9,  $00,  $ff,  $81,  $ff,  $24,  $80,  $ff,  $17,  $fe
        byte    $b3,  $1f,  $c3,  $fe,  $1f,  $f0,  $9b,  $1c,  $fc,  $84,  $ff,  $27,  $01,  $3f,  $03,  $3c
        byte    $ff,  $67,  $f0,  $5f,  $c0,  $76,  $ec,  $3f,  $fc,  $67,  $70,  $38,  $fc,  $80,  $01,  $18
        byte    $d8,  $df,  $3f,  $fc,  $ff,  $ff,  $0b,  $df,  $41,  $f3,  $90,  $f8,  $fb,  $00,  $7f,  $fe
        byte    $7f,  $06,  $d2,  $61,  $e0,  $ef,  $2f,  $00,  $7e,  $18,  $73,  $e0,  $e7,  $c3,  $3f,  $fe
        byte    $e7,  $80,  $ff,  $ff,  $1f,  $c0,  $e7,  $f3,  $ff,  $c3,  $11,  $f0,  $f8,  $f1,  $0f,  $ff
        byte    $c4,  $ff,  $ff,  $87,  $83,  $e3,  $ff,  $ff,  $60,  $f8,  $f3,  $0f,  $fe,  $26,  $78,  $10
        byte    $fe,  $3f,  $01,  $5c,  $fa,  $ff,  $03,  $2f,  $fe,  $43,  $1f,  $02,  $fe,  $ff,  $1f,  $b0

        byte    $80,  $ff,  $9f,  $03,  $80,  $df,  $3f,  $e0,  $13,  $3c,  $bc,  $72,  $fe,  $f7,  $51,  $fd
        byte    $fd,  $89,  $a7,  $fa,  $79,  $00,  $27,  $bc,  $ea,  $e1,  $0f,  $01,  $e0,  $bf,  $83,  $3f
        byte    $0c,  $00,  $ff,  $ed,  $75,  $1f,  $00,  $7b,  $fa,  $c5,  $df,  $cd,  $7e,  $c0,  $fb,  $c0
        byte    $ff,  $b3,  $03,  $ff,  $01,  $f8,  $cf,  $e9,  $cf,  $04

c_19    byte    $8c,  $02,  $fa,  $03,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $8f,  $ff
        byte    $e7,  $9b,  $7f,  $32,  $f0,  $33,  $c0,  $13,  $1c,  $fc,  $0c,  $fc,  $7b,  $f8,  $49,  $3e
        byte    $f8,  $ef,  $e3,  $a7,  $03,  $ef,  $fb,  $fb,  $1f,  $cf,  $ff,  $27,  $00,  $f7,  $f1,  $f7
        byte    $7f,  $1e,  $9e,  $80,  $ff,  $9f,  $01,  $80,  $e9,  $67,  $c0,  $2b,  $39,  $f8,  $7f,  $09
        byte    $00,  $fe,  $6f,  $02,  $08,  $00,  $bc,  $87,  $9b,  $3f,  $38,  $1f,  $3f,  $03,  $08,  $f0
        byte    $be,  $9f,  $ff,  $e1,  $2c,  $fe,  $0e,  $5e,  $f9,  $78,  $be,  $80,  $ff,  $71,  $fc,  $e1
        byte    $8f,  $ff,  $7f,  $03,  $ff,  $f0,  $51,  $1b,  $87,  $df,  $0c,  $fc,  $ff,  $e0,  $b7,  $f0
        byte    $bf,  $ff,  $3f,  $fc,  $00,  $2c,  $0e,  $1e,  $f8,  $36,  $81,  $ff,  $ff,  $05,  $c0,  $ff
        byte    $0f,  $f8,  $4f,  $fc,  $fe,  $13,  $0e,  $78,  $04,  $1f,  $cd,  $c1,  $07,  $ff,  $0d,  $b4
        byte    $f4,  $0c,  $e3,  $ff,  $a9,  $fd,  $e7,  $1f,  $e0,  $09,  $7e,  $be,  $c3,  $07,  $fc,  $7b
        byte    $30,  $bc,  $3e,  $fc,  $2f,  $e0,  $7b,  $f0,  $cf,  $ff,  $ff,  $f5,  $0b,  $40,  $00,  $cf
        byte    $21,  $ff,  $ff,  $c0,  $3f,  $03,  $df,  $c7,  $e1,  $8f,  $ff,  $ff,  $7f,  $fc,  $3c,  $07
        byte    $61,  $fa,  $2f,  $1e,  $00,  $7f,  $7c,  $7e,  $be,  $01,  $f8,  $0c,  $38,  $c0,  $f3,  $f7
        byte    $16,  $00,  $7e,  $e7,  $ff,  $ef,  $03,  $e3,  $03,  $e3,  $3f,  $80,  $07,  $e0,  $00,  $3f
        byte    $8e,  $ff,  $9f,  $00,  $f8,  $ff,  $04,  $e0,  $2f,  $c0,  $c1,  $23,  $e0,  $ff,  $17,  $e0
        byte    $7c,  $ff,  $80,  $6f,  $82,  $67,  $e0,  $fc,  $9f,  $c0,  $fd,  $ff,  $13,  $70,  $07,  $27

        byte    $00,  $fc,  $02,  $9e,  $81,  $ff,  $01,  $2c,  $c0,  $02,  $fe,  $8a,  $0e,  $00,  $b6,  $ff
        byte    $d3,  $eb,  $8f,  $ff,  $4f,  $3c,  $ba,  $bf,  $3f,  $f9,  $54,  $1f,  $f8,  $7b,  $82,  $d7
        byte    $3d,  $fc,  $21,  $00,  $fc,  $77,  $f0,  $47,  $03,  $fe,  $0d,  $c0,  $ef,  $3e,  $00,  $f7
        byte    $e4,  $bf,  $d7,  $9f,  $fc,  $c0,  $f7,  $81,  $ff,  $66,  $07,  $fe,  $03,  $f0,  $9f,  $d3
        byte    $9f,  $09

c_20    byte    $8c,  $02,  $46,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $8f,  $ff
        byte    $e7,  $9b,  $7f,  $12,  $f0,  $33,  $c0,  $13,  $1c,  $fc,  $0c,  $fc,  $7b,  $f8,  $19,  $fc
        byte    $f7,  $f1,  $33,  $be,  $ef,  $e7,  $27,  $fe,  $7c,  $fe,  $cd,  $f8,  $79,  $3c,  $01,  $ff
        byte    $3f,  $07,  $ff,  $67,  $f8,  $0f,  $a0,  $81,  $ff,  $df,  $02,  $ec,  $e0,  $67,  $f0,  $02
        byte    $80,  $ff,  $9b,  $1e,  $80,  $e7,  $61,  $f8,  $4e,  $61,  $3d,  $70,  $3e,  $86,  $c3,  $0f
        byte    $f8,  $c1,  $fb,  $06,  $ff,  $87,  $e3,  $67,  $01,  $f8,  $00,  $1b,  $9e,  $c7,  $bf,  $15
        byte    $ff,  $1f,  $c7,  $7f,  $1e,  $5e,  $09,  $cf,  $1f,  $fe,  $e6,  $e0,  $37,  $0e,  $bf,  $09
        byte    $e0,  $5f,  $fe,  $83,  $3f,  $f1,  $7d,  $0e,  $fe,  $ff,  $f2,  $f3,  $1d,  $3c,  $f0,  $d3
        byte    $03,  $c0,  $f6,  $81,  $4f,  $03,  $ed,  $fb,  $17,  $3e,  $17,  $fc,  $ff,  $04,  $cf,  $c5
        byte    $e7,  $3f,  $c3,  $fc,  $47,  $f0,  $91,  $0c,  $3c,  $87,  $e9,  $3b,  $00,  $fc,  $db,  $1b
        byte    $00,  $04,  $80,  $ff,  $1e,  $de,  $78,  $01,  $df,  $e3,  $ff,  $f1,  $7f,  $3e,  $df,  $87
        byte    $7f,  $fe,  $df,  $83,  $41,  $fc,  $df,  $3f,  $40,  $00,  $06,  $1c,  $3f,  $3f,  $27,  $00
        byte    $7f,  $02,  $1e,  $7c,  $7f,  $47,  $3f,  $f8,  $67,  $c0,  $61,  $fb,  $f8,  $f1,  $fd,  $ef
        byte    $3f,  $c0,  $f7,  $f1,  $1c,  $04,  $60,  $ff,  $79,  $00,  $78,  $38,  $08,  $fb,  $e0,  $0d
        byte    $00,  $3f,  $c1,  $d0,  $5f,  $00,  $e0,  $63,  $78,  $06,  $fe,  $e7,  $83,  $23,  $38,  $f8
        byte    $80,  $01,  $f8,  $80,  $f3,  $ff,  $77,  $00,  $1f,  $8e,  $87,  $0f,  $10,  $80,  $00,  $f0

        byte    $ff,  $7f,  $00,  $e0,  $e0,  $79,  $f8,  $2b,  $02,  $01,  $e7,  $e0,  $f1,  $ff,  $19,  $f8
        byte    $ff,  $57,  $c0,  $33,  $e0,  $1f,  $ff,  $4d,  $0b,  $b0,  $80,  $ff,  $3f,  $c0,  $f2,  $e0
        byte    $ff,  $e4,  $e1,  $3f,  $f0,  $3f,  $f9,  $e8,  $fe,  $fe,  $c4,  $53,  $7d,  $00,  $ef,  $09
        byte    $5e,  $f7,  $f0,  $87,  $00,  $f0,  $df,  $c1,  $1f,  $06,  $7a,  $13,  $00,  $bf,  $04,  $1f
        byte    $00,  $7b,  $f2,  $df,  $eb,  $4f,  $7e,  $c0,  $fb,  $c0,  $7f,  $b3,  $03,  $ff,  $01,  $f8
        byte    $cf,  $e9,  $cf,  $04

c_21    byte    $4e,  $01,  $e2,  $01,  $08,  $c0,  $bf,  $ff,  $10,  $83,  $70,  $10,  $0e,  $f0,  $88,  $fc
        byte    $84,  $83,  $3f,  $bc,  $30,  $32,  $16,  $10,  $1e,  $c0,  $bc,  $0b,  $f6,  $10,  $1f,  $f8
        byte    $78,  $ca,  $8c,  $04,  $7e,  $38,  $fe,  $e2,  $6b,  $30,  $7c,  $df,  $b3,  $25,  $e8,  $11
        byte    $60,  $db,  $fe,  $0d,  $00,  $34,  $90,  $57,  $38,  $80,  $77,  $8d,  $84,  $bf,  $00,  $e0
        byte    $e1,  $38,  $df,  $0f,  $f8,  $18,  $c6,  $c3,  $03,  $e7,  $c3,  $3f,  $e0,  $b1,  $e0,  $85
        byte    $03,  $70,  $90,  $35,  $e0,  $ac,  $01,  $20,  $0a,  $e0,  $00,  $f0,  $84,  $5b,  $44,  $38
        byte    $38,  $fc,  $f0,  $07,  $d0,  $04,  $60,  $00,  $38,  $fc,  $1d,  $b1,  $04,  $40,  $00,  $1c
        byte    $fc,  $3d,  $e9,  $ff,  $94,  $f0,  $fd,  $85,  $eb,  $bf,  $19,  $00,  $3c,  $c2,  $29,  $06
        byte    $78,  $0d,  $1e,  $f2,  $09,  $47,  $78,  $02,  $06,  $ea,  $09,  $c7,  $70,  $83,  $49,  $84
        byte    $63,  $70,  $00,  $00,  $f0,  $86,  $8d,  $a4,  $14,  $3c,  $00,  $0c,  $f8,  $5f,  $25,  $17
        byte    $1f,  $e1,  $f0,  $df,  $cd,  $01,  $40,  $03,  $f8,  $6f,  $69,  $c8,  $00,  $fc,  $07,  $1a
        byte    $04,  $1f,  $8e,  $3f,  $ff,  $0d,  $19,  $00,  $1f,  $ce,  $99,  $78,  $1c,  $00,  $f7,  $1f
        byte    $40,  $03,  $1e,  $1c,  $08,  $0f,  $43,  $ff,  $9c,  $0e,  $0d,  $87,  $03,  $bf,  $41,  $c7
        byte    $06,  $c3,  $01,  $3f,  $a7,  $c3,  $35,  $fc,  $03,  $ff,  $c7,  $01,  $87,  $39,  $c2,  $f9
        byte    $27,  $7c,  $c0,  $ff,  $70,  $e0,  $b0,  $86,  $7f,  $80,  $02,  $80,  $e3,  $c0,  $b1,  $46
        byte    $38,  $00,  $e0,  $c3,  $09,  $ef,  $5f,  $38,  $78,  $d2,  $d9,  $93,  $07,  $38,  $38,  $e1

        byte    $dc,  $01,  $60,  $17,  $78,  $ed,  $84,  $6b,  $00,  $38,  $b8,  $70,  $e0,  $e7,  $23,  $00
        byte    $30,  $f0,  $79,  $76,  $89,  $10,  $b8,  $81,  $39,  $c2,  $00,  $30,  $89,  $80,  $f0,  $1d
        byte    $00,  $04,  $e0,  $1f,  $70,  $bc,  $0e,  $82,  $99,  $33,  $84,  $47,  $00,  $f8,  $4b,  $22
        byte    $1c,  $3e,  $41,  $f8,  $48,  $13,  $00,  $bc,  $10,  $7e,  $68,  $b3,  $db,  $65,  $c2,  $09
        byte    $4e,  $c0,  $bc,  $3e,  $8a,  $f3,  $df,  $6c,  $71,  $7e,  $e0,  $fb,  $b8,  $32,  $47,  $ff
        byte    $fe,  $8f,  $4a,  $35,  $53,  $00

c_22    byte    $4e,  $01,  $92,  $00,  $08,  $c0,  $bf,  $ff,  $10,  $83,  $70,  $10,  $0e,  $f0,  $88,  $fc
        byte    $84,  $83,  $3f,  $bc,  $30,  $32,  $16,  $10,  $1e,  $c0,  $bc,  $0b,  $f6,  $10,  $1f,  $f8
        byte    $78,  $7c,  $84,  $57,  $61,  $9d,  $91,  $f0,  $1f,  $2d,  $c1,  $70,  $ea,  $ee,  $30,  $7c
        byte    $ff,  $ee,  $01,  $1a,  $28,  $cb,  $bf,  $71,  $c0,  $bb,  $c8,  $8f,  $54,  $30,  $f0,  $70
        byte    $c0,  $87,  $0b,  $10,  $f8,  $18,  $c0,  $fd,  $45,  $00,  $10,  $dc,  $18,  $80,  $07,  $05
        byte    $00,  $2f,  $1c,  $80,  $41,  $f4,  $01,  $27,  $06,  $00,  $45,  $ac,  $81,  $27,  $dc,  $2e
        byte    $e0,  $03,  $c0,  $e1,  $67,  $a9,  $3b,  $70,  $f8,  $bb,  $d2,  $3f,  $70,  $00,  $1c,  $fc
        byte    $25,  $03,  $c0,  $1f,  $e0,  $70,  $c1,  $03,  $03,  $e0,  $07,  $60,  $38,  $c9,  $e4,  $e0
        byte    $e3,  $97,  $66,  $04,  $67,  $e0,  $21,  $3c,  $83,  $15,  $38,  $48,  $27,  $1e,  $07,  $1d
        byte    $96,  $13,  $ca,  $05,  $a9,  $14,  $11,  $5e,  $2a,  $f0,  $00,  $18,  $c0,  $7f,  $ca,  $28
        byte    $78,  $c2,  $81,  $7f,  $40,  $2a,  $3c,  $c2,  $01,  $ef,  $cf,  $7f,  $47,  $06,  $80,  $fb
        byte    $f7,  $df,  $91,  $01,  $c1,  $e1,  $74,  $64,  $c0,  $60,  $38,  $fe,  $3b,  $00,  $ee,  $c0
        byte    $61,  $b8,  $1d,  $80,  $73,  $30,  $86,  $7f,  $fb,  $73,  $e0,  $71,  $d0,  $87,  $7f,  $f0
        byte    $03,  $f0,  $08,  $0f,  $38,  $38,  $00,  $1e,  $1c,  $f4,  $e1,  $1f,  $f0,  $1c,  $0e,  $38
        byte    $86,  $0b,  $70,  $8e,  $f0,  $53,  $09,  $84,  $c3,  $1e,  $63,  $38,  $00,  $c8,  $01,  $47
        byte    $38,  $6b,  $18,  $00,  $8c,  $23,  $7c,  $01,  $c0,  $e1,  $e0,  $e9,  $e7,  $0e,  $00,  $e0

        byte    $c1,  $c1,  $09,  $e7,  $0f,  $00,  $70,  $80,  $c3,  $5b,  $67,  $16,  $00,  $3a,  $00,  $1f
        byte    $30,  $c6,  $1d,  $1e,  $00,  $3e,  $e0,  $ff,  $16,  $00,  $0e,  $04,  $02,  $37,  $f0,  $2b
        byte    $00,  $03,  $9d,  $08,  $18,  $23,  $9d,  $04,  $00,  $0a,  $18,  $23,  $5c,  $0f,  $c1,  $f4
        byte    $19,  $82,  $8f,  $20,  $f0,  $c5,  $09,  $e0,  $13,  $00,  $7c,  $c2,  $83,  $d7,  $5d,  $30
        byte    $02,  $96,  $75,  $30,  $6f,  $70,  $02,  $2a,  $f4,  $31,  $2d,  $80,  $09,  $a7,  $03,  $e0
        byte    $07,  $be,  $8f,  $e1,  $1d,  $f8,  $f7,  $5f,  $64,  $ab,  $e1,  $84,  $08

c_23    byte    $81,  $01,  $e2,  $01,  $08,  $c0,  $bf,  $ff,  $20,  $03,  $71,  $10,  $1c,  $f0,  $10,  $01
        byte    $f8,  $09,  $0e,  $7f,  $f0,  $00,  $82,  $89,  $31,  $04,  $01,  $c1,  $fb,  $07,  $18,  $6f
        byte    $f0,  $fe,  $13,  $f4,  $10,  $bc,  $7f,  $f0,  $e1,  $f9,  $08,  $de,  $3f,  $fc,  $e0,  $fc
        byte    $05,  $ef,  $3f,  $c3,  $e0,  $43,  $2e,  $3b,  $fc,  $40,  $00,  $66,  $9b,  $63,  $0e,  $06
        byte    $fc,  $f3,  $8f,  $d9,  $3f,  $e0,  $ba,  $f0,  $d7,  $a8,  $1f,  $78,  $70,  $f0,  $73,  $86
        byte    $0f,  $bc,  $18,  $f0,  $25,  $83,  $07,  $17,  $46,  $ac,  $d5,  $c1,  $0b,  $0e,  $e0,  $80
        byte    $80,  $e1,  $24,  $01,  $20,  $93,  $6c,  $f0,  $f8,  $e1,  $0f,  $a0,  $50,  $00,  $38,  $fc
        byte    $d4,  $5a,  $48,  $70,  $fe,  $5a,  $f5,  $17,  $1a,  $07,  $7f,  $99,  $2c,  $d4,  $4f,  $70
        byte    $c0,  $23,  $f0,  $31,  $0e,  $07,  $ff,  $82,  $a3,  $f0,  $00,  $18,  $40,  $6e,  $06,  $32
        byte    $70,  $b0,  $8c,  $03,  $fe,  $21,  $85,  $11,  $3c,  $fe,  $ba,  $00,  $1a,  $88,  $be,  $ed
        byte    $d1,  $92,  $73,  $00,  $be,  $86,  $b0,  $b2,  $33,  $00,  $7c,  $ac,  $b0,  $e0,  $35,  $26
        byte    $78,  $ae,  $b0,  $e0,  $04,  $67,  $30,  $b8,  $12,  $70,  $04,  $d7,  $67,  $dd,  $c1,  $4d
        byte    $59,  $62,  $70,  $f7,  $fa,  $0f,  $6a,  $b2,  $2d,  $c7,  $12,  $b0,  $78,  $72,  $e6,  $ab
        byte    $d9,  $37,  $38,  $e1,  $25,  $a6,  $7b,  $59,  $89,  $0e,  $ee,  $04,  $00,  $0e,  $00,  $9e
        byte    $f1,  $96,  $2c,  $07,  $47,  $f0,  $c5,  $94,  $c3,  $81,  $43,  $76,  $d5,  $f0,  $00,  $e0
        byte    $61,  $3f,  $ff,  $cd,  $78,  $00,  $c0,  $23,  $f8,  $21,  $01,  $e2,  $c1,  $f3,  $7e,  $35

        byte    $80,  $e1,  $c1,  $79,  $ff,  $01,  $c0,  $e0,  $e1,  $b5,  $07,  $20,  $00,  $e1,  $c0,  $c1
        byte    $39,  $78,  $1e,  $80,  $39,  $80,  $0d,  $3c,  $ff,  $80,  $00,  $e0,  $06,  $b2,  $89,  $8e
        byte    $c7,  $41,  $21,  $c5,  $8f,  $e1,  $e6,  $f0,  $43,  $72,  $10,  $48,  $fc,  $31,  $06,  $82
        byte    $27,  $7a,  $00,  $7c,  $42,  $0d,  $1e,  $c0,  $05,  $ad,  $cc,  $55,  $41,  $92,  $0e,  $9a
        byte    $03,  $10,  $78,  $68,  $29,  $fa,  $88,  $1c,  $c0,  $31,  $81,  $26,  $e9,  $07,  $be,  $8f
        byte    $c6,  $0b,  $3f,  $28,  $d1,  $08,  $83,  $0b,  $12

c_24    byte    $8c,  $02,  $fa,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $8f,  $ff
        byte    $e7,  $9b,  $7f,  $12,  $f0,  $33,  $c0,  $13,  $1c,  $fc,  $0c,  $fc,  $7b,  $f8,  $19,  $fc
        byte    $f7,  $f1,  $33,  $fc,  $ef,  $ef,  $67,  $fe,  $ff,  $e6,  $f4,  $05,  $fc,  $9c,  $01,  $fc
        byte    $e1,  $f3,  $26,  $80,  $06,  $a6,  $8f,  $9f,  $00,  $3b,  $28,  $f8,  $3d,  $fc,  $04,  $7c
        byte    $c2,  $77,  $f0,  $ff,  $07,  $6f,  $e0,  $a7,  $e1,  $a3,  $00,  $fe,  $8d,  $3f,  $bc,  $0f
        byte    $50,  $c0,  $09,  $f8,  $e1,  $f8,  $e1,  $0f,  $20,  $7c,  $f8,  $78,  $1e,  $fe,  $ff,  $81
        byte    $e3,  $f0,  $07,  $1f,  $06,  $80,  $e6,  $1f,  $f0,  $07,  $0e,  $e7,  $f9,  $79,  $00,  $39
        byte    $f8,  $03,  $8c,  $ff,  $f9,  $e0,  $5f,  $be,  $c0,  $f9,  $f0,  $ff,  $65,  $e0,  $7b,  $00
        byte    $ff,  $1c,  $e0,  $1f,  $fe,  $27,  $f0,  $0a,  $de,  $c7,  $03,  $68,  $00,  $f0,  $07,  $ee
        byte    $ef,  $ad,  $ff,  $c7,  $f9,  $02,  $c6,  $17,  $f8,  $81,  $af,  $6c,  $c0,  $c1,  $07,  $ff
        byte    $c0,  $a5,  $e7,  $e1,  $c3,  $ff,  $df,  $c7,  $ff,  $70,  $be,  $bf,  $8f,  $7f,  $e1,  $f8
        byte    $37,  $f1,  $5f,  $1c,  $92,  $83,  $ff,  $ff,  $ff,  $c9,  $fd,  $fe,  $3f,  $19,  $07,  $68
        byte    $20,  $39,  $f8,  $c9,  $e0,  $ff,  $3f,  $09,  $00,  $9c,  $1d,  $f8,  $3b,  $f8,  $01,  $00
        byte    $cf,  $1c,  $3e,  $fc,  $05,  $2e,  $7f,  $ff,  $e0,  $ff,  $ff,  $0f,  $f0,  $82,  $93,  $71
        byte    $f8,  $79,  $00,  $d7,  $c8,  $ff,  $8d,  $c0,  $23,  $c3,  $f1,  $81,  $ff,  $73,  $28,  $78
        byte    $3e,  $fc,  $ef,  $a0,  $0c,  $78,  $1e,  $80,  $7f,  $03,  $02,  $07,  $38,  $07,  $80,  $ff

        byte    $33,  $38,  $80,  $3f,  $80,  $5f,  $80,  $67,  $81,  $cf,  $00,  $e0,  $9f,  $f8,  $6f,  $01
        byte    $ff,  $04,  $7c,  $0e,  $00,  $36,  $e0,  $37,  $81,  $f3,  $30,  $e1,  $ff,  $04,  $c4,  $c7
        byte    $c4,  $f7,  $33,  $9e,  $ca,  $e7,  $67,  $78,  $d5,  $03,  $c0,  $2e,  $00,  $7c,  $77,  $00
        byte    $bc,  $f7,  $6e,  $00,  $7e,  $f7,  $01,  $b0,  $27,  $ff,  $bd,  $fe,  $e4,  $07,  $be,  $0f
        byte    $fc,  $37,  $7b,  $f0,  $1f,  $80,  $ff,  $9c,  $fe,  $4c

c_25    byte    $4c,  $02,  $aa,  $01,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $5e,  $fc
        byte    $ff,  $99,  $7e,  $02,  $7e,  $80,  $00,  $02,  $07,  $3f,  $f0,  $d7,  $c3,  $0f,  $fe,  $f5
        byte    $f3,  $c3,  $7f,  $fd,  $fd,  $f8,  $7f,  $ff,  $d1,  $3b,  $ba,  $ff,  $00,  $0a,  $18,  $1d
        byte    $ff,  $06,  $46,  $83,  $1f,  $60,  $07,  $03,  $7f,  $03,  $1f,  $f0,  $17,  $be,  $80,  $df
        byte    $c3,  $00,  $fc,  $07,  $ef,  $e3,  $01,  $0c,  $a0,  $08,  $e1,  $bf,  $47,  $e0,  $ef,  $f3
        byte    $83,  $ff,  $f7,  $0f,  $ff,  $01,  $8f,  $01,  $40,  $73,  $04,  $38,  $1a,  $e0,  $78,  $3e
        byte    $fc,  $8f,  $3f,  $80,  $fc,  $1f,  $1f,  $fe,  $e1,  $73,  $e0,  $27,  $60,  $f8,  $80,  $3f
        byte    $f0,  $1c,  $bc,  $1e,  $0a,  $80,  $0f,  $78,  $1f,  $a3,  $03,  $fe,  $00,  $0a,  $c0,  $7e
        byte    $3e,  $fc,  $2f,  $c0,  $23,  $00,  $6c,  $00,  $fc,  $db,  $fc,  $80,  $5f,  $0f,  $2f,  $70
        byte    $01,  $9f,  $8f,  $17,  $3c,  $00,  $e0,  $89,  $81,  $33,  $f9,  $7f,  $f8,  $00,  $c0,  $25
        byte    $ff,  $ff,  $e3,  $07,  $00,  $27,  $f9,  $5f,  $18,  $bf,  $7f,  $fe,  $0b,  $8e,  $c4,  $c1
        byte    $12,  $3a,  $5f,  $38,  $fc,  $fe,  $1d,  $fe,  $4b,  $c0,  $df,  $00,  $40,  $07,  $00,  $92
        byte    $17,  $ff,  $ff,  $f8,  $f3,  $0f,  $5e,  $00,  $60,  $03,  $00,  $39,  $bc,  $0b,  $80,  $44
        byte    $c0,  $7f,  $04,  $c0,  $1f,  $c0,  $1c,  $fc,  $f0,  $7f,  $c1,  $15,  $c0,  $71,  $3c,  $f0
        byte    $ff,  $af,  $78,  $e1,  $14,  $e0,  $f0,  $f8,  $00,  $f8,  $3f,  $70,  $9e,  $33,  $c1,  $91
        byte    $1c,  $f0,  $38,  $7c,  $18,  $1a,  $f8,  $e0,  $1c,  $7c,  $1c,  $0c,  $00,  $0f,  $1e,  $80

        byte    $00,  $82,  $c6,  $83,  $c0,  $c7,  $00,  $e0,  $cf,  $c7,  $2a,  $00,  $f8,  $bb,  $e0,  $77
        byte    $00,  $f0,  $01,  $ff,  $35,  $1e,  $46,  $f8,  $a5,  $00,  $c0,  $3c,  $46,  $3c,  $65,  $02
        byte    $70,  $e2,  $f1,  $15,  $f0,  $46,  $0f,  $00,  $5b,  $01,  $e0,  $5b,  $07,  $80,  $3b,  $e0
        byte    $ad,  $00,  $f8,  $ad,  $0f,  $80,  $6d,  $e2,  $bf,  $ad,  $46,  $3f,  $f0,  $3d,  $24,  $6b
        byte    $ea,  $c0,  $7f,  $00,  $fc,  $6f,  $de,  $0b

c_26    byte    $8c,  $02,  $06,  $03,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $8f,  $ff
        byte    $e7,  $9b,  $7f,  $12,  $f0,  $33,  $e0,  $13,  $1c,  $fc,  $0c,  $fc,  $7b,  $f8,  $19,  $fc
        byte    $f7,  $f1,  $33,  $fc,  $ef,  $ef,  $67,  $fe,  $ff,  $e6,  $f4,  $01,  $6c,  $fd,  $35,  $1d
        byte    $01,  $53,  $f8,  $4f,  $00,  $0d,  $cc,  $f6,  $13,  $60,  $07,  $85,  $3f,  $80,  $9f,  $80
        byte    $7b,  $28,  $f0,  $9f,  $bf,  $f6,  $3f,  $e0,  $ff,  $c1,  $fb,  $68,  $27,  $f8,  $f9,  $f0
        byte    $1f,  $fe,  $ff,  $fd,  $bf,  $06,  $9e,  $01,  $80,  $ff,  $f0,  $37,  $80,  $3e,  $5e,  $3a
        byte    $9f,  $df,  $6a,  $ff,  $e3,  $87,  $67,  $60,  $00,  $f4,  $f0,  $b9,  $03,  $9b,  $ff,  $73
        byte    $00,  $e0,  $67,  $3c,  $07,  $05,  $ff,  $13,  $d0,  $02,  $e0,  $0f,  $be,  $f4,  $6f,  $a0
        byte    $1e,  $1f,  $2d,  $00,  $7f,  $fc,  $01,  $bc,  $fb,  $1f,  $fc,  $ff,  $13,  $78,  $01,  $c0
        byte    $ff,  $ff,  $0f,  $f0,  $33,  $f0,  $13,  $fc,  $05,  $fc,  $ff,  $ff,  $ff,  $ff,  $0b,  $dc
        byte    $ff,  $09,  $ff,  $ff,  $ff,  $2f,  $30,  $c9,  $c1,  $4f,  $dc,  $17,  $9c,  $ff,  $13,  $c7
        byte    $05,  $e3,  $7f,  $fe,  $0e,  $16,  $8e,  $ff,  $e1,  $ff,  $df,  $3e,  $60,  $03,  $00,  $38
        byte    $a4,  $e7,  $cf,  $7f,  $7b,  $00,  $7f,  $7a,  $f8,  $9f,  $80,  $e7,  $a0,  $7d,  $f0,  $1f
        byte    $f0,  $7f,  $7e,  $00,  $fe,  $67,  $a0,  $e1,  $e0,  $53,  $22,  $f0,  $07,  $f0,  $e1,  $f9
        byte    $e9,  $09,  $78,  $07,  $c7,  $4f,  $e0,  $1e,  $60,  $38,  $3c,  $fe,  $ff,  $f0,  $38,  $fc
        byte    $04,  $26,  $01,  $07,  $e7,  $e0,  $27,  $38,  $02,  $5e,  $78,  $00,  $4f,  $80,  $31,  $84

        byte    $3f,  $03,  $80,  $3f,  $0e,  $1f,  $06,  $97,  $00,  $e0,  $ff,  $f1,  $33,  $00,  $70,  $fd
        byte    $e2,  $01,  $7c,  $6a,  $01,  $7e,  $5d,  $80,  $7d,  $4c,  $7c,  $d5,  $41,  $c1,  $33,  $79
        byte    $d4,  $0c,  $af,  $7a,  $00,  $d8,  $05,  $80,  $ef,  $0e,  $80,  $f7,  $de,  $0d,  $c0,  $ef
        byte    $3e,  $00,  $f6,  $e4,  $bf,  $f3,  $bf,  $d9,  $0f,  $7c,  $1f,  $f8,  $7f,  $76,  $e0,  $3f
        byte    $00,  $ff,  $39,  $fd,  $99,  $00

c_27    byte    $4c,  $02,  $ca,  $02,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $5e,  $fc
        byte    $ff,  $99,  $7e,  $02,  $7e,  $80,  $00,  $02,  $07,  $3f,  $f0,  $d7,  $c3,  $0f,  $fe,  $f5
        byte    $f3,  $c3,  $7f,  $fd,  $fd,  $f8,  $7f,  $ff,  $21,  $ff,  $77,  $f2,  $d7,  $02,  $14,  $d0
        byte    $82,  $ff,  $0d,  $bc,  $00,  $fd,  $b4,  $80,  $1d,  $34,  $f8,  $01,  $7c,  $c0,  $df,  $e2
        byte    $1f,  $3c,  $f8,  $3f,  $02,  $1f,  $4d,  $00,  $be,  $81,  $ff,  $3f,  $cb,  $03,  $d8,  $00
        byte    $c0,  $e6,  $78,  $f9,  $00,  $58,  $1e,  $0f,  $1f,  $98,  $67,  $f8,  $f1,  $1f,  $0e,  $1e
        byte    $c0,  $1e,  $8a,  $e0,  $f5,  $f3,  $3a,  $78,  $f9,  $0b,  $68,  $01,  $ff,  $1e,  $5e,  $e0
        byte    $ff,  $99,  $3c,  $06,  $46,  $e6,  $ff,  $e7,  $e0,  $03,  $ff,  $c2,  $ff,  $1f,  $01,  $fe
        byte    $01,  $ff,  $2f,  $7f,  $00,  $3f,  $7c,  $01,  $e0,  $1f,  $03,  $fe,  $c3,  $67,  $01,  $fc
        byte    $fb,  $7f,  $81,  $ff,  $ff,  $ff,  $e0,  $5f,  $80,  $fd,  $1f,  $b8,  $ff,  $c1,  $b8,  $bc
        byte    $0e,  $96,  $00,  $3f,  $87,  $07,  $4c,  $f2,  $01,  $7f,  $e1,  $fc,  $0d,  $83,  $e4,  $87
        byte    $bf,  $38,  $48,  $60,  $b4,  $fe,  $00,  $7f,  $38,  $1a,  $0e,  $fc,  $8a,  $c0,  $40,  $f2
        byte    $81,  $fb,  $00,  $62,  $18,  $38,  $c0,  $f9,  $97,  $01,  $c7,  $27,  $00,  $e0,  $87,  $07
        byte    $40,  $f0,  $00,  $66,  $d0,  $1c,  $38,  $7e,  $07,  $03,  $1c,  $1e,  $6f,  $02,  $f8,  $85
        byte    $c7,  $e1,  $03,  $6e,  $60,  $00,  $e7,  $e0,  $7f,  $00,  $02,  $7f,  $0a,  $00,  $01,  $b0
        byte    $47,  $e0,  $53,  $7c,  $e0,  $3c,  $18,  $04,  $2c,  $00,  $38,  $80,  $e0,  $f1,  $e7,  $10

        byte    $e0,  $03,  $fe,  $35,  $83,  $df,  $c3,  $08,  $bf,  $f4,  $03,  $9c,  $c7,  $88,  $e7,  $2b
        byte    $26,  $1e,  $2f,  $8c,  $02,  $df,  $e8,  $01,  $60,  $2b,  $00,  $7c,  $eb,  $00,  $70,  $07
        byte    $bc,  $15,  $00,  $bf,  $f5,  $01,  $b0,  $4d,  $fc,  $b7,  $d5,  $e8,  $07,  $be,  $87,  $64
        byte    $4d,  $1d,  $f8,  $0f,  $80,  $ff,  $cd,  $c1,  $ff,  $02

c_28    byte    $4c,  $02,  $b2,  $01,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $5e,  $fc
        byte    $ff,  $99,  $7e,  $02,  $7e,  $80,  $00,  $02,  $07,  $3f,  $f0,  $d7,  $c3,  $0f,  $fe,  $f5
        byte    $f1,  $c3,  $7f,  $fd,  $fd,  $fc,  $df,  $bb,  $f9,  $87,  $c0,  $77,  $09,  $40,  $40,  $0b
        byte    $df,  $43,  $0b,  $d0,  $40,  $0b,  $e0,  $03,  $ec,  $e0,  $01,  $ff,  $03,  $f7,  $c0,  $ff
        byte    $f8,  $5f,  $c0,  $bf,  $7f,  $f0,  $38,  $4e,  $c0,  $0e,  $8e,  $00,  $fe,  $e9,  $e3,  $7f
        byte    $0d,  $f8,  $07,  $ee,  $a0,  $08,  $f0,  $03,  $f0,  $f3,  $bf,  $0e,  $8a,  $ff,  $f5,  $f7
        byte    $19,  $68,  $f9,  $ff,  $ff,  $07,  $fe,  $f7,  $1f,  $fe,  $57,  $f1,  $08,  $d8,  $db,  $7f
        byte    $fd,  $5b,  $e7,  $65,  $02,  $5f,  $40,  $c1,  $df,  $c1,  $ff,  $02,  $fe,  $e1,  $03,  $48
        byte    $0d,  $f8,  $0f,  $57,  $c0,  $00,  $7e,  $fc,  $0b,  $f0,  $df,  $ff,  $6f,  $60,  $09,  $71
        byte    $03,  $00,  $96,  $38,  $38,  $f1,  $e3,  $f8,  $5f,  $80,  $18,  $1e,  $70,  $89,  $83,  $07
        byte    $7c,  $f3,  $bf,  $47,  $c0,  $21,  $01,  $97,  $3c,  $c0,  $7f,  $30,  $2f,  $b8,  $97,  $41
        byte    $f1,  $72,  $f8,  $1f,  $38,  $c9,  $ef,  $e0,  $87,  $33,  $04,  $3f,  $8e,  $1f,  $00,  $8c
        byte    $e4,  $c1,  $53,  $04,  $06,  $be,  $03,  $c7,  $3f,  $c2,  $e1,  $f1,  $01,  $7c,  $e1,  $71
        byte    $f8,  $5f,  $70,  $0e,  $7e,  $0c,  $03,  $f0,  $07,  $60,  $23,  $a0,  $e0,  $50,  $3c,  $06
        byte    $00,  $ff,  $ab,  $80,  $af,  $e0,  $f3,  $00,  $04,  $00,  $3c,  $11,  $e0,  $98,  $bf,  $87
        byte    $21,  $80,  $ff,  $fa,  $6f,  $7c,  $bc,  $f8,  $ca,  $a7,  $c0,  $33,  $f2,  $28,  $c1,  $17

        byte    $f0,  $46,  $0f,  $00,  $5b,  $01,  $e0,  $5b,  $07,  $c0,  $fb,  $d6,  $00,  $fc,  $d6,  $07
        byte    $c0,  $36,  $f1,  $df,  $f2,  $bf,  $0a,  $3f,  $f8,  $d3,  $df,  $81,  $ff,  $00,  $f8,  $df
        byte    $bc,  $17

c_29    byte    $4c,  $02,  $e2,  $03,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $5e,  $fc
        byte    $ff,  $99,  $7e,  $02,  $7e,  $80,  $00,  $02,  $07,  $3f,  $f0,  $d7,  $c3,  $0f,  $fe,  $f5
        byte    $f1,  $c3,  $7f,  $fd,  $fc,  $f8,  $5f,  $7f,  $3f,  $ff,  $f7,  $6e,  $1f,  $01,  $2d,  $7e
        byte    $03,  $2d,  $c0,  $16,  $3c,  $80,  $0f,  $b0,  $03,  $e0,  $c7,  $bf,  $fd,  $fe,  $7f,  $00
        byte    $06,  $8e,  $00,  $fc,  $10,  $f8,  $69,  $3e,  $f8,  $87,  $3f,  $ff,  $ff,  $e3,  $e7,  $f8
        byte    $9b,  $1f,  $bc,  $81,  $23,  $c0,  $ef,  $a7,  $7d,  $04,  $7c,  $fe,  $fe,  $96,  $ff,  $2f
        byte    $e0,  $6f,  $e1,  $ff,  $67,  $f2,  $f3,  $ff,  $05,  $4c,  $ff,  $ff,  $ff,  $ff,  $ff,  $ff
        byte    $3f,  $80,  $d1,  $f8,  $ff,  $02,  $34,  $f0,  $e1,  $7f,  $00,  $27,  $ff,  $0b,  $fc,  $87
        byte    $8f,  $63,  $f9,  $db,  $df,  $c1,  $09,  $e0,  $ff,  $ff,  $ff,  $05,  $06,  $e0,  $c7,  $b0
        byte    $7c,  $e0,  $86,  $e0,  $e7,  $f0,  $03,  $00,  $96,  $fc,  $18,  $16,  $70,  $2f,  $9c,  $a2
        byte    $fd,  $70,  $fc,  $3f,  $9e,  $21,  $e0,  $f0,  $1d,  $38,  $7e,  $70,  $03,  $1c,  $1e,  $ff
        byte    $0b,  $8f,  $c3,  $cb,  $a0,  $00,  $93,  $80,  $73,  $f0,  $bf,  $c0,  $1f,  $80,  $00,  $18
        byte    $24,  $8f,  $80,  $c7,  $00,  $e0,  $7f,  $15,  $00,  $fc,  $71,  $90,  $c0,  $29,  $00,  $3e
        byte    $e0,  $df,  $06,  $be,  $87,  $21,  $68,  $5e,  $ff,  $0d,  $8f,  $17,  $df,  $07,  $1e,  $cf
        byte    $cb,  $e3,  $05,  $5e,  $c0,  $7b,  $3d,  $00,  $6c,  $05,  $80,  $6f,  $1d,  $00,  $ee,  $80
        byte    $b7,  $02,  $e0,  $b7,  $3e,  $00,  $b6,  $09,  $ff,  $d6,  $ff,  $55,  $f8,  $01,  $ef,  $03

        byte    $ff,  $ef,  $c0,  $7f,  $00,  $fc,  $6f,  $0e,  $fe,  $17

c_30    byte    $ca,  $01,  $0c,  $02,  $08,  $e0,  $df,  $7f,  $c2,  $08,  $0e,  $72,  $00,  $2f,  $e4,  $27
        byte    $07,  $fe,  $5c,  $19,  $0e,  $0b,  $c8,  $05,  $f0,  $73,  $09,  $e0,  $39,  $3c,  $f4,  $02
        byte    $9f,  $c3,  $47,  $2e,  $f8,  $39,  $fc,  $e5,  $e2,  $9f,  $23,  $53,  $0c,  $00,  $02,  $f2
        byte    $0e,  $08,  $59,  $03,  $60,  $5e,  $c0,  $79,  $81,  $e7,  $f3,  $70,  $03,  $3e,  $80,  $18
        byte    $e0,  $7d,  $e4,  $81,  $9f,  $cf,  $4f,  $1f,  $fc,  $f9,  $fb,  $fa,  $cb,  $c3,  $3f,  $7f
        byte    $df,  $0c,  $fe,  $e1,  $03,  $48,  $98,  $7f,  $cf,  $a8,  $fd,  $ff,  $57,  $fd,  $f7,  $ff
        byte    $ff,  $17,  $60,  $00,  $00,  $60,  $00,  $48,  $60,  $20,  $af,  $03,  $e0,  $7d,  $f2,  $f7
        byte    $df,  $0f,  $00,  $06,  $00,  $c0,  $00,  $1c,  $80,  $eb,  $c3,  $21,  $7f,  $5f,  $38,  $79
        byte    $70,  $e4,  $c3,  $d3,  $07,  $0f,  $8e,  $3c,  $70,  $78,  $e4,  $81,  $c7,  $21,  $0f,  $38
        byte    $07,  $79,  $80,  $3b,  $00,  $08,  $00,  $06,  $00,  $c0,  $02,  $80,  $1b,  $00,  $9c,  $2b
        byte    $85,  $80,  $dc,  $2b,  $81,  $f7,  $f2,  $00,  $00,  $00,  $7c,  $00,  $3e,  $fc,  $03,  $f6
        byte    $91,  $03,  $5f,  $2e,  $3e,  $39,  $78,  $e4,  $82,  $97,  $c3,  $03,  $c0,  $18,  $02,  $c0
        byte    $c7,  $70,  $00,  $3c,  $8e,  $00,  $f8,  $39,  $7c,  $cc,  $04,  $e0,  $3f,  $47,  $c4,  $04
        byte    $7e,  $f0,  $87,  $48,  $f1,  $d0,  $bf,  $7f,  $e0,  $b9,  $0e,  $6c,  $02

c_31    byte    $42,  $02,  $22,  $00,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $ba,  $f8
        byte    $fb,  $cd,  $68,  $4f,  $40,  $1f,  $e0,  $d0,  $41,  $1f,  $78,  $d7,  $43,  $1f,  $7c,  $d7
        byte    $4f,  $1f,  $7e,  $d7,  $5f,  $1f,  $7f,  $57,  $40,  $9f,  $7f,  $37,  $ea,  $6f,  $d6,  $cf
        byte    $f8,  $19,  $02,  $34,  $30,  $1f,  $02,  $76,  $b0,  $59,  $4c,  $bb,  $c0,  $bb,  $83,  $cc
        byte    $a0,  $e7,  $a1,  $11,  $e0,  $df,  $03,  $ef,  $a3,  $ef,  $af,  $00,  $bf,  $ff,  $e9,  $f9
        byte    $f9,  $77,  $f1,  $f7,  $7f,  $7d,  $fe,  $7d,  $7f,  $fe,  $03,  $fd,  $4c,  $0f,  $ff,  $af
        byte    $df,  $ef,  $f8,  $0f,  $f6,  $5b,  $89,  $6e,  $fd,  $df,  $ef,  $f7,  $fb,  $fd,  $7e,  $cf
        byte    $71,  $bf,  $07,  $58,  $40,  $01,  $3f,  $80,  $7e,  $21,  $00,  $bf,  $ff,  $e9,  $c2,  $e8
        byte    $f7,  $3b,  $9e,  $fd,  $07,  $7a,  $70,  $04,  $14,  $1c,  $74,  $80,  $1f,  $02,  $bd,  $cc
        byte    $a0,  $ff,  $ed,  $ff,  $fb,  $fd,  $0c,  $03,  $60,  $89,  $00,  $18,  $01,  $80,  $33,  $1c
        byte    $c0,  $f5,  $01,  $f6,  $7f,  $3d,  $38,  $ff,  $2e,  $8e,  $1e,  $38,  $01,  $fd,  $6f,  $c7
        byte    $40,  $f7,  $81,  $a3,  $df,  $e3,  $d1,  $ef,  $c2,  $e3,  $d0,  $ef,  $82,  $73,  $d0,  $ef
        byte    $02,  $ef,  $64,  $81,  $19,  $d8,  $08,  $e8,  $64,  $00,  $17,  $7a,  $d5,  $69,  $df,  $01
        byte    $c0,  $0a,  $f8,  $be,  $87,  $42,  $00,  $5c,  $c4,  $bf,  $e3,  $04,  $8f,  $2e,  $9e,  $ee
        byte    $20,  $51,  $5c,  $79,  $e8,  $c2,  $fb,  $56,  $00,  $66,  $08,  $08,  $00,  $df,  $75,  $00
        byte    $3c,  $9f,  $dd,  $c0,  $cf,  $fa,  $00,  $98,  $8d,  $f8,  $cf,  $a6,  $8a,  $7e,  $c0,  $3f

        byte    $f0,  $bf,  $12,  $0e,  $2e,  $01,  $e0,  $fd,  $4c,  $b7,  $05

c_32    byte    $4c,  $02,  $72,  $01,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $5e,  $fc
        byte    $ff,  $99,  $7e,  $06,  $7e,  $80,  $00,  $02,  $07,  $3f,  $f0,  $d7,  $c3,  $0f,  $fe,  $4d
        byte    $7e,  $f8,  $9f,  $03,  $ff,  $21,  $ff,  $af,  $f0,  $f7,  $26,  $83,  $00,  $f0,  $85,  $81
        byte    $ff,  $19,  $00,  $02,  $f0,  $d1,  $8c,  $06,  $0a,  $f8,  $8f,  $80,  $17,  $b0,  $83,  $0e
        byte    $80,  $87,  $01,  $f8,  $c7,  $ff,  $f7,  $e0,  $3f,  $04,  $e8,  $a3,  $01,  $5f,  $fe,  $0d
        byte    $fc,  $1f,  $c0,  $f8,  $f8,  $f1,  $1f,  $7e,  $f8,  $ff,  $ff,  $7f,  $46,  $fc,  $fe,  $fc
        byte    $87,  $1f,  $ff,  $af,  $f9,  $ff,  $df,  $7f,  $c8,  $ff,  $f1,  $b7,  $fd,  $ff,  $ff,  $39
        byte    $7f,  $f1,  $03,  $f8,  $80,  $b7,  $bf,  $7f,  $c0,  $06,  $8a,  $b7,  $08,  $1f,  $00,  $3e
        byte    $7e,  $ff,  $af,  $80,  $ff,  $03,  $00,  $23,  $59,  $42,  $c0,  $43,  $00,  $e7,  $ff,  $05
        byte    $f8,  $0f,  $81,  $03,  $08,  $e0,  $fc,  $1f,  $98,  $47,  $b0,  $ff,  $e0,  $7f,  $00,  $7a
        byte    $f8,  $c1,  $bd,  $00,  $fe,  $c7,  $00,  $c0,  $c7,  $c1,  $50,  $04,  $c0,  $3e,  $0e,  $ff
        byte    $ff,  $01,  $7f,  $00,  $04,  $1c,  $e0,  $b4,  $3f,  $8e,  $df,  $01,  $80,  $e0,  $c1,  $d3
        byte    $02,  $fe,  $0e,  $1c,  $7f,  $0b,  $87,  $47,  $23,  $00,  $30,  $83,  $17,  $1e,  $87,  $af
        byte    $1d,  $c0,  $79,  $f8,  $9b,  $00,  $b8,  $03,  $80,  $02,  $12,  $0e,  $47,  $f3,  $18,  $00
        byte    $fc,  $62,  $78,  $b6,  $a7,  $01,  $f8,  $3a,  $68,  $00,  $80,  $7f,  $80,  $e3,  $18,  $9e
        byte    $24,  $80,  $ff,  $f0,  $7f,  $79,  $bc,  $f8,  $0a,  $ff,  $f8,  $0b,  $3e,  $2f,  $8f,  $c2

        byte    $03,  $fc,  $02,  $de,  $bb,  $00,  $5c,  $05,  $80,  $7f,  $1d,  $00,  $ef,  $5b,  $01,  $f0
        byte    $5b,  $1f,  $00,  $db,  $c4,  $7f,  $5b,  $8d,  $7e,  $f0,  $a7,  $6b,  $ea,  $c0,  $7f,  $00
        byte    $fc,  $6f,  $de,  $0b

c_33    byte    $46,  $01,  $22,  $00,  $08,  $e0,  $df,  $7f,  $c4,  $10,  $0e,  $e2,  $00,  $4f,  $e4,  $27
        byte    $0e,  $fc,  $78,  $31,  $1a,  $0b,  $88,  $07,  $b0,  $a0,  $bf,  $84,  $83,  $3c,  $c4,  $05
        byte    $9f,  $07,  $4c,  $23,  $fc,  $71,  $f0,  $01,  $38,  $18,  $d7,  $3f,  $40,  $07,  $0d,  $f8
        byte    $03,  $a8,  $d2,  $66,  $69,  $dc,  $34,  $4b,  $01,  $1a,  $a8,  $00,  $78,  $29,  $e0,  $8e
        byte    $13,  $96,  $00,  $ff,  $b6,  $34,  $3e,  $f0,  $0e,  $e0,  $7d,  $f4,  $f1,  $df,  $11,  $7e
        byte    $fc,  $09,  $f0,  $47,  $1c,  $8c,  $83,  $3f,  $1e,  $c0,  $0d,  $f1,  $e3,  $f9,  $9b,  $1b
        byte    $97,  $7f,  $3c,  $00,  $1b,  $e2,  $c7,  $73,  $5e,  $37,  $ae,  $7f,  $e0,  $71,  $f8,  $03
        byte    $b8,  $08,  $bc,  $6d,  $7c,  $03,  $fe,  $f3,  $03,  $06,  $e0,  $0f,  $7f,  $88,  $0e,  $71
        byte    $3c,  $c4,  $8f,  $23,  $20,  $7e,  $1c,  $00,  $78,  $00,  $bc,  $8d,  $0b,  $27,  $3e,  $00
        byte    $00,  $f1,  $f3,  $82,  $11,  $50,  $17,  $78,  $1e,  $70,  $f1,  $e3,  $17,  $c8,  $0b,  $cc
        byte    $80,  $c3,  $f8,  $c0,  $0d,  $00,  $8c,  $1f,  $07,  $80,  $0f,  $ff,  $c0,  $fa,  $00,  $76
        byte    $00,  $c0,  $00,  $7f,  $70,  $f1,  $01,  $f0,  $8b,  $23,  $00,  $30,  $83,  $34,  $1c,  $e0
        byte    $00,  $88,  $c3,  $21,  $0e,  $8e,  $b8,  $00,  $e3,  $8f,  $89,  $07,  $07,  $47,  $5c,  $0c
        byte    $75,  $e0,  $f0,  $88,  $03,  $20,  $0d,  $00,  $78,  $6d,  $be,  $c4,  $05,  $17,  $25,  $08
        byte    $8c,  $3a,  $c0,  $1d,  $00,  $fc,  $72,  $16,  $b8,  $01,  $c0,  $4d,  $e2,  $44,  $11,  $00
        byte    $3c,  $0e,  $18,  $00,  $55,  $00,  $80,  $f7,  $00,  $18,  $1c,  $00,  $0f,  $00,  $01,  $2c

        byte    $81,  $1f,  $e7,  $0b,  $00,  $7c,  $00,  $fc,  $03,  $07,  $80,  $e7,  $08,  $1f,  $00,  $3e
        byte    $e2,  $c0,  $8b,  $d3,  $c2,  $00,  $70,  $01,  $e0,  $e3,  $38,  $c8,  $b2,  $23,  $ac,  $00
        byte    $f8,  $69,  $7c,  $ec,  $88,  $e0,  $3f,  $74,  $46,  $f8,  $3e,  $f0,  $47,  $19,  $e8,  $ff
        byte    $61,  $22,  $7f,  $4d,  $01,  $00

c_34    byte    $8c,  $02,  $06,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $9f,  $8f,  $ff
        byte    $ff,  $ef,  $3f,  $fc,  $ec,  $e0,  $26,  $80,  $17,  $81,  $80,  $9f,  $80,  $7f,  $0f,  $c5
        byte    $df,  $09,  $e0,  $bf,  $0f,  $c0,  $1e,  $3e,  $fc,  $ef,  $af,  $19,  $f8,  $f8,  $ff,  $e0
        byte    $df,  $7e,  $fa,  $13,  $a0,  $9f,  $fe,  $04,  $74,  $e0,  $0e,  $3a,  $40,  $03,  $1d,  $bf
        byte    $80,  $0e,  $d8,  $41,  $4f,  $00,  $fc,  $15,  $e0,  $1e,  $7e,  $02,  $ec,  $a3,  $80,  $ff
        byte    $6d,  $1a,  $a8,  $3e,  $ee,  $14,  $50,  $e0,  $ff,  $f6,  $ff,  $f3,  $73,  $13,  $70,  $03
        byte    $05,  $ff,  $6f,  $ff,  $ff,  $9b,  $00,  $ff,  $e7,  $ee,  $7f,  $07,  $85,  $3f,  $b8,  $9f
        byte    $00,  $fe,  $ef,  $e7,  $7c,  $0f,  $e5,  $01,  $ef,  $bf,  $b7,  $67,  $a0,  $04,  $00,  $3e
        byte    $fa,  $1b,  $fe,  $fe,  $6f,  $7f,  $f0,  $07,  $e0,  $e7,  $fc,  $e1,  $e0,  $ff,  $07,  $f8
        byte    $09,  $c0,  $5f,  $fe,  $1f,  $01,  $4f,  $f2,  $77,  $fe,  $87,  $f1,  $3f,  $e0,  $0f,  $a7
        byte    $dc,  $f4,  $17,  $98,  $7f,  $fe,  $08,  $e0,  $04,  $dc,  $04,  $fc,  $ff,  $ff,  $3f,  $70
        byte    $01,  $ff,  $ff,  $67,  $e0,  $ff,  $27,  $00,  $f0,  $f3,  $71,  $fe,  $7f,  $0e,  $0c,  $7c
        byte    $70,  $1f,  $e0,  $6b,  $8f,  $ff,  $37,  $f0,  $38,  $3c,  $3f,  $bf,  $bd,  $f4,  $3d,  $3c
        byte    $38,  $cb,  $41,  $c2,  $91,  $04,  $e0,  $ff,  $ff,  $03,  $c0,  $87,  $a7,  $70,  $48,  $30
        byte    $52,  $38,  $38,  $7e,  $82,  $f3,  $0b,  $8f,  $86,  $23,  $81,  $f9,  $f0,  $38,  $fc,  $04
        byte    $ee,  $17,  $0f,  $0d,  $c6,  $ff,  $c0,  $1d,  $00,  $84,  $b3,  $46,  $12,  $50,  $0c,  $00

        byte    $fe,  $7f,  $0b,  $78,  $7c,  $2a,  $00,  $07,  $00,  $0b,  $78,  $0f,  $82,  $01,  $ff,  $14
        byte    $e0,  $1b,  $10,  $0f,  $70,  $f0,  $f8,  $78,  $8a,  $ff,  $cf,  $e7,  $f3,  $28,  $7e,  $26
        byte    $bc,  $ea,  $01,  $a0,  $83,  $21,  $00,  $fc,  $5f,  $c0,  $7b,  $ef,  $02,  $e0,  $77,  $1f
        byte    $80,  $7b,  $f2,  $df,  $eb,  $4f,  $7e,  $e0,  $fb,  $c0,  $7f,  $b3,  $03,  $ff,  $01,  $f8
        byte    $cf,  $e9,  $cf,  $04

c_35    byte    $8e,  $01,  $e2,  $02,  $08,  $e0,  $df,  $7f,  $c8,  $20,  $0e,  $c2,  $01,  $8f,  $08,  $c0
        byte    $40,  $38,  $fc,  $09,  $d3,  $67,  $0c,  $25,  $00,  $b0,  $9f,  $70,  $00,  $f3,  $82,  $f7
        byte    $51,  $30,  $9c,  $07,  $fc,  $15,  $c1,  $87,  $f3,  $c1,  $5f,  $40,  $c5,  $70,  $fe,  $fc
        byte    $03,  $0c,  $c2,  $bf,  $b6,  $7f,  $e0,  $15,  $c2,  $a7,  $00,  $ef,  $a1,  $63,  $4e,  $fc
        byte    $93,  $01,  $06,  $f7,  $1f,  $1d,  $70,  $4b,  $ff,  $80,  $2b,  $00,  $0f,  $5f,  $61,  $12
        byte    $f0,  $e2,  $fe,  $e1,  $c7,  $58,  $39,  $ba,  $04,  $fc,  $9d,  $f1,  $00,  $04,  $b9,  $19
        byte    $de,  $1f,  $7e,  $38,  $69,  $fc,  $9f,  $f2,  $1f,  $2e,  $61,  $78,  $fc,  $e0,  $7e,  $03
        byte    $9f,  $c0,  $1f,  $dc,  $40,  $e0,  $f5,  $c2,  $ad,  $04,  $1c,  $1e,  $78,  $33,  $ff,  $00
        byte    $93,  $87,  $ab,  $10,  $7e,  $1b,  $80,  $4d,  $41,  $c3,  $e7,  $08,  $ff,  $0c,  $80,  $00
        byte    $fe,  $00,  $ba,  $03,  $06,  $00,  $80,  $1f,  $80,  $e9,  $e1,  $71,  $84,  $4f,  $0f,  $00
        byte    $0e,  $00,  $7f,  $27,  $e2,  $87,  $0f,  $9f,  $0f,  $dc,  $d4,  $f4,  $00,  $c0,  $6d,  $ed
        byte    $0f,  $e0,  $6e,  $ba,  $75,  $02,  $ce,  $86,  $1f,  $17,  $3e,  $3c,  $00,  $03,  $67,  $da
        byte    $a7,  $0b,  $3f,  $bf,  $85,  $03,  $00,  $1c,  $9e,  $f0,  $0f,  $c7,  $00,  $00,  $86,  $27
        byte    $e1,  $39,  $00,  $38,  $e0,  $9f,  $ff,  $8a,  $50,  $1b,  $f1,  $87,  $bf,  $e8,  $23,  $7c
        byte    $a4,  $ea,  $f8,  $53,  $1f,  $98,  $06,  $9f,  $47,  $e8,  $61,  $00,  $e0,  $d7,  $02,  $06
        byte    $00,  $f0,  $f7,  $51,  $77,  $c2,  $03,  $77,  $20,  $10,  $fc,  $86,  $7c,  $c0,  $0d,  $00

        byte    $86,  $1f,  $3e,  $94,  $00,  $e0,  $7c,  $b2,  $3c,  $07,  $00,  $dc,  $83,  $c3,  $32,  $1e
        byte    $00,  $02,  $80,  $67,  $80,  $7b,  $38,  $1f,  $41,  $f0,  $09,  $c0,  $1f,  $02,  $4f,  $10
        byte    $3e,  $00,  $f0,  $85,  $80,  $97,  $15,  $20,  $8c,  $36,  $e0,  $c3,  $39,  $58,  $1d,  $fc
        byte    $68,  $d9,  $3a,  $21,  $fc,  $07,  $0d,  $12,  $13,  $be,  $8f,  $c6,  $05,  $fd,  $fb,  $2f
        byte    $9a,  $38,  $5c,  $48

c_36    byte    $8c,  $02,  $86,  $02,  $88,  $fe,  $c3,  $cc,  $d9,  $df,  $03,  $7e,  $33,  $18,  $3f,  $0f
        byte    $ff,  $cf,  $f0,  $3d,  $bc,  $f0,  $93,  $01,  $fe,  $0e,  $3e,  $c0,  $13,  $b6,  $80,  $0f
        byte    $fc,  $7b,  $58,  $80,  $3f,  $f8,  $ef,  $63,  $01,  $f7,  $57,  $e0,  $ff,  $09,  $de,  $c7
        byte    $c3,  $ff,  $db,  $f4,  $d0,  $7f,  $e7,  $ef,  $a0,  $03,  $14,  $d0,  $53,  $2f,  $cf,  $c0
        byte    $4f,  $80,  $7b,  $71,  $f0,  $13,  $70,  $3f,  $f5,  $b7,  $00,  $df,  $c7,  $f7,  $70,  $13
        byte    $fe,  $09,  $9e,  $c7,  $4f,  $fc,  $0d,  $14,  $f8,  $38,  $fc,  $b4,  $2f,  $e0,  $e3,  $f1
        byte    $f1,  $f9,  $03,  $68,  $f8,  $e1,  $38,  $f8,  $e3,  $f9,  $f9,  $06,  $3e,  $fc,  $ff,  $c0
        byte    $09,  $f8,  $df,  $1f,  $ff,  $07,  $a0,  $f9,  $07,  $df,  $ca,  $6f,  $7e,  $06,  $f0,  $ff
        byte    $ba,  $8f,  $07,  $58,  $40,  $09,  $df,  $c1,  $37,  $f0,  $ff,  $04,  $f8,  $fd,  $7f,  $00
        byte    $2d,  $39,  $28,  $7f,  $04,  $7e,  $c9,  $c3,  $07,  $fc,  $f9,  $14,  $1f,  $ff,  $2f,  $1c
        byte    $ff,  $ff,  $05,  $27,  $f9,  $f9,  $7f,  $81,  $4b,  $fe,  $fe,  $ff,  $e9,  $a6,  $bf,  $80
        byte    $ff,  $13,  $a6,  $00,  $c0,  $e9,  $7e,  $00,  $06,  $00,  $a6,  $ff,  $ff,  $ff,  $ff,  $39
        byte    $c8,  $ff,  $2f,  $0e,  $f9,  $27,  $70,  $8b,  $c7,  $f7,  $73,  $f8,  $7f,  $1c,  $2f,  $f9
        byte    $f8,  $1f,  $ce,  $4b,  $1e,  $3e,  $bc,  $05,  $2e,  $1b,  $78,  $f8,  $e1,  $fc,  $2c,  $e0
        byte    $e3,  $59,  $c0,  $73,  $fa,  $38,  $04,  $00,  $ce,  $cf,  $0f,  $7c,  $1e,  $06,  $00,  $26
        byte    $c0,  $cf,  $c7,  $e3,  $f0,  $f3,  $73,  $00,  $3e,  $2d,  $c0,  $e5,  $84,  $01,  $7c,  $08

        byte    $04,  $cf,  $e1,  $0b,  $78,  $06,  $00,  $c3,  $fb,  $00,  $b6,  $80,  $87,  $07,  $c7,  $09
        byte    $0e,  $00,  $16,  $f0,  $1e,  $e0,  $fc,  $57,  $e1,  $37,  $f0,  $93,  $47,  $c5,  $63,  $e0
        byte    $2f,  $3e,  $9f,  $47,  $01,  $3e,  $f1,  $55,  $0f,  $00,  $01,  $0d,  $01,  $e0,  $bf,  $03
        byte    $e0,  $bd,  $77,  $01,  $f0,  $bb,  $0f,  $80,  $3d,  $f9,  $ef,  $f5,  $27,  $3f,  $f0,  $7d
        byte    $e0,  $bf,  $d9,  $81,  $ff,  $00,  $fc,  $e7,  $f4,  $67,  $02

c_37    byte    $81,  $01,  $12,  $00,  $08,  $c0,  $87,  $ff,  $20,  $03,  $71,  $e0,  $c0,  $3f,  $f0,  $10
        byte    $01,  $f8,  $31,  $e0,  $1f,  $7f,  $f0,  $00,  $fc,  $0b,  $f6,  $1f,  $23,  $00,  $01,  $51
        byte    $05,  $07,  $30,  $5e,  $ff,  $e0,  $fd,  $25,  $08,  $c0,  $83,  $7f,  $f8,  $7e,  $42,  $09
        byte    $2f,  $08,  $fc,  $a1,  $a4,  $18,  $05,  $ff,  $1c,  $f8,  $87,  $97,  $84,  $ff,  $1c,  $82
        byte    $4b,  $27,  $04,  $81,  $39,  $06,  $ef,  $1f,  $70,  $8e,  $91,  $05,  $91,  $23,  $60,  $07
        byte    $7e,  $83,  $cb,  $11,  $b8,  $83,  $b6,  $ea,  $09,  $0c,  $38,  $87,  $3c,  $fc,  $f3,  $0f
        byte    $0c,  $3c,  $8f,  $3c,  $62,  $48,  $02,  $3e,  $8e,  $14,  $fd,  $e7,  $00,  $1f,  $4f,  $8e
        byte    $fe,  $01,  $26,  $02,  $a7,  $bf,  $a2,  $fd,  $e1,  $0f,  $ae,  $c1,  $c9,  $f0,  $83,  $0b
        byte    $6c,  $5a,  $1f,  $fc,  $83,  $1b,  $10,  $40,  $f0,  $00,  $72,  $00,  $1f,  $19,  $ff,  $4d
        byte    $72,  $08,  $6c,  $e6,  $15,  $01,  $67,  $7e,  $68,  $77,  $85,  $07,  $ef,  $0f,  $60,  $e5
        byte    $c1,  $fb,  $01,  $10,  $7c,  $6c,  $00,  $78,  $64,  $1a,  $db,  $4a,  $78,  $0e,  $0f,  $1e
        byte    $40,  $2d,  $a3,  $47,  $5f,  $6b,  $2b,  $c1,  $17,  $1b,  $7c,  $71,  $c5,  $06,  $57,  $3d
        byte    $c0,  $51,  $3f,  $76,  $90,  $6f,  $f8,  $59,  $e4,  $1b,  $7c,  $b1,  $9b,  $46,  $5f,  $ec
        byte    $e7,  $79,  $c0,  $03,  $80,  $23,  $b8,  $e9,  $43,  $82,  $b3,  $6a,  $50,  $39,  $81,  $f3
        byte    $73,  $0b,  $1c,  $01,  $c5,  $80,  $af,  $6f,  $3f,  $03,  $c5,  $00,  $df,  $04,  $3f,  $9e
        byte    $62,  $01,  $e7,  $80,  $1f,  $07,  $87,  $72,  $a6,  $87,  $cf,  $c3,  $43,  $39,  $9b,  $c2

        byte    $e7,  $e0,  $00,  $60,  $44,  $db,  $81,  $77,  $90,  $1e,  $8e,  $59,  $fc,  $00,  $0f,  $07
        byte    $f8,  $74,  $f7,  $01,  $37,  $00,  $18,  $5c,  $29,  $9d,  $01,  $16,  $00,  $1c,  $cf,  $a1
        byte    $51,  $01,  $28,  $23,  $78,  $0f,  $00,  $01,  $c0,  $f3,  $b0,  $aa,  $8f,  $54,  $f0,  $45
        byte    $0e,  $60,  $b0,  $71,  $0c,  $84,  $16,  $45,  $60,  $b1,  $96,  $07,  $3e,  $38,  $07,  $e9
        byte    $06,  $1e,  $1a,  $fc,  $d0,  $7c,  $a4,  $13,  $84,  $ff,  $40,  $13,  $05,  $e0,  $07,  $be
        byte    $0f,  $fc,  $c1,  $1f,  $bd,  $67,  $88,  $5d,  $c4,  $0c,  $00

c_38    byte    $4e,  $01,  $62,  $01,  $08,  $40,  $b8,  $ff,  $10,  $83,  $70,  $00,  $dc,  $3f,  $f0,  $88
        byte    $fc,  $80,  $f7,  $87,  $3f,  $3c,  $ff,  $f0,  $fd,  $64,  $24,  $c0,  $3f,  $7e,  $1f,  $fe
        byte    $01,  $e6,  $e9,  $9f,  $bf,  $87,  $82,  $42,  $f0,  $ef,  $c0,  $3f,  $f8,  $78,  $52,  $f0
        byte    $6f,  $b0,  $88,  $70,  $fc,  $f9,  $f7,  $2f,  $b0,  $88,  $f0,  $05,  $47,  $11,  $4e,  $30
        byte    $a5,  $84,  $2b,  $c0,  $7b,  $08,  $13,  $74,  $60,  $c0,  $71,  $38,  $13,  $02,  $76,  $50
        byte    $c3,  $44,  $c0,  $1d,  $cc,  $33,  $31,  $87,  $70,  $27,  $e2,  $01,  $a0,  $c1,  $09,  $71
        byte    $00,  $98,  $70,  $00,  $f8,  $78,  $00,  $bc,  $e2,  $1f,  $70,  $15,  $70,  $00,  $1c,  $18
        byte    $fe,  $83,  $00,  $fd,  $e1,  $07,  $07,  $e0,  $15,  $ff,  $d9,  $f0,  $0f,  $c7,  $40,  $3f
        byte    $d9,  $84,  $3b,  $00,  $7e,  $00,  $1e,  $f8,  $03,  $7f,  $14,  $7e,  $38,  $cf,  $84,  $1b
        byte    $4d,  $33,  $f1,  $fa,  $03,  $3c,  $6c,  $b8,  $7e,  $00,  $2e,  $1b,  $ae,  $8f,  $2c,  $97
        byte    $08,  $e1,  $8a,  $2e,  $c2,  $3b,  $62,  $ca,  $62,  $00,  $c0,  $6b,  $33,  $3e,  $f0,  $57
        byte    $03,  $10,  $d0,  $56,  $bc,  $06,  $da,  $9a,  $d7,  $43,  $5b,  $e1,  $b6,  $71,  $89,  $ff
        byte    $70,  $db,  $0e,  $b7,  $ed,  $70,  $db,  $f6,  $0f,  $4e,  $c0,  $21,  $7e,  $f2,  $e0,  $0f
        byte    $ce,  $40,  $1f,  $f2,  $c2,  $73,  $d0,  $06,  $f8,  $70,  $e1,  $70,  $58,  $00,  $b8,  $3f
        byte    $ff,  $f8,  $e1,  $e0,  $00,  $90,  $49,  $01,  $f8,  $f1,  $84,  $93,  $49,  $b8,  $38,  $d2
        byte    $09,  $c4,  $87,  $7f,  $f8,  $3c,  $62,  $49,  $c4,  $43,  $38,  $1c,  $ee,  $58,  $c0,  $81

        byte    $7f,  $f0,  $0e,  $fe,  $58,  $c0,  $c0,  $1a,  $0e,  $04,  $0a,  $5f,  $e0,  $01,  $e0,  $2d
        byte    $98,  $5f,  $00,  $80,  $7f,  $c0,  $69,  $f8,  $03,  $b8,  $48,  $b0,  $e0,  $fd,  $84,  $01
        byte    $20,  $58,  $f8,  $6d,  $44,  $c0,  $23,  $08,  $3c,  $10,  $e2,  $e5,  $13,  $75,  $08,  $f8
        byte    $82,  $f0,  $50,  $a6,  $80,  $21,  $00,  $38,  $e8,  $23,  $78,  $01,  $f0,  $93,  $f1,  $91
        byte    $ec,  $30,  $e1,  $f8,  $af,  $b2,  $1b,  $f8,  $3e,  $f0,  $87,  $77,  $c3,  $29,  $e1,  $65
        byte    $90,  $16

c_39    byte    $81,  $01,  $62,  $03,  $08,  $00,  $bf,  $9f,  $20,  $03,  $f1,  $c0,  $df,  $07,  $f8,  $10
        byte    $01,  $f8,  $e1,  $ef,  $01,  $7f,  $f0,  $00,  $fc,  $fb,  $77,  $e0,  $3f,  $78,  $01,  $c1
        byte    $19,  $f4,  $0f,  $38,  $84,  $30,  $fc,  $1b,  $f6,  $0f,  $3c,  $d9,  $f0,  $04,  $fb,  $4f
        byte    $d1,  $47,  $70,  $c0,  $fd,  $a7,  $e8,  $2f,  $38,  $f0,  $fe,  $f9,  $47,  $67,  $3f,  $38
        byte    $f8,  $a1,  $01,  $10,  $20,  $3c,  $78,  $3f,  $39,  $08,  $00,  $1c,  $1c,  $fe,  $c4,  $00
        byte    $1a,  $08,  $be,  $86,  $02,  $1c,  $00,  $8c,  $a3,  $86,  $02,  $3c,  $d4,  $57,  $63,  $70
        byte    $1c,  $82,  $f7,  $5f,  $03,  $78,  $1e,  $00,  $4a,  $ac,  $01,  $3e,  $0e,  $00,  $1e,  $6a
        byte    $f4,  $0f,  $1f,  $0f,  $80,  $16,  $6b,  $84,  $13,  $7c,  $33,  $0d,  $c0,  $03,  $60,  $a0
        byte    $41,  $7f,  $f8,  $c1,  $d5,  $14,  $1c,  $e0,  $d9,  $82,  $9b,  $11,  $a0,  $0f,  $fe,  $c1
        byte    $77,  $1d,  $dc,  $c4,  $71,  $e4,  $1e,  $bc,  $1f,  $f8,  $99,  $07,  $ef,  $27,  $b0,  $c2
        byte    $82,  $f7,  $b1,  $55,  $6d,  $1b,  $7b,  $00,  $d8,  $fa,  $c1,  $ad,  $00,  $18,  $2c,  $78
        byte    $7c,  $a5,  $5e,  $0c,  $e0,  $88,  $5a,  $c3,  $13,  $90,  $48,  $af,  $c1,  $2d,  $34,  $6a
        byte    $f4,  $0b,  $cd,  $fa,  $32,  $9f,  $cb,  $3a,  $0a,  $7e,  $20,  $01,  $c1,  $27,  $91,  $6e
        byte    $f0,  $c0,  $0d,  $a4,  $1b,  $3c,  $f0,  $74,  $77,  $f6,  $0f,  $2e,  $dd,  $77,  $46,  $01
        byte    $b7,  $c3,  $8c,  $c1,  $a7,  $6b,  $3c,  $3e,  $fe,  $70,  $0e,  $30,  $20,  $38,  $38,  $fc
        byte    $70,  $6e,  $8c,  $11,  $3f,  $9e,  $e0,  $fa,  $0b,  $1f,  $c7,  $0f,  $fd,  $0d,  $03,  $9f

        byte    $87,  $83,  $fe,  $73,  $80,  $cf,  $c1,  $81,  $c0,  $0a,  $82,  $03,  $ef,  $c0,  $80,  $c3
        byte    $65,  $d6,  $0d,  $c7,  $73,  $77,  $e3,  $35,  $03,  $98,  $7f,  $70,  $c7,  $00,  $9e,  $eb
        byte    $aa,  $6b,  $63,  $03,  $ff,  $f1,  $7a,  $91,  $c1,  $03,  $12,  $d8,  $04,  $81,  $15,  $15
        byte    $18,  $00,  $fc,  $81,  $5d,  $1d,  $44,  $e2,  $4f,  $5f,  $b7,  $58,  $6a,  $1f,  $3b,  $08
        byte    $5c,  $40,  $e4,  $3e,  $b2,  $39,  $32,  $d0,  $54,  $ef,  $c0,  $ef,  $23,  $dd,  $2a,  $87
        byte    $8a,  $37,  $e2,  $e0,  $82,  $04

c_40    byte    $4c,  $02,  $1a,  $02,  $08,  $fd,  $3b,  $9e,  $4a,  $07,  $8f,  $61,  $e0,  $6b,  $ea,  $e7
        byte    $11,  $8c,  $ff,  $3f,  $02,  $e1,  $c9,  $27,  $e0,  $05,  $5f,  $00,  $04,  $10,  $38,  $f8
        byte    $fc,  $01,  $7f,  $3d,  $bc,  $f0,  $1f,  $f0,  $2f,  $9f,  $cf,  $0f,  $fc,  $17,  $9f,  $3f
        byte    $ff,  $f8,  $9f,  $e4,  $85,  $37,  $bc,  $3e,  $8a,  $17,  $fc,  $cb,  $ff,  $05,  $28,  $00
        byte    $f8,  $e8,  $df,  $43,  $f2,  $18,  $00,  $fc,  $39,  $78,  $96,  $02,  $a0,  $87,  $21,  $70
        byte    $98,  $00,  $7f,  $00,  $7c,  $06,  $5f,  $0e,  $8f,  $83,  $21,  $30,  $9c,  $80,  $e7,  $f1
        byte    $18,  $78,  $85,  $17,  $f0,  $71,  $fc,  $1f,  $9c,  $47,  $80,  $ff,  $00,  $7c,  $82,  $ff
        byte    $7f,  $fd,  $7d,  $00,  $8e,  $00,  $fe,  $0b,  $ee,  $f8,  $fd,  $f0,  $ff,  $fc,  $f9,  $07
        byte    $fe,  $03,  $18,  $1e,  $c0,  $3e,  $f8,  $03,  $3f,  $be,  $e2,  $f1,  $ff,  $0d,  $f8,  $1f
        byte    $0f,  $ff,  $03,  $fe,  $71,  $f0,  $7b,  $00,  $fe,  $37,  $c1,  $03,  $b0,  $30,  $e0,  $1f
        byte    $f0,  $cb,  $a7,  $f4,  $f0,  $c3,  $7f,  $fd,  $7c,  $02,  $c0,  $bf,  $c7,  $e7,  $00,  $f0
        byte    $23,  $e0,  $f7,  $71,  $04,  $0e,  $7e,  $7c,  $af,  $8f,  $1f,  $fe,  $eb,  $ef,  $05,  $6e
        byte    $20,  $79,  $cf,  $64,  $f1,  $00,  $f0,  $31,  $f0,  $f3,  $39,  $02,  $0f,  $3f,  $be,  $d7
        byte    $c7,  $07,  $0e,  $fc,  $eb,  $ef,  $e5,  $ff,  $04,  $8f,  $80,  $33,  $79,  $c1,  $3c,  $06
        byte    $9c,  $1f,  $2f,  $9c,  $e0,  $f1,  $e0,  $f0,  $c5,  $7f,  $e0,  $78,  $f8,  $18,  $f8,  $8e
        byte    $17,  $fe,  $7f,  $70,  $10,  $00,  $3e,  $f1,  $1f,  $c0,  $e7,  $f1,  $38,  $00,  $0c,  $e0

        byte    $3b,  $7d,  $1c,  $1f,  $78,  $07,  $06,  $f0,  $bd,  $fe,  $fc,  $03,  $7f,  $0c,  $c2,  $ff
        byte    $1f,  $03,  $82,  $8b,  $d7,  $8f,  $7f,  $c0,  $02,  $84,  $03,  $fc,  $47,  $f0,  $67,  $e2
        byte    $c3,  $ff,  $08,  $ef,  $f3,  $c0,  $7f,  $c4,  $f3,  $7f,  $3c,  $3e,  $07,  $f8,  $47,  $0f
        byte    $00,  $db,  $07,  $7c,  $07,  $bc,  $6f,  $05,  $c0,  $6f,  $7d,  $00,  $6c,  $13,  $ff,  $6d
        byte    $35,  $fa,  $81,  $ef,  $23,  $59,  $53,  $07,  $fe,  $03,  $e0,  $7f,  $f3,  $5e

c_41    byte    $8c,  $02,  $06,  $03,  $88,  $fe,  $e1,  $cf,  $9c,  $1c,  $7c,  $70,  $37,  $fb,  $f9,  $f8
        byte    $7e,  $3e,  $01,  $bf,  $9f,  $9f,  $04,  $fc,  $0f,  $f8,  $04,  $07,  $9f,  $bf,  $0f,  $e0
        byte    $df,  $83,  $4f,  $ff,  $1f,  $fc,  $e7,  $e1,  $e1,  $85,  $02,  $ff,  $e3,  $fb,  $9f,  $ff
        byte    $87,  $ef,  $e0,  $84,  $fa,  $c1,  $ff,  $e7,  $30,  $3d,  $01,  $80,  $ff,  $4f,  $00,  $0d
        byte    $bc,  $34,  $82,  $e1,  $b4,  $1c,  $00,  $fc,  $3f,  $01,  $f7,  $00,  $40,  $c0,  $08,  $c2
        byte    $3f,  $87,  $ff,  $3f,  $78,  $1e,  $2f,  $fc,  $55,  $e0,  $e3,  $f8,  $ff,  $3f,  $3c,  $df
        byte    $9f,  $ff,  $57,  $f0,  $c3,  $f9,  $1f,  $fe,  $ff,  $00,  $fe,  $c7,  $0f,  $ee,  $04,  $3f
        byte    $fe,  $57,  $e1,  $ff,  $ff,  $ff,  $ff,  $f9,  $78,  $f0,  $0b,  $7f,  $e0,  $e7,  $bf,  $f1
        byte    $ea,  $f7,  $30,  $5a,  $05,  $fe,  $07,  $fe,  $ef,  $ff,  $0f,  $07,  $e0,  $eb,  $6f,  $c1
        byte    $07,  $e0,  $ff,  $fa,  $e0,  $97,  $fe,  $6f,  $02,  $e0,  $7f,  $03,  $7f,  $78,  $00,  $fe
        byte    $db,  $1f,  $7e,  $6e,  $ff,  $0d,  $ff,  $4f,  $e7,  $1b,  $00,  $ff,  $1d,  $7c,  $e0,  $3e
        byte    $00,  $ff,  $f6,  $1f,  $bf,  $9b,  $fc,  $fd,  $07,  $ff,  $0b,  $b8,  $e9,  $85,  $ef,  $e1
        byte    $ff,  $0f,  $c0,  $cf,  $4f,  $e0,  $80,  $9d,  $70,  $13,  $ff,  $17,  $8e,  $81,  $ff,  $0f
        byte    $98,  $e7,  $c1,  $f7,  $f9,  $70,  $c2,  $f3,  $e7,  $e1,  $e3,  $3f,  $30,  $04,  $c0,  $ff
        byte    $fe,  $1f,  $1e,  $1c,  $0e,  $80,  $a7,  $f3,  $4f,  $f0,  $01,  $f0,  $3f,  $f8,  $1c,  $02
        byte    $7f,  $00,  $06,  $ce,  $3f,  $1e,  $c0,  $ff,  $3f,  $1c,  $04,  $c0,  $ff,  $7f,  $87,  $27

        byte    $08,  $f8,  $c0,  $0d,  $00,  $fe,  $df,  $ff,  $6a,  $c0,  $7f,  $3a,  $01,  $60,  $fb,  $e5
        byte    $bf,  $0e,  $af,  $26,  $7f,  $bf,  $e1,  $fb,  $1f,  $ff,  $e4,  $f1,  $93,  $1f,  $f8,  $d3
        byte    $03,  $c0,  $fe,  $c0,  $77,  $07,  $c0,  $ff,  $eb,  $43,  $00,  $fc,  $ef,  $03,  $60,  $4f
        byte    $fe,  $7b,  $fd,  $c9,  $0f,  $7e,  $1f,  $e9,  $66,  $07,  $fe,  $03,  $f0,  $9f,  $d3,  $9f
        byte    $09

c_42    byte    $4c,  $02,  $ca,  $01,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $3f,  $13,  $3f,  $2f,  $86,  $ab
        byte    $38,  $13,  $0f,  $9f,  $00,  $fb,  $47,  $e0,  $10,  $20,  $80,  $c0,  $81,  $f1,  $0f,  $f8
        byte    $eb,  $c1,  $e0,  $07,  $fe,  $e5,  $23,  $e0,  $35,  $0c,  $ff,  $c5,  $f7,  $e3,  $7f,  $c1
        byte    $fd,  $fe,  $5f,  $f0,  $c5,  $10,  $08,  $4f,  $00,  $0a,  $00,  $fe,  $bf,  $06,  $00,  $ff
        byte    $cf,  $e2,  $00,  $e0,  $e3,  $6f,  $01,  $9f,  $00,  $7f,  $8e,  $ff,  $e5,  $f0,  $83,  $7f
        byte    $12,  $1e,  $af,  $9f,  $05,  $be,  $bf,  $04,  $c7,  $ff,  $c1,  $f9,  $5f,  $fc,  $9f,  $0f
        byte    $ff,  $8b,  $9f,  $ff,  $7f,  $c0,  $01,  $08,  $7e,  $fe,  $9f,  $07,  $ff,  $8b,  $8f,  $ff
        byte    $7f,  $80,  $03,  $08,  $7e,  $ff,  $9f,  $83,  $01,  $bc,  $87,  $ff,  $05,  $f8,  $03,  $78
        byte    $f0,  $17,  $ff,  $e0,  $07,  $78,  $e1,  $c0,  $3f,  $e0,  $46,  $00,  $ff,  $e2,  $6f,  $3c
        byte    $80,  $ff,  $01,  $0f,  $fe,  $00,  $be,  $06,  $fc,  $3f,  $05,  $fe,  $33,  $f9,  $7c,  $00
        byte    $ff,  $3c,  $f8,  $07,  $9c,  $5c,  $85,  $bf,  $45,  $30,  $fc,  $cf,  $c0,  $11,  $08,  $07
        byte    $fc,  $f9,  $78,  $81,  $ff,  $67,  $f2,  $04,  $00,  $02,  $07,  $1f,  $b0,  $cf,  $cf,  $07
        byte    $0e,  $18,  $00,  $01,  $17,  $ff,  $27,  $78,  $3c,  $fc,  $9f,  $3f,  $bf,  $fe,  $03,  $fe
        byte    $70,  $c0,  $18,  $c0,  $ef,  $e7,  $6d,  $9e,  $c0,  $07,  $f0,  $e4,  $c3,  $f1,  $0c,  $00
        byte    $fe,  $67,  $80,  $ff,  $0f,  $3c,  $1e,  $c0,  $8f,  $07,  $ff,  $c1,  $c3,  $81,  $c7,  $f1
        byte    $83,  $77,  $70,  $fe,  $c0,  $1f,  $80,  $47,  $d0,  $f8,  $0f,  $1e,  $03,  $80,  $ff,  $67

        byte    $11,  $00,  $fc,  $7f,  $00,  $3e,  $e0,  $5f,  $03,  $47,  $30,  $c2,  $fb,  $f9,  $8f,  $78
        byte    $7e,  $fc,  $23,  $8f,  $52,  $80,  $ff,  $cf,  $03,  $40,  $00,  $2f,  $f8,  $26,  $70,  $00
        byte    $fc,  $6b,  $47,  $f8,  $45,  $e0,  $1f,  $60,  $3b,  $7e,  $57,  $e1,  $07,  $be,  $8f,  $e4
        byte    $77,  $e0,  $3f,  $00,  $fe,  $37,  $07,  $ff,  $0b

c_43    byte    $c2,  $02,  $e2,  $00,  $08,  $f4,  $1f,  $50,  $94,  $e8,  $a0,  $13,  $f8,  $b0,  $9f,  $be
        byte    $06,  $7f,  $11,  $c2,  $bf,  $04,  $c0,  $ef,  $02,  $3c,  $e8,  $00,  $78,  $a7,  $f8,  $8c
        byte    $4e,  $0f,  $00,  $3b,  $c1,  $07,  $74,  $f2,  $48,  $e8,  $82,  $df,  $89,  $2f,  $c1,  $8f
        byte    $ff,  $07,  $fe,  $9d,  $8b,  $5d,  $13,  $9d,  $c0,  $bf,  $36,  $fc,  $15,  $08,  $00,  $dc
        byte    $03,  $d0,  $40,  $a7,  $0f,  $ff,  $9f,  $15,  $0e,  $26,  $3e,  $ba,  $81,  $7b,  $68,  $e8
        byte    $c2,  $ef,  $af,  $83,  $43,  $8f,  $1f,  $f0,  $3c,  $7a,  $e1,  $e3,  $e8,  $f4,  $e0,  $1f
        byte    $ff,  $47,  $07,  $9e,  $de,  $09,  $38,  $dd,  $fc,  $3f,  $fa,  $7c,  $74,  $80,  $fb,  $e9
        byte    $e0,  $df,  $e5,  $c0,  $7f,  $45,  $7f,  $27,  $70,  $00,  $01,  $9f,  $fe,  $3d,  $44,  $f4
        byte    $77,  $19,  $38,  $c0,  $ff,  $53,  $08,  $b0,  $e7,  $01,  $3c,  $80,  $6e,  $1f,  $1d,  $0d
        byte    $01,  $0e,  $32,  $00,  $1b,  $48,  $ec,  $f1,  $87,  $bf,  $f1,  $4b,  $f0,  $03,  $c0,  $5e
        byte    $f0,  $4d,  $5f,  $c2,  $01,  $77,  $1b,  $f0,  $df,  $eb,  $a0,  $03,  $f8,  $4f,  $43,  $e7
        byte    $00,  $80,  $40,  $1f,  $bd,  $02,  $1a,  $7f,  $fc,  $74,  $81,  $03,  $06,  $c0,  $40,  $13
        byte    $ff,  $2e,  $7f,  $3d,  $03,  $1e,  $1a,  $86,  $3e,  $e0,  $88,  $6b,  $00,  $df,  $85,  $bf
        byte    $a3,  $60,  $01,  $40,  $37,  $1e,  $3f,  $80,  $3b,  $12,  $fc,  $07,  $7c,  $e0,  $18,  $68
        byte    $e8,  $86,  $cf,  $a1,  $b1,  $bf,  $1b,  $bc,  $83,  $5f,  $e0,  $1d,  $00,  $07,  $7d,  $f8
        byte    $0f,  $e8,  $30,  $00,  $b8,  $a7,  $42,  $c0,  $44,  $0f,  $c0,  $8a,  $de,  $43,  $78,  $3f

        byte    $85,  $f8,  $12,  $3d,  $f8,  $c7,  $5f,  $c8,  $a3,  $1b,  $7e,  $11,  $c0,  $8c,  $4f,  $f0
        byte    $9d,  $0e,  $80,  $77,  $65,  $16,  $08,  $80,  $9f,  $b0,  $e0,  $1f,  $e0,  $67,  $44,  $41
        byte    $57,  $53,  $82,  $1f,  $fc,  $91,  $dd,  $0e,  $fc,  $07,  $00,  $ef,  $ce,  $e8,  $6c,  $02

c_44    byte    $cc,  $02,  $82,  $00,  $08,  $fa,  $0f,  $8c,  $8a,  $0e,  $9e,  $c0,  $97,  $49,  $3f,  $4f
        byte    $fc,  $ef,  $83,  $87,  $c4,  $5b,  $00,  $fc,  $af,  $03,  $e0,  $2f,  $20,  $00,  $02,  $0b
        byte    $80,  $2f,  $30,  $4f,  $3e,  $85,  $17,  $9c,  $27,  $be,  $37,  $9e,  $27,  $fc,  $17,  $7f
        byte    $3e,  $4f,  $f0,  $6f,  $3f,  $03,  $01,  $c0,  $0b,  $0e,  $fc,  $f3,  $f7,  $01,  $d0,  $00
        byte    $e0,  $cf,  $c2,  $01,  $c0,  $0f,  $f0,  $c7,  $e1,  $cb,  $e1,  $0b,  $9e,  $c7,  $17,  $3e
        byte    $8e,  $1f,  $9c,  $b7,  $7f,  $1f,  $f8,  $ff,  $5f,  $0f,  $f8,  $c1,  $01,  $08,  $18,  $f0
        byte    $1f,  $78,  $f0,  $ff,  $03,  $03,  $10,  $30,  $e0,  $3f,  $e0,  $81,  $3f,  $f0,  $af,  $ff
        byte    $ff,  $ff,  $e5,  $cf,  $7f,  $c0,  $43,  $02,  $30,  $80,  $65,  $02,  $e0,  $53,  $f0,  $09
        byte    $40,  $e0,  $0d,  $ff,  $98,  $70,  $e0,  $5f,  $30,  $f8,  $d3,  $1b,  $f0,  $ff,  $ff,  $05
        byte    $0e,  $f8,  $ff,  $ff,  $bf,  $3c,  $f8,  $0f,  $00,  $03,  $fe,  $f4,  $73,  $4c,  $80,  $7b
        byte    $9e,  $f9,  $3f,  $fd,  $87,  $9f,  $cb,  $46,  $31,  $d1,  $80,  $53,  $c0,  $0f,  $e0,  $35
        byte    $78,  $80,  $3b,  $7c,  $f0,  $1c,  $3f,  $38,  $be,  $f0,  $79,  $fc,  $38,  $7c,  $c1,  $3b
        byte    $78,  $f9,  $f3,  $1f,  $00,  $fe,  $00,  $08,  $20,  $f0,  $36,  $00,  $f8,  $b3,  $10,  $00
        byte    $fc,  $03,  $70,  $01,  $fe,  $33,  $84,  $f7,  $e6,  $3f,  $c4,  $f3,  $c6,  $3f,  $e4,  $f1
        byte    $86,  $3f,  $f4,  $00,  $b0,  $e1,  $cf,  $3f,  $f8,  $a7,  $03,  $e0,  $af,  $e6,  $40,  $00
        byte    $fc,  $82,  $1f,  $ff,  $00,  $1b,  $c1,  $c1,  $eb,  $b4,  $84,  $ef,  $27,  $f1,  $76,  $e0

        byte    $3f,  $00,  $fc,  $dd,  $38,  $f0,  $3f,  $01

c_45    byte    $c2,  $02,  $2c,  $00,  $08,  $f4,  $1f,  $50,  $94,  $e8,  $a0,  $13,  $f8,  $b0,  $1f,  $f9
        byte    $03,  $f8,  $bb,  $2b,  $04,  $44,  $04,  $74,  $55,  $c0,  $ef,  $02,  $38,  $e8,  $00,  $78
        byte    $af,  $87,  $8d,  $5e,  $1e,  $00,  $ba,  $10,  $16,  $04,  $e0,  $eb,  $66,  $d8,  $09,  $bf
        byte    $db,  $61,  $27,  $f0,  $5e,  $01,  $80,  $7b,  $00,  $1a,  $e8,  $ad,  $70,  $30,  $f1,  $03
        byte    $bc,  $a3,  $a1,  $97,  $43,  $2f,  $78,  $1e,  $bd,  $f0,  $71,  $f4,  $e1,  $e9,  $c5,  $0f
        byte    $a7,  $bf,  $0f,  $5c,  $2f,  $ff,  $fe,  $7e,  $e0,  $00,  $02,  $04,  $f8,  $0f,  $70,  $18
        byte    $d1,  $df,  $2f,  $dc,  $7f,  $b0,  $c3,  $82,  $fe,  $0e,  $c0,  $00,  $82,  $1c,  $7c,  $08
        byte    $ee,  $ef,  $ef,  $ef,  $13,  $de,  $df,  $df,  $df,  $df,  $df,  $27,  $ce,  $7f,  $08,  $ff
        byte    $7e,  $70,  $00,  $02,  $04,  $f8,  $0f,  $fc,  $80,  $d3,  $8b,  $bf,  $1f,  $cf,  $1f,  $8e
        byte    $5e,  $f8,  $3c,  $fa,  $38,  $f4,  $82,  $77,  $d0,  $0b,  $bc,  $03,  $e0,  $80,  $00,  $ff
        byte    $81,  $1d,  $06,  $00,  $f7,  $54,  $1c,  $4c,  $f4,  $00,  $ac,  $00,  $df,  $53,  $10,  $00
        byte    $bf,  $0f,  $5f,  $37,  $ff,  $4f,  $1e,  $dd,  $f0,  $3b,  $3d,  $00,  $14,  $e0,  $3f,  $00
        byte    $7c,  $a7,  $03,  $e0,  $5d,  $19,  $9d,  $15,  $f0,  $bb,  $00,  $76,  $46,  $f8,  $ef,  $6a
        byte    $4a,  $f0,  $a3,  $7f,  $02,  $7f,  $b7,  $83,  $86,  $00,  $e0,  $dd,  $19,  $9d,  $4d

c_46    byte    $cc,  $02,  $a2,  $03,  $08,  $fa,  $0f,  $8c,  $8a,  $0e,  $9e,  $c0,  $97,  $49,  $3f,  $e0
        byte    $13,  $f8,  $df,  $fc,  $07,  $0f,  $ff,  $2f,  $01,  $f0,  $5f,  $00,  $1b,  $01,  $07,  $80
        byte    $0b,  $fe,  $fc,  $03,  $7f,  $7a,  $00,  $f8,  $02,  $ff,  $e4,  $51,  $f4,  $e7,  $ff,  $85
        byte    $e7,  $0d,  $7c,  $08,  $ef,  $2d,  $7c,  $08,  $fe,  $03,  $50,  $00,  $f0,  $af,  $01,  $80
        byte    $1f,  $c0,  $0e,  $be,  $c0,  $1f,  $00,  $82,  $fe,  $fc,  $0b,  $7f,  $70,  $78,  $1d,  $02
        byte    $c6,  $c1,  $f3,  $f8,  $c2,  $c7,  $f1,  $31,  $fc,  $c0,  $f3,  $c5,  $0f,  $e7,  $ff,  $03
        byte    $f7,  $e5,  $ff,  $ff,  $03,  $07,  $0c,  $40,  $80,  $ff,  $80,  $e1,  $c4,  $23,  $01,  $fe
        byte    $e5,  $f8,  $55,  $90,  $9f,  $08,  $bc,  $0c,  $2f,  $93,  $0e,  $0b,  $82,  $01,  $03,  $38
        byte    $26,  $3e,  $00,  $0e,  $3f,  $00,  $7e,  $1c,  $fa,  $17,  $0c,  $78,  $11,  $72,  $f0,  $ff
        byte    $3f,  $01,  $02,  $08,  $79,  $78,  $08,  $ff,  $ff,  $01,  $03,  $08,  $79,  $f0,  $6f,  $3c
        byte    $01,  $fc,  $23,  $fc,  $11,  $80,  $0f,  $20,  $e0,  $61,  $00,  $ce,  $40,  $21,  $c0,  $ff
        byte    $59,  $78,  $34,  $04,  $3c,  $82,  $1e,  $5e,  $00,  $0c,  $3c,  $13,  $0f,  $38,  $87,  $0f
        byte    $fe,  $97,  $03,  $ff,  $c1,  $07,  $1e,  $00,  $81,  $0f,  $8e,  $2f,  $7c,  $1e,  $3f,  $0e
        byte    $5f,  $f0,  $0e,  $be,  $c0,  $1f,  $00,  $01,  $14,  $fc,  $07,  $1f,  $06,  $00,  $7f,  $16
        byte    $02,  $80,  $7f,  $00,  $2e,  $c0,  $27,  $3c,  $f8,  $0f,  $0e,  $02,  $f0,  $de,  $fc,  $9f
        byte    $78,  $de,  $f8,  $9f,  $3c,  $de,  $f0,  $9f,  $1e,  $00,  $26,  $fc,  $07,  $c0,  $3f,  $1d

        byte    $00,  $7f,  $35,  $9e,  $02,  $e0,  $bf,  $00,  $3e,  $13,  $fe,  $5f,  $a7,  $82,  $0f,  $ff
        byte    $01,  $fc,  $6f,  $07,  $4f,  $e0,  $ef,  $86,  $3f,  $ff,  $27

c_47    byte    $42,  $02,  $32,  $01,  $08,  $fa,  $0f,  $94,  $92,  $0e,  $ba,  $c0,  $c7,  $7e,  $e0,  $fb
        byte    $c0,  $df,  $7f,  $14,  $1c,  $24,  $87,  $06,  $1e,  $3d,  $80,  $dd,  $03,  $f0,  $8c,  $87
        byte    $4f,  $b6,  $b8,  $ed,  $82,  $ff,  $f2,  $48,  $76,  $f1,  $17,  $f1,  $f5,  $7b,  $f0,  $bb
        byte    $3e,  $fc,  $f7,  $80,  $f7,  $bb,  $02,  $fa,  $3f,  $03,  $80,  $ff,  $f0,  $01,  $39,  $00
        byte    $d8,  $ef,  $00,  $eb,  $34,  $23,  $7e,  $fc,  $77,  $c0,  $71,  $e8,  $f7,  $78,  $f4,  $bb
        byte    $f0,  $71,  $f4,  $3b,  $e0,  $3b,  $78,  $fa,  $5d,  $fc,  $70,  $7a,  $fe,  $fa,  $fd,  $1e
        byte    $b8,  $7e,  $47,  $38,  $ff,  $ce,  $c8,  $5f,  $bf,  $00,  $10,  $40,  $a3,  $07,  $3c,  $83
        byte    $bf,  $5f,  $e9,  $18,  $4f,  $00,  $fe,  $16,  $3b,  $01,  $1f,  $fc,  $bb,  $86,  $bf,  $17
        byte    $00,  $cd,  $48,  $57,  $78,  $d7,  $c3,  $bf,  $07,  $a0,  $2f,  $f8,  $db,  $71,  $30,  $70
        byte    $1c,  $e9,  $00,  $6c,  $04,  $fd,  $38,  $ec,  $77,  $05,  $74,  $0d,  $ff,  $27,  $0e,  $3e
        byte    $c6,  $fb,  $7d,  $e0,  $85,  $90,  $87,  $6f,  $a4,  $df,  $7d,  $74,  $c0,  $ff,  $2b,  $1d
        byte    $07,  $09,  $80,  $c3,  $5f,  $c1,  $1f,  $fe,  $ae,  $8f,  $03,  $b8,  $82,  $81,  $0c,  $f0
        byte    $4c,  $87,  $7f,  $b7,  $38,  $e8,  $67,  $02,  $1e,  $3a,  $e0,  $bf,  $70,  $fa,  $03,  $9f
        byte    $f8,  $fb,  $8d,  $60,  $07,  $cf,  $bf,  $87,  $a3,  $df,  $85,  $cf,  $a3,  $eb,  $a3,  $19
        byte    $e9,  $70,  $e8,  $0f,  $c1,  $3b,  $e8,  $77,  $81,  $77,  $00,  $0e,  $7c,  $34,  $23,  $1d
        byte    $03,  $80,  $fb,  $9d,  $8a,  $80,  $ae,  $9f,  $1f,  $c0,  $0b,  $f8,  $48,  $bf,  $10,  $80

        byte    $df,  $f7,  $df,  $c5,  $d3,  $e7,  $df,  $e5,  $91,  $f0,  $77,  $09,  $c0,  $ef,  $7a,  $00
        byte    $d8,  $03,  $df,  $75,  $00,  $bc,  $97,  $e9,  $0a,  $80,  $df,  $03,  $d8,  $8d,  $f8,  $ef
        byte    $b5,  $12,  $7e,  $06,  $01,  $fc,  $7d,  $07,  $5d,  $e0,  $fd,  $4c,  $b7,  $05

c_48    byte    $4c,  $02,  $4a,  $03,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $e0,  $7b
        byte    $c0,  $ff,  $f3,  $1f,  $fd,  $7f,  $02,  $e0,  $7f,  $80,  $5b,  $07,  $ad,  $00,  $ff,  $c0
        byte    $5f,  $0f,  $00,  $9b,  $17,  $fc,  $cb,  $a3,  $7c,  $f1,  $8f,  $78,  $4a,  $03,  $fe,  $f9
        byte    $8f,  $f0,  $7f,  $ff,  $83,  $00,  $f0,  $ff,  $03,  $f0,  $01,  $fe,  $3a,  $38,  $5e,  $03
        byte    $00,  $ff,  $67,  $70,  $f0,  $1f,  $1f,  $80,  $d0,  $c3,  $c1,  $7f,  $e0,  $f0,  $bf,  $20
        byte    $78,  $fc,  $2f,  $0c,  $1c,  $9f,  $8f,  $07,  $3f,  $9c,  $ff,  $c3,  $03,  $07,  $40,  $f8
        byte    $3f,  $c1,  $eb,  $c7,  $3f,  $7c,  $7c,  $e0,  $fc,  $fd,  $0f,  $bf,  $17,  $38,  $00,  $3f
        byte    $fe,  $3f,  $63,  $f8,  $1f,  $7f,  $0f,  $78,  $fe,  $c0,  $80,  $2f,  $80,  $3f,  $ff,  $47
        byte    $e0,  $01,  $fe,  $7f,  $00,  $06,  $e0,  $3f,  $14,  $5e,  $24,  $af,  $8f,  $ff,  $33,  $f0
        byte    $0b,  $06,  $08,  $20,  $78,  $8d,  $17,  $86,  $3f,  $0f,  $eb,  $0f,  $40,  $c0,  $0f,  $f0
        byte    $08,  $fd,  $18,  $f6,  $9f,  $00,  $ff,  $1c,  $38,  $7c,  $f1,  $7f,  $c5,  $0b,  $dc,  $1f
        byte    $c0,  $25,  $74,  $e0,  $ff,  $f1,  $00,  $ff,  $1b,  $5e,  $01,  $c5,  $ff,  $2e,  $7e,  $80
        byte    $17,  $81,  $87,  $cf,  $00,  $fe,  $d7,  $c7,  $03,  $6e,  $f4,  $07,  $b0,  $79,  $f8,  $7f
        byte    $03,  $f8,  $bf,  $99,  $0a,  $3f,  $fc,  $e1,  $7c,  $fe,  $01,  $3f,  $f8,  $ff,  $07,  $fe
        byte    $8b,  $07,  $40,  $30,  $3c,  $81,  $3f,  $f8,  $38,  $fe,  $27,  $78,  $78,  $fc,  $1f,  $87
        byte    $d7,  $df,  $99,  $80,  $77,  $f0,  $1f,  $01,  $f0,  $07,  $20,  $00,  $7f,  $e7,  $6b,  $00

        byte    $f0,  $73,  $15,  $8b,  $00,  $e0,  $ff,  $03,  $70,  $01,  $ff,  $7f,  $f0,  $04,  $0c,  $21
        byte    $7f,  $00,  $01,  $9e,  $1f,  $ff,  $cb,  $e7,  $87,  $ff,  $7a,  $30,  $e8,  $3f,  $04,  $ff
        byte    $3a,  $30,  $fe,  $01,  $7f,  $05,  $d8,  $ff,  $00,  $be,  $c9,  $55,  $5c,  $85,  $8f,  $25
        byte    $c0,  $ff,  $3b,  $78,  $81,  $ff,  $cd,  $7b,  $01

c_49    byte    $8c,  $02,  $fa,  $02,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $3e
        byte    $f0,  $ff,  $ec,  $bf,  $d6,  $6e,  $00,  $7e,  $f7,  $01,  $b8,  $3b,  $00,  $de,  $fd,  $f4
        byte    $e1,  $01,  $e0,  $7f,  $e0,  $3b,  $8f,  $9a,  $1e,  $fc,  $89,  $ef,  $27,  $7f,  $fc,  $27
        byte    $bc,  $ff,  $fd,  $4f,  $e0,  $3f,  $9d,  $2f,  $e0,  $9f,  $ff,  $00,  $1a,  $00,  $7c,  $05
        byte    $9c,  $b0,  $1c,  $00,  $fc,  $ff,  $01,  $7f,  $37,  $19,  $38,  $01,  $30,  $87,  $ff,  $ff
        byte    $e3,  $f1,  $ff,  $07,  $88,  $e3,  $27,  $07,  $ff,  $e1,  $c1,  $71,  $fe,  $c7,  $00,  $c7
        byte    $07,  $c0,  $e7,  $e1,  $7f,  $3f,  $c0,  $ff,  $7f,  $e0,  $c4,  $c0,  $7f,  $3e,  $1e,  $7f
        byte    $1e,  $2f,  $f0,  $fb,  $ff,  $03,  $f3,  $01,  $d8,  $cf,  $c3,  $cf,  $07,  $78,  $30,  $00
        byte    $fe,  $bf,  $f2,  $01,  $4c,  $ff,  $f0,  $fd,  $09,  $07,  $fc,  $fc,  $8c,  $ff,  $bf,  $87
        byte    $13,  $c0,  $7f,  $80,  $00,  $04,  $fc,  $57,  $0c,  $7f,  $00,  $fe,  $d6,  $ff,  $27,  $f8
        byte    $78,  $c2,  $d3,  $03,  $ff,  $1d,  $fc,  $04,  $18,  $ff,  $17,  $b0,  $0c,  $7f,  $3f,  $3f
        byte    $b5,  $0f,  $d8,  $43,  $3a,  $a1,  $39,  $f4,  $0f,  $dc,  $00,  $fc,  $df,  $fe,  $5b,  $fc
        byte    $7e,  $72,  $e0,  $ff,  $fb,  $00,  $78,  $82,  $87,  $df,  $1c,  $00,  $ff,  $7f,  $0a,  $c0
        byte    $ff,  $7d,  $f8,  $07,  $37,  $fd,  $fc,  $c7,  $ff,  $af,  $07,  $b8,  $fe,  $36,  $e1,  $ff
        byte    $07,  $e7,  $fb,  $1b,  $ad,  $e0,  $ff,  $d3,  $3f,  $c0,  $8f,  $e7,  $fc,  $07,  $fc,  $e3
        byte    $f8,  $27,  $e0,  $4f,  $f0,  $79,  $fc,  $9f,  $1f,  $87,  $27,  $e0,  $67,  $f0,  $1e,  $fe

        byte    $cf,  $c0,  $1d,  $00,  $34,  $f0,  $ff,  $5b,  $80,  $ff,  $4d,  $4b,  $40,  $72,  $70,  $33
        byte    $40,  $00,  $e0,  $ff,  $4d,  $27,  $c0,  $ff,  $9f,  $ff,  $c7,  $e3,  $e1,  $a6,  $0f,  $80
        byte    $c7,  $3f,  $01,  $fe,  $09,  $c7,  $e7,  $4d,  $e0,  $bf,  $83,  $9b,  $81,  $7f,  $01,  $3f
        byte    $03,  $fe,  $e9,  $e7,  $9b,  $fd,  $5c,  $fc,  $3f,  $3b,  $f8,  $c0,  $7f,  $4e,  $7f,  $26

c_50    byte    $8c,  $02,  $46,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $1e
        byte    $f0,  $ff,  $ec,  $bf,  $d6,  $2e,  $00,  $7e,  $f7,  $01,  $b0,  $3b,  $00,  $dc,  $1b,  $f0
        byte    $ee,  $01,  $e0,  $7f,  $e0,  $3b,  $8f,  $9a,  $1e,  $fc,  $89,  $e7,  $27,  $0f,  $fc,  $27
        byte    $fc,  $ff,  $fd,  $17,  $01,  $e0,  $7f,  $f2,  $f1,  $1f,  $e0,  $9f,  $fc,  $3c,  $80,  $06
        byte    $fe,  $f9,  $6f,  $39,  $00,  $78,  $93,  $bf,  $07,  $fc,  $dd,  $fc,  $1f,  $07,  $04,  $37
        byte    $f9,  $0f,  $e0,  $79,  $70,  $f8,  $02,  $fe,  $c3,  $e1,  $01,  $20,  $80,  $ef,  $ff,  $fb
        byte    $00,  $fe,  $0c,  $9c,  $30,  $e0,  $e0,  $80,  $ff,  $ff,  $87,  $83,  $ef,  $39,  $f8,  $80
        byte    $c1,  $81,  $f1,  $f1,  $3f,  $e1,  $17,  $1c,  $00,  $f6,  $f0,  $19,  $1e,  $e0,  $02,  $c0
        byte    $fb,  $f8,  $0c,  $4e,  $00,  $00,  $ff,  $fb,  $f7,  $20,  $1c,  $f0,  $e3,  $e3,  $e7,  $f0
        byte    $ff,  $bf,  $f9,  $fd,  $3e,  $8c,  $03,  $04,  $e0,  $e0,  $04,  $fc,  $7e,  $1e,  $e0,  $27
        byte    $e0,  $c3,  $7f,  $82,  $c1,  $bf,  $e0,  $cf,  $ff,  $2b,  $80,  $f1,  $7d,  $3f,  $0f,  $fc
        byte    $e7,  $f3,  $3d,  $fc,  $04,  $78,  $00,  $04,  $60,  $60,  $01,  $ff,  $a3,  $bd,  $b0,  $84
        byte    $ff,  $01,  $ff,  $fb,  $33,  $fc,  $80,  $2f,  $7c,  $df,  $87,  $c1,  $bf,  $c6,  $77,  $e0
        byte    $f0,  $af,  $01,  $b8,  $08,  $68,  $7f,  $82,  $2f,  $c1,  $c3,  $9f,  $f8,  $ab,  $8f,  $07
        byte    $6e,  $f2,  $f9,  $8f,  $ff,  $5f,  $fe,  $00,  $16,  $3f,  $bf,  $05,  $ff,  $c0,  $ff,  $83
        byte    $f3,  $1f,  $f8,  $e6,  $0f,  $ff,  $17,  $f0,  $c6,  $2f,  $78,  $da,  $f7,  $df,  $d2,  $c3

        byte    $d1,  $0c,  $8c,  $20,  $38,  $c1,  $e7,  $f1,  $bf,  $f0,  $cf,  $e1,  $39,  $f8,  $f6,  $0b
        byte    $f8,  $f5,  $3c,  $fc,  $0c,  $fc,  $01,  $fc,  $37,  $3d,  $03,  $80,  $7d,  $dc,  $bc,  $04
        byte    $00,  $ff,  $37,  $01,  $04,  $f0,  $fc,  $dc,  $fc,  $e1,  $fd,  $9b,  $00,  $04,  $7c,  $fe
        byte    $6e,  $c2,  $ff,  $f9,  $dc,  $0c,  $ff,  $7b,  $f8,  $19,  $fc,  $77,  $f0,  $33,  $f0,  $2f
        byte    $e0,  $67,  $80,  $3f,  $fd,  $7c,  $b3,  $9f,  $8b,  $ff,  $67,  $07,  $1f,  $f8,  $cf,  $e9
        byte    $cf,  $04

c_51    byte    $4e,  $01,  $12,  $02,  $08,  $c0,  $bf,  $ff,  $10,  $83,  $f0,  $10,  $0e,  $f0,  $88,  $fc
        byte    $c0,  $f7,  $81,  $3f,  $bc,  $54,  $33,  $12,  $00,  $3f,  $06,  $1f,  $00,  $83,  $71,  $90
        byte    $63,  $70,  $1e,  $a2,  $15,  $00,  $3e,  $1e,  $1e,  $c5,  $65,  $8b,  $2f,  $5c,  $01,  $fc
        byte    $43,  $80,  $17,  $5e,  $83,  $c3,  $19,  $08,  $47,  $40,  $78,  $0e,  $fc,  $03,  $34,  $00
        byte    $38,  $dd,  $70,  $00,  $3b,  $68,  $13,  $c0,  $11,  $c0,  $1d,  $18,  $88,  $d0,  $87,  $7f
        byte    $f0,  $1c,  $1c,  $64,  $e8,  $27,  $1c,  $1e,  $cb,  $85,  $03,  $1f,  $07,  $87,  $01,  $fd
        byte    $f9,  $87,  $8f,  $07,  $07,  $9e,  $06,  $fc,  $fb,  $c7,  $0f,  $07,  $87,  $0f,  $00,  $02
        byte    $c2,  $83,  $d3,  $49,  $b8,  $f0,  $c1,  $81,  $9b,  $64,  $8d,  $7a,  $c0,  $01,  $ff,  $61
        byte    $8e,  $f0,  $00,  $c0,  $0b,  $17,  $b8,  $f0,  $31,  $f0,  $ac,  $e1,  $5f,  $b0,  $f1,  $70
        byte    $3c,  $ac,  $e1,  $df,  $b0,  $f0,  $77,  $1c,  $f8,  $6d,  $c7,  $21,  $70,  $f0,  $00,  $ea
        byte    $f4,  $bf,  $cb,  $dc,  $fc,  $3d,  $00,  $e6,  $b1,  $c6,  $1e,  $fc,  $7d,  $00,  $f6,  $f0
        byte    $cf,  $1d,  $f8,  $c3,  $99,  $03,  $40,  $3b,  $f0,  $fd,  $00,  $16,  $d0,  $e0,  $1c,  $fe
        byte    $fa,  $80,  $df,  $20,  $78,  $ff,  $73,  $fe,  $0b,  $dc,  $7f,  $2a,  $0d,  $09,  $0e,  $f7
        byte    $1f,  $00,  $7e,  $0c,  $87,  $db,  $90,  $c3,  $70,  $ff,  $01,  $e0,  $e0,  $93,  $7c,  $fe
        byte    $a9,  $60,  $10,  $70,  $21,  $f0,  $0f,  $c2,  $07,  $ff,  $70,  $fd,  $87,  $0f,  $40,  $80
        byte    $ff,  $43,  $f9,  $c3,  $99,  $b5,  $18,  $7f,  $f8,  $c3,  $a9,  $06,  $3c,  $00,  $ff,  $f8

        byte    $f1,  $b4,  $e0,  $ff,  $90,  $70,  $70,  $bc,  $ca,  $bf,  $08,  $f8,  $bb,  $f8,  $f0,  $ef
        byte    $df,  $40,  $12,  $1c,  $76,  $08,  $c7,  $b1,  $7f,  $f0,  $0e,  $c2,  $73,  $be,  $c7,  $2d
        byte    $fe,  $e2,  $09,  $04,  $f8,  $2d,  $61,  $f9,  $07,  $2c,  $00,  $70,  $f8,  $00,  $05,  $88
        byte    $0f,  $ff,  $08,  $fb,  $e1,  $3d,  $e9,  $27,  $fc,  $27,  $c3,  $c3,  $1f,  $8e,  $87,  $f0
        byte    $2e,  $39,  $33,  $c2,  $4f,  $00,  $1c,  $13,  $2e,  $c0,  $74,  $be,  $09,  $37,  $cc,  $fd
        byte    $ca,  $8c,  $c4,  $c1,  $ae,  $f1,  $65,  $18,  $26

c_52    byte    $8c,  $02,  $26,  $00,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $3e
        byte    $f0,  $ff,  $ec,  $bf,  $d6,  $2e,  $00,  $7e,  $f7,  $01,  $b0,  $3b,  $00,  $de,  $7b,  $f7
        byte    $00,  $b0,  $0b,  $00,  $df,  $79,  $d4,  $8c,  $af,  $e2,  $f9,  $99,  $4f,  $85,  $ff,  $b3
        byte    $8f,  $0a,  $fe,  $67,  $3f,  $00,  $05,  $00,  $ff,  $d9,  $df,  $33,  $00,  $38,  $dc,  $e4
        byte    $7f,  $38,  $10,  $08,  $fc,  $0b,  $78,  $e3,  $35,  $f0,  $df,  $c0,  $e7,  $d0,  $e0,  $7e
        byte    $07,  $0f,  $3c,  $8f,  $86,  $e3,  $7b,  $78,  $f0,  $17,  $87,  $f1,  $7d,  $7c,  $3c,  $38
        byte    $1c,  $00,  $04,  $e0,  $e7,  $e1,  $87,  $13,  $0c,  $00,  $fe,  $ff,  $80,  $13,  $00,  $fc
        byte    $f9,  $fb,  $07,  $fc,  $ca,  $27,  $f0,  $17,  $07,  $fc,  $c1,  $13,  $f0,  $ff,  $c7,  $63
        byte    $e0,  $bf,  $03,  $1e,  $00,  $07,  $07,  $1f,  $fe,  $83,  $f7,  $8e,  $87,  $ff,  $f1,  $3c
        byte    $03,  $be,  $3f,  $78,  $e0,  $1c,  $9e,  $80,  $9b,  $84,  $3f,  $07,  $2f,  $fc,  $24,  $18
        byte    $b0,  $01,  $80,  $cf,  $df,  $09,  $06,  $9f,  $00,  $e0,  $cf,  $cf,  $77,  $f0,  $16,  $f8
        byte    $e4,  $e3,  $f1,  $f7,  $f0,  $e1,  $bd,  $f1,  $f0,  $fb,  $f8,  $78,  $9e,  $83,  $07,  $df
        byte    $cf,  $e7,  $f1,  $04,  $3c,  $f0,  $fe,  $80,  $2f,  $0f,  $29,  $fc,  $3f,  $0c,  $00,  $2c
        byte    $db,  $3f,  $f0,  $21,  $a0,  $fa,  $11,  $fc,  $5f,  $00,  $9f,  $7c,  $18,  $fc,  $1f,  $7e
        byte    $f1,  $e0,  $e0,  $81,  $1b,  $02,  $f0,  $17,  $06,  $1e,  $f8,  $7f,  $03,  $ed,  $05,  $1f
        byte    $bf,  $39,  $f0,  $ff,  $fd,  $3c,  $38,  $c3,  $c3,  $03,  $d8,  $fc,  $e1,  $ff,  $3e,  $1e

        byte    $e0,  $57,  $1e,  $9e,  $e6,  $67,  $00,  $ff,  $0f,  $47,  $f3,  $f7,  $e0,  $0b,  $a8,  $3c
        byte    $5e,  $0b,  $f8,  $0d,  $7c,  $0e,  $02,  $3e,  $7f,  $07,  $0d,  $7c,  $f9,  $23,  $78,  $48
        byte    $c0,  $9f,  $c1,  $9b,  $7c,  $7e,  $03,  $8e,  $7f,  $4e,  $80,  $05,  $78,  $ff,  $39,  $01
        byte    $04,  $70,  $73,  $fe,  $fe,  $6e,  $4e,  $00,  $c2,  $bf,  $09,  $ff,  $f7,  $73,  $33,  $fc
        byte    $ef,  $e1,  $67,  $f0,  $df,  $c1,  $cf,  $c0,  $bf,  $80,  $9f,  $01,  $fe,  $f4,  $f3,  $cd
        byte    $7e,  $2e,  $fe,  $9f,  $1d,  $7c,  $e0,  $3f,  $a7,  $3f,  $13

c_53    byte    $81,  $01,  $12,  $00,  $08,  $c0,  $bf,  $ff,  $20,  $03,  $71,  $10,  $1c,  $f0,  $10,  $01
        byte    $f8,  $81,  $ef,  $03,  $7f,  $f0,  $00,  $a2,  $8e,  $11,  $80,  $00,  $f8,  $61,  $f8,  $00
        byte    $18,  $6f,  $9c,  $0e,  $02,  $f7,  $10,  $ba,  $00,  $f0,  $e1,  $f1,  $48,  $1c,  $00,  $bc
        byte    $20,  $f0,  $05,  $0f,  $00,  $4f,  $10,  $a1,  $a6,  $18,  $48,  $e1,  $41,  $78,  $c8,  $06
        byte    $38,  $98,  $18,  $1d,  $00,  $34,  $00,  $38,  $46,  $00,  $1e,  $00,  $87,  $54,  $25,  $00
        byte    $1f,  $c0,  $1d,  $08,  $e0,  $1c,  $bd,  $1f,  $e0,  $1c,  $1c,  $38,  $ec,  $d5,  $3f,  $78
        byte    $1e,  $1e,  $0c,  $54,  $20,  $c0,  $3f,  $7c,  $1c,  $3c,  $52,  $02,  $60,  $20,  $38,  $3c
        byte    $78,  $04,  $14,  $34,  $0a,  $7e,  $38,  $d9,  $34,  $e1,  $c1,  $7f,  $70,  $41,  $85,  $e4
        byte    $23,  $38,  $70,  $e0,  $00,  $c0,  $99,  $c5,  $3f,  $7f,  $70,  $41,  $e1,  $00,  $e0,  $2f
        byte    $f8,  $4e,  $38,  $2c,  $12,  $1c,  $f0,  $e1,  $1c,  $64,  $b3,  $6b,  $27,  $06,  $1c,  $06
        byte    $e3,  $bf,  $81,  $5e,  $3c,  $07,  $0f,  $bc,  $9a,  $aa,  $82,  $c3,  $0f,  $5c,  $00,  $e0
        byte    $64,  $ab,  $0b,  $aa,  $9a,  $6c,  $da,  $0b,  $ae,  $04,  $3f,  $e9,  $06,  $57,  $42,  $35
        byte    $fe,  $05,  $07,  $57,  $4e,  $33,  $fe,  $0d,  $06,  $57,  $62,  $39,  $0e,  $82,  $2b,  $b1
        byte    $1d,  $0f,  $43,  $02,  $9c,  $76,  $83,  $29,  $00,  $07,  $07,  $7e,  $83,  $8b,  $4b,  $00
        byte    $ee,  $2f,  $ba,  $f9,  $fd,  $01,  $6e,  $2e,  $ba,  $99,  $fc,  $18,  $f4,  $5f,  $96,  $03
        byte    $f8,  $d7,  $38,  $98,  $ee,  $b1,  $07,  $38,  $78,  $08,  $de,  $0f,  $ff,  $1b,  $7c,  $f0

        byte    $af,  $ab,  $ad,  $e0,  $fc,  $ec,  $d7,  $f7,  $03,  $fe,  $f0,  $5f,  $d3,  $c5,  $c8,  $f8
        byte    $71,  $ac,  $39,  $d9,  $78,  $3c,  $1e,  $2b,  $ec,  $fd,  $4c,  $a2,  $03,  $3f,  $00,  $78
        byte    $07,  $63,  $c2,  $0f,  $6c,  $1f,  $bf,  $5b,  $2e,  $b0,  $cf,  $e1,  $fc,  $0b,  $e9,  $3d
        byte    $c4,  $40,  $46,  $0f,  $3e,  $90,  $4a,  $82,  $0d,  $a4,  $d1,  $23,  $83,  $6f,  $35,  $c2
        byte    $72,  $82,  $3b,  $b2,  $e4,  $e0,  $aa,  $bf,  $37,  $b8,  $bf,  $b3,  $0d,  $ee,  $ef,  $6c
        byte    $83,  $cf,  $70,  $a1,  $e0,  $7b,  $3c,  $22,  $f8,  $18,  $83,  $06

c_54    byte    $8c,  $02,  $fa,  $02,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7f,  $b3,  $1f,  $f8,  $3e
        byte    $f0,  $ff,  $ec,  $bf,  $d6,  $2e,  $00,  $7e,  $f7,  $01,  $b8,  $3b,  $00,  $de,  $7b,  $f7
        byte    $00,  $b0,  $0b,  $00,  $df,  $79,  $d4,  $8c,  $af,  $e2,  $f9,  $99,  $4f,  $85,  $8f,  $a0
        byte    $27,  $1f,  $1d,  $3c,  $87,  $9f,  $1c,  $24,  $01,  $c0,  $f9,  $fc,  $64,  $00,  $60,  $02
        byte    $ec,  $ef,  $ff,  $e5,  $40,  $a0,  $79,  $80,  $27,  $08,  $00,  $fe,  $0c,  $08,  $06,  $fc
        byte    $c7,  $e3,  $e0,  $40,  $e0,  $07,  $30,  $c0,  $f3,  $f0,  $31,  $80,  $a7,  $30,  $e0,  $e3
        byte    $c0,  $33,  $c0,  $7d,  $3f,  $1f,  $de,  $ca,  $c5,  $3f,  $7e,  $38,  $61,  $64,  $01,  $7f
        byte    $e0,  $78,  $d9,  $c0,  $e3,  $0f,  $8e,  $c3,  $cb,  $1e,  $fe,  $ff,  $c9,  $c7,  $7f,  $0e
        byte    $56,  $f6,  $f3,  $81,  $1b,  $00,  $98,  $4f,  $7c,  $02,  $00,  $27,  $c1,  $3f,  $fd,  $ef
        byte    $f8,  $7f,  $00,  $c0,  $93,  $f7,  $ff,  $17,  $b8,  $e4,  $ef,  $ff,  $ff,  $7f,  $02,  $bc
        byte    $e0,  $24,  $3f,  $9f,  $ff,  $c7,  $f1,  $7c,  $7c,  $f8,  $9f,  $c3,  $ff,  $e0,  $ff,  $f7
        byte    $f0,  $81,  $7f,  $07,  $00,  $d2,  $17,  $08,  $7c,  $19,  $00,  $98,  $7e,  $f9,  $05,  $f0
        byte    $e7,  $ef,  $e0,  $7f,  $01,  $fe,  $e1,  $7b,  $f8,  $0e,  $ea,  $03,  $ef,  $67,  $7a,  $18
        byte    $00,  $fc,  $01,  $4e,  $e0,  $86,  $1f,  $f8,  $5f,  $20,  $ff,  $ef,  $ef,  $fb,  $31,  $f0
        byte    $05,  $f8,  $c7,  $0f,  $00,  $87,  $83,  $07,  $c7,  $c0,  $6b,  $0f,  $86,  $8f,  $ef,  $e0
        byte    $85,  $17,  $fc,  $e0,  $c7,  $e3,  $e3,  $7f,  $7f,  $0f,  $87,  $9f,  $0f,  $50,  $40,  $83

        byte    $cf,  $c3,  $df,  $07,  $6c,  $e0,  $7b,  $b8,  $e9,  $4d,  $f0,  $0e,  $7e,  $02,  $ee,  $a3
        byte    $fc,  $3f,  $fd,  $14,  $e0,  $06,  $7e,  $82,  $df,  $01,  $0b,  $f8,  $49,  $7e,  $07,  $08
        byte    $e0,  $e7,  $ff,  $fd,  $dd,  $9c,  $00,  $84,  $7f,  $13,  $ff,  $ef,  $e3,  $66,  $f8,  $df
        byte    $c3,  $cf,  $e0,  $bf,  $83,  $9f,  $81,  $7f,  $01,  $3f,  $03,  $fc,  $e9,  $e7,  $9b,  $fd
        byte    $5c,  $fc,  $3f,  $3b,  $f8,  $c0,  $7f,  $4e,  $7f,  $26

c_55    byte    $8c,  $02,  $06,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $0f,  $f0,  $09
        byte    $ff,  $cf,  $fe,  $6b,  $ed,  $02,  $e0,  $77,  $1f,  $00,  $bb,  $03,  $e0,  $dd,  $40,  $1f
        byte    $1e,  $00,  $7e,  $01,  $e0,  $3b,  $8f,  $9a,  $e1,  $55,  $3c,  $02,  $7a,  $1a,  $1d,  $9e
        byte    $01,  $80,  $d3,  $47,  $05,  $ef,  $01,  $f0,  $6c,  $00,  $05,  $00,  $f7,  $f3,  $01,  $38
        byte    $78,  $06,  $16,  $7c,  $e0,  $27,  $6c,  $07,  $02,  $c1,  $ff,  $27,  $a0,  $bd,  $00,  $18
        byte    $dc,  $89,  $8f,  $83,  $8f,  $01,  $e6,  $27,  $70,  $3c,  $70,  $34,  $38,  $3f,  $c1,  $3f
        byte    $1c,  $5a,  $f9,  $02,  $1e,  $9e,  $ff,  $01,  $38,  $c0,  $0f,  $a7,  $0c,  $0e,  $29,  $f8
        byte    $f8,  $ff,  $3f,  $7f,  $0f,  $9c,  $01,  $80,  $0e,  $4e,  $f0,  $cf,  $ff,  $09,  $78,  $06
        byte    $4e,  $fa,  $1f,  $f0,  $02,  $e8,  $e1,  $03,  $07,  $90,  $04,  $00,  $f6,  $f3,  $c2,  $ff
        byte    $cf,  $df,  $ff,  $e0,  $00,  $08,  $bf,  $e9,  $7f,  $e7,  $ff,  $03,  $80,  $93,  $fc,  $fd
        byte    $04,  $78,  $c1,  $48,  $7e,  $fe,  $5f,  $38,  $fe,  $ff,  $8b,  $43,  $f2,  $f1,  $ff,  $ff
        byte    $ff,  $2f,  $07,  $c9,  $c3,  $ff,  $ff,  $7f,  $f8,  $c0,  $97,  $01,  $80,  $0e,  $3e,  $f8
        byte    $ff,  $00,  $a7,  $df,  $be,  $87,  $ff,  $05,  $7c,  $3f,  $65,  $3c,  $fc,  $06,  $be,  $bf
        byte    $ff,  $e0,  $7b,  $00,  $27,  $60,  $80,  $07,  $50,  $80,  $f3,  $78,  $0e,  $06,  $fc,  $0f
        byte    $90,  $df,  $f3,  $f1,  $9f,  $3f,  $01,  $fc,  $e1,  $f8,  $79,  $f8,  $1f,  $1e,  $07,  $ed
        byte    $9d,  $ff,  $c0,  $78,  $78,  $3e,  $3e,  $ff,  $17,  $fc,  $fc,  $ff,  $df,  $80,  $ef,  $e3

        byte    $a7,  $63,  $e0,  $7b,  $f8,  $09,  $a0,  $83,  $02,  $be,  $b6,  $ef,  $a3,  $00,  $ff,  $1f
        byte    $b0,  $bf,  $6f,  $e0,  $26,  $c1,  $1d,  $b0,  $80,  $9f,  $8c,  $77,  $80,  $7f,  $7a,  $af
        byte    $00,  $42,  $cf,  $89,  $ff,  $f7,  $73,  $f3,  $07,  $e0,  $e3,  $67,  $fc,  $27,  $78,  $f8
        byte    $19,  $fc,  $77,  $f0,  $33,  $f0,  $2f,  $e0,  $67,  $80,  $3f,  $fd,  $7c,  $b3,  $9f,  $8b
        byte    $ff,  $67,  $07,  $1f,  $f8,  $cf,  $e9,  $cf,  $04

c_56    byte    $8c,  $02,  $06,  $01,  $88,  $fe,  $c3,  $cc,  $c9,  $c1,  $07,  $7e,  $b3,  $1f,  $f8,  $3e
        byte    $f0,  $ff,  $ec,  $af,  $fa,  $ff,  $49,  $00,  $fc,  $e9,  $03,  $70,  $77,  $00,  $bc,  $f7
        byte    $ee,  $01,  $60,  $17,  $00,  $be,  $f3,  $a8,  $19,  $5e,  $c5,  $53,  $80,  $4f,  $3e,  $15
        byte    $be,  $01,  $f0,  $d3,  $47,  $5d,  $1e,  $fe,  $72,  $90,  $04,  $00,  $e6,  $07,  $67,  $7c
        byte    $80,  $06,  $04,  $c3,  $ff,  $6f,  $01,  $76,  $e0,  $10,  $38,  $8c,  $13,  $04,  $8c,  $17
        byte    $00,  $e2,  $f8,  $e9,  $71,  $78,  $0d,  $c3,  $4f,  $e0,  $78,  $18,  $00,  $c8,  $e1,  $27
        byte    $78,  $38,  $fe,  $3f,  $01,  $0e,  $1e,  $01,  $00,  $1d,  $dc,  $74,  $e0,  $3c,  $c0,  $ff
        byte    $04,  $7c,  $af,  $3c,  $03,  $00,  $9b,  $00,  $fc,  $e0,  $1a,  $f0,  $df,  $3c,  $f0,  $ff
        byte    $4f,  $00,  $c0,  $e7,  $e7,  $37,  $70,  $0f,  $70,  $f3,  $ff,  $80,  $ff,  $f4,  $0c,  $bc
        byte    $f0,  $e1,  $bc,  $e6,  $e3,  $ff,  $df,  $fc,  $fd,  $0f,  $03,  $80,  $b8,  $9b,  $3e,  $8e
        byte    $e7,  $ee,  $ff,  $85,  $21,  $f9,  $f9,  $09,  $f0,  $e2,  $f0,  $ff,  $ff,  $c9,  $c7,  $ff
        byte    $cb,  $c1,  $ff,  $ff,  $ff,  $ff,  $97,  $01,  $80,  $1e,  $7e,  $02,  $fe,  $1c,  $fc,  $ff
        byte    $9f,  $0f,  $c0,  $0e,  $fe,  $7f,  $fe,  $fe,  $87,  $0f,  $dc,  $c0,  $78,  $b5,  $9d,  $e0
        byte    $a1,  $ff,  $06,  $10,  $9c,  $9f,  $2f,  $a0,  $e0,  $07,  $f0,  $5a,  $00,  $ff,  $0b,  $03
        byte    $77,  $ff,  $37,  $c0,  $3c,  $fc,  $7c,  $f8,  $00,  $5a,  $e2,  $f7,  $c7,  $4f,  $02,  $f0
        byte    $ff,  $d7,  $00,  $00,  $f3,  $d0,  $7c,  $9c,  $ff,  $82,  $1f,  $f8,  $ff,  $ff,  $f6,  $3c

        byte    $94,  $c0,  $ff,  $19,  $68,  $e0,  $1d,  $fc,  $ef,  $e3,  $ff,  $16,  $00,  $f8,  $2b,  $c0
        byte    $0d,  $dc,  $24,  $a0,  $03,  $ee,  $d3,  $61,  $05,  $08,  $a0,  $27,  $bf,  $fd,  $04,  $7f
        byte    $33,  $a7,  $ff,  $6f,  $e2,  $ff,  $7d,  $dc,  $0c,  $ff,  $7b,  $f8,  $19,  $fc,  $77,  $f0
        byte    $33,  $f0,  $6f,  $e0,  $67,  $80,  $3f,  $fd,  $7c,  $b3,  $9f,  $8b,  $ff,  $67,  $07,  $1f
        byte    $f8,  $cf,  $e9,  $cf,  $04

c_57    byte    $8c,  $02,  $7a,  $01,  $88,  $fe,  $fc,  $cf,  $9c,  $1c,  $9c,  $00,  $fc,  $66,  $1f,  $e0
        byte    $13,  $fe,  $9f,  $fd,  $d7,  $da,  $05,  $c0,  $ef,  $3e,  $00,  $76,  $07,  $c0,  $bb,  $81
        byte    $3e,  $3c,  $00,  $fc,  $02,  $c0,  $77,  $3e,  $05,  $c6,  $84,  $57,  $f1,  $14,  $fc,  $73
        byte    $36,  $78,  $0e,  $fe,  $f0,  $91,  $02,  $78,  $3f,  $98,  $a7,  $07,  $80,  $02,  $84,  $f3
        byte    $e7,  $f0,  $1d,  $3c,  $03,  $82,  $c1,  $7f,  $00,  $02,  $00,  $3b,  $10,  $58,  $18,  $9c
        byte    $0f,  $fc,  $09,  $78,  $e5,  $a7,  $c7,  $a1,  $fc,  $9f,  $c0,  $f1,  $28,  $c0,  $0d,  $fc
        byte    $04,  $0f,  $c7,  $7f,  $00,  $5b,  $80,  $83,  $a7,  $00,  $fb,  $ff,  $c0,  $69,  $e0,  $04
        byte    $00,  $fc,  $38,  $fe,  $07,  $fc,  $df,  $6a,  $60,  $04,  $fc,  $c1,  $e1,  $c3,  $19,  $bf
        byte    $f0,  $fb,  $1f,  $f8,  $31,  $c0,  $bf,  $c3,  $58,  $dd,  $87,  $ff,  $8e,  $e3,  $01,  $4b
        byte    $e7,  $b7,  $0f,  $ce,  $c1,  $07,  $fe,  $30,  $a4,  $e7,  $e7,  $7f,  $0e,  $4f,  $cc,  $4d
        byte    $80,  $d7,  $f7,  $f3,  $ff,  $63,  $90,  $fe,  $f9,  $cb,  $41,  $f2,  $71,  $ff,  $ff,  $ff
        byte    $2f,  $03,  $ff,  $ff,  $e5,  $01,  $a0,  $8f,  $9f,  $80,  $3f,  $7f,  $cf,  $c3,  $ff,  $06
        byte    $ca,  $ff,  $df,  $47,  $01,  $ec,  $e1,  $ff,  $fe,  $1c,  $fc,  $e4,  $ec,  $ff,  $9f,  $fc
        byte    $75,  $e0,  $0e,  $3a,  $f8,  $3f,  $9e,  $81,  $0f,  $f0,  $ff,  $8f,  $1f,  $80,  $9f,  $13
        byte    $c0,  $7f,  $e0,  $ff,  $3f,  $01,  $ed,  $60,  $f0,  $f1,  $3f,  $fc,  $87,  $ef,  $fb,  $5f
        byte    $02,  $00,  $1b,  $68,  $ff,  $03,  $08,  $eb,  $79,  $38,  $ff,  $37,  $f0,  $0e,  $3e,  $fe

        byte    $37,  $81,  $7f,  $ff,  $df,  $4f,  $7b,  $06,  $ca,  $17,  $d0,  $01,  $f7,  $c1,  $df,  $c3
        byte    $07,  $f8,  $bf,  $bf,  $0f,  $20,  $cc,  $9d,  $f8,  $7f,  $3f,  $37,  $7f,  $00,  $3e,  $7e
        byte    $c6,  $7f,  $82,  $87,  $9f,  $c1,  $7f,  $07,  $3f,  $03,  $ff,  $02,  $7e,  $06,  $f8,  $d3
        byte    $cf,  $37,  $fb,  $b9,  $f8,  $7f,  $76,  $f0,  $81,  $ff,  $9c,  $fe,  $4c

c_58    byte    $4c,  $02,  $b2,  $03,  $08,  $fd,  $07,  $53,  $e9,  $e0,  $05,  $be,  $a6,  $7e,  $f0,  $a7
        byte    $bf,  $bf,  $d1,  $ff,  $27,  $00,  $fe,  $e8,  $03,  $70,  $eb,  $00,  $78,  $df,  $7a,  $00
        byte    $d8,  $0a,  $00,  $df,  $f2,  $28,  $3c,  $8c,  $f0,  $4a,  $3c,  $85,  $ff,  $91,  $4f,  $09
        byte    $df,  $c7,  $03,  $70,  $69,  $5e,  $f0,  $fe,  $8c,  $bf,  $0e,  $1e,  $01,  $80,  $f1,  $19
        byte    $78,  $cb,  $e4,  $01,  $27,  $e0,  $5b,  $1c,  $0c,  $bf,  $00,  $e0,  $0f,  $00,  $30,  $03
        byte    $e0,  $26,  $78,  $38,  $14,  $70,  $7e,  $70,  $3c,  $fe,  $26,  $80,  $87,  $e3,  $4d,  $00
        byte    $bf,  $70,  $f0,  $34,  $30,  $fe,  $03,  $ce,  $07,  $bc,  $09,  $70,  $bc,  $c5,  $f0,  $83
        byte    $5b,  $fe,  $81,  $c3,  $0f,  $ec,  $f8,  $31,  $0c,  $3f,  $f0,  $e5,  $05,  $d7,  $04,  $0e
        byte    $5e,  $0e,  $c3,  $e7,  $ff,  $07,  $03,  $c0,  $c3,  $bf,  $3c,  $02,  $8e,  $8f,  $c1,  $03
        byte    $c7,  $cf,  $ff,  $da,  $39,  $13,  $c0,  $00,  $1c,  $24,  $7e,  $fe,  $ff,  $7f,  $0c,  $24
        byte    $3e,  $fe,  $f5,  $f7,  $0f,  $dc,  $40,  $01,  $d0,  $47,  $11,  $3e,  $fe,  $fe,  $d7,  $79
        byte    $09,  $d0,  $43,  $9b,  $ff,  $ff,  $ff,  $03,  $f6,  $b0,  $f9,  $6b,  $7f,  $fe,  $bf,  $03
        byte    $ff,  $c1,  $0f,  $f8,  $f7,  $e3,  $3f,  $00,  $fe,  $35,  $ff,  $8b,  $1f,  $c0,  $ff,  $02
        byte    $7e,  $7c,  $f8,  $0f,  $80,  $1b,  $80,  $7f,  $fc,  $ef,  $09,  $c7,  $83,  $ff,  $00,  $fc
        byte    $69,  $a0,  $71,  $f0,  $03,  $f0,  $f7,  $37,  $87,  $07,  $ff,  $c0,  $0d,  $14,  $c1,  $db
        byte    $02,  $16,  $f0,  $f9,  $68,  $01,  $02,  $68,  $ed,  $97,  $c9,  $11,  $f8,  $db,  $ca,  $7f

        byte    $4d,  $f8,  $bf,  $3e,  $ae,  $02,  $fe,  $eb,  $e1,  $07,  $ff,  $3a,  $f8,  $81,  $bf,  $02
        byte    $7e,  $80,  $6f,  $f2,  $5f,  $85,  $1f,  $ff,  $01,  $fe,  $df,  $c1,  $0b,  $fc,  $6f,  $de
        byte    $0b

c_59    byte    $4c,  $02,  $e2,  $03,  $08,  $fd,  $f9,  $9f,  $4a,  $07,  $47,  $00,  $7c,  $4d,  $fd,  $c0
        byte    $f7,  $80,  $ff,  $f7,  $3f,  $fa,  $fb,  $04,  $c0,  $1f,  $7d,  $00,  $6c,  $1d,  $00,  $6f
        byte    $0d,  $74,  $1e,  $00,  $be,  $02,  $c0,  $b7,  $3c,  $0a,  $07,  $c0,  $0b,  $78,  $2f,  $1e
        byte    $0f,  $fe,  $5f,  $3e,  $2f,  $3c,  $1f,  $5f,  $f3,  $82,  $6f,  $00,  $02,  $5f,  $3c,  $34
        byte    $02,  $06,  $1c,  $cb,  $eb,  $e0,  $31,  $00,  $18,  $c3,  $03,  $2c,  $59,  $1d,  $00,  $fc
        byte    $05,  $00,  $7f,  $00,  $fc,  $c3,  $c3,  $e1,  $6f,  $02,  $70,  $3c,  $0a,  $0e,  $e3,  $0b
        byte    $0f,  $c7,  $ff,  $c2,  $c1,  $f3,  $bf,  $07,  $9c,  $ff,  $c5,  $f1,  $83,  $fb,  $5a,  $0e
        byte    $0b,  $98,  $77,  $78,  $19,  $fc,  $ff,  $ff,  $00,  $5f,  $18,  $fc,  $0e,  $7e,  $38,  $00
        byte    $82,  $af,  $18,  $7e,  $e0,  $cb,  $3f,  $fe,  $70,  $4e,  $ff,  $80,  $db,  $e4,  $f1,  $71
        byte    $fc,  $8f,  $9f,  $f3,  $33,  $f0,  $bf,  $02,  $8a,  $c7,  $47,  $11,  $3a,  $2e,  $ff,  $35
        byte    $05,  $e8,  $63,  $ff,  $ff,  $ff,  $ff,  $ff,  $ff,  $f3,  $f7,  $ff,  $7f,  $cb,  $df,  $df
        byte    $e7,  $e1,  $ff,  $3f,  $3f,  $7f,  $8b,  $ff,  $03,  $ec,  $e1,  $f3,  $d1,  $fe,  $f8,  $7f
        byte    $0f,  $fe,  $f9,  $03,  $f8,  $1f,  $fc,  $47,  $d0,  $f8,  $0f,  $00,  $af,  $a9,  $83,  $ff
        byte    $4c,  $fe,  $73,  $01,  $6e,  $c0,  $7f,  $00,  $f8,  $f1,  $d0,  $0a,  $f8,  $fc,  $b4,  $00
        byte    $01,  $b4,  $f9,  $11,  $f8,  $bb,  $f9,  $bf,  $7e,  $7e,  $fc,  $af,  $8f,  $1f,  $fe,  $eb
        byte    $e1,  $07,  $ff,  $3a,  $f8,  $81,  $bf,  $02,  $7e,  $80,  $6f,  $f2,  $5f,  $85,  $1f,  $ff

        byte    $01,  $fe,  $df,  $c1,  $0b,  $fc,  $6f,  $de,  $0b
