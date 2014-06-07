'
'Jim Bagley's 3D Monster Maze-esque Demo
'Version: 1.0
'
CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

OBJ
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX" 
        ctrl    :               "LameControl"

VAR

    byte    gfx_map[16*16]
    long    gfx_maze[2*32]
    word    buffer[1024]
    long    screen

    long    gameframe
    long    sptr,cptr

    long    oldl,newl
    long    oldr,newr
    long    oldf,newf
    long    oldb,newb
    long    old1,new1
    long    old2,new2
    word    dir
    word    counter
    byte    xpos,ypos
    byte    rexx,rexy
    long    xstp,ystp
    long    rexxstp,rexystp
    word    rexframe,rexcount,rexspeed,gameover

PUB Game | x,y,t
    screen := lcd.Start
    gfx.Start(@buffer,screen)

    longfill(@gfx_maze,0,64)
    repeat y from 0 to 31
      gfx_maze[(y<<1)+0]:=0
      gfx_maze[(y<<1)+1]:=0
      repeat x from 0 to 31
        gfx_maze[(y<<1)+(x>>4)]|=(getmap(x,y)<<(((x)&15)<<1))

    repeat
      ctrl.Update
      repeat y from 0 to 31
        repeat x from 0 to 1
          long[@buffer][(y*8)+(x+4)]:=gfx_maze[y*2+x]
      gfx.Sprite(@gfx_clown1,0,0,0)
      gfx.TranslateBuffer(@buffer, screen)
      gfx.ClearScreen

      old1:=new1
      old2:=new2
      new1:=ctrl.A
      new2:=ctrl.B
      if (new1) and (!old1)
        repeat 50*3
          repeat y from 0 to 31
            repeat x from 0 to 1
              long[@buffer][(y*8)+(x+4)]:=gfx_maze[y*2+x]
          gfx.Sprite(@gfx_clown1,0,0,1)
          gfx.TranslateBuffer(@buffer, screen)
          gfx.ClearScreen

        PlayGame

PUB ShowEaten
    repeat 50*3
      longfill(@buffer,0,512)
      gfx.Sprite(@gfx_clown1,0,0,3)
      gfx.TranslateBuffer(@buffer, screen)
      gfx.ClearScreen
    repeat 50*10
      longfill(@buffer,0,512)
      gfx.Sprite(@gfx_clown1,0,0,2)
      gfx.TranslateBuffer(@buffer, screen)
      gfx.ClearScreen
    gameover:=1

PUB PlayGame | x,y,t,done
    xpos := 1
    ypos := 1
    dir :=1
    newl := newr := newf := newb :=0

    rexx:=30
    rexy:=30
    rexxstp:=0
    rexystp:=-1
    rexframe:=0
    rexcount:=0
    rexspeed:=2

    gameover:=0
    done:=0
    repeat while !done
      waitcnt(clkfreq/1000 + cnt)
      ctrl.Update

      dir&=3
      if dir==0
        xstp:=0
        ystp:=-1
      if dir==1
        xstp:=1
        ystp:=0
      if dir==2
        xstp:=0
        ystp:=1
      if dir==3
        xstp:=-1
        ystp:=0
      repeat x from 0 to 5
        gfx_whatcansee[(5-x)*3+0]:=getmap(xpos+(xstp*x)+ystp,ypos+(ystp*x)-xstp)
        gfx_whatcansee[(5-x)*3+1]:=getmap(xpos+(xstp*x)     ,ypos+(ystp*x)     )
        gfx_whatcansee[(5-x)*3+2]:=getmap(xpos+(xstp*x)-ystp,ypos+(ystp*x)+xstp)

      bytefill(@gfx_map,0,16*16)
      if gfx_whatcansee[0]
        putleftwall(0,7,7,2,1,gfx_whatcansee[1])
      if gfx_whatcansee[2]
        putrightwall(9,7,7,2,1,gfx_whatcansee[1])
      putwall(7,7,2,2,gfx_whatcansee[1])

      if gfx_whatcansee[3]
        putleftwall(0,6,6,4,1,gfx_whatcansee[4])
      if gfx_whatcansee[5]
        putrightwall(10,6,6,4,1,gfx_whatcansee[4])
      putwall(6,6,4,4,gfx_whatcansee[4])

      if gfx_whatcansee[6]
        putleftwall(0,5,5,6,1,gfx_whatcansee[7])
      if gfx_whatcansee[8]
        putrightwall(11,5,5,6,1,gfx_whatcansee[7])
      putwall(5,5,6,6,gfx_whatcansee[7])

      if gfx_whatcansee[9]
        putleftwall(0,3,3,10,2,gfx_whatcansee[10])
      if gfx_whatcansee[11]
        putrightwall(13,3,3,10,2,gfx_whatcansee[10])
      putwall(3,3,10,10,gfx_whatcansee[10])

      if gfx_whatcansee[12]
        putleftwall(0,1,1,14,2,gfx_whatcansee[13])
      if gfx_whatcansee[14]
        putrightwall(15,1,1,14,2,gfx_whatcansee[13])
      putwall(1,1,14,14,gfx_whatcansee[13])

      if gfx_whatcansee[15]
        gfx_map[$00]:=1
        repeat y from 1 to 14
          gfx_map[y<<4+0]:=2
        gfx_map[$f0]:=3
      if gfx_whatcansee[17]
        gfx_map[$0f]:=$09
        repeat y from 1 to 14
          gfx_map[y<<4+$0f]:=$0a
        gfx_map[$ff]:=$0b

      repeat x from 0 to 15
        sptr:=x<<1+@buffer
        repeat y from 0 to 15
          cptr:=@gfx_chars[gfx_map[y<<4+x]<<2]
          word[sptr][$00]:=word[cptr][0]
          word[sptr][$10]:=word[cptr][1]
          word[sptr][$20]:=word[cptr][2]
          word[sptr][$30]:=word[cptr][3]
          cptr+=8
          sptr+=$80

      if (rexx==(xpos+(xstp*1))) and (rexy==(ypos+(ystp*1)))
        gfx.Sprite(@gfx_clown1,0,0,gfx_frames[6+rexframe])
      if gfx_whatcansee[13]==0
        if (rexx==(xpos+(xstp*2))) and (rexy==(ypos+(ystp*2)))
          gfx.Sprite(@gfx_clown1,0,0,gfx_frames[4+rexframe])
        if gfx_whatcansee[10]==0
          if (rexx==(xpos+(xstp*3))) and (rexy==(ypos+(ystp*3)))
            gfx.Sprite(@gfx_clown1,0,0,gfx_frames[2+rexframe])
          if gfx_whatcansee[7]==0
            if (rexx==(xpos+(xstp*4))) and (rexy==(ypos+(ystp*4)))
              gfx.Sprite(@gfx_clown1,0,0,gfx_frames[0+rexframe])

      oldr:=newr
      oldl:=newl
      oldf:=newf
      oldb:=newb
      newr:=ctrl.Right
      newl:=ctrl.Left
      newf:=ctrl.Up
      newb:=ctrl.Down
      if (newf) and (getmap(xpos+xstp,ypos+ystp)==3)
        done:=1
        return
      if (newb) and (getmap(xpos-xstp,ypos-ystp)==3)
        done:=1
        return
      if (newf) and (getmap(xpos+xstp,ypos+ystp)==0)
        xpos+=xstp
        ypos+=ystp
      if (newb) and (getmap(xpos-xstp,ypos-ystp)==0)
        xpos-=xstp
        ypos-=ystp
      if newr<>0 and oldr==0
        dir++
      if newl<>0 and oldl==0
        dir--
      dir&=3

      t:=ypos-8
      if t<0
        t:=0
      if t>16
        t:=16
      repeat y from 0 to 15
        repeat x from 0 to 1
          long[@buffer][((y+48)*8)+(x+3)]:=gfx_maze[(y+t)*2+x]
      if gameframe&4
        plot(xpos+48,ypos-t+48,1)
        plot(xpos+xstp+48,ypos+ystp+48-t,3)
      if(((rexy-t)>0) and ((rexy-y)<48))
        plot(rexx+48,rexy-t+48,1)
        plot(rexx+rexxstp+48,rexy+rexystp+48-t,3)

      gameframe++
      gfx.TranslateBuffer(@buffer, screen)
      gfx.ClearScreen

      rexcount++
      if rexcount>rexspeed
        rexcount:=0
        rexframe++
        if rexframe>1
          rexframe:=0
          if rexxstp==0
            if (rexx>xpos) and (getmap(rexx-1,rexy) == 0)
              rexxstp:=-1
              rexystp:=0
            if (rexx<xpos) and (getmap(rexx+1,rexy) == 0)
              rexxstp:=1
              rexystp:=0
          else
            if (rexy>ypos) and (getmap(rexx,rexy-1) == 0)
              rexxstp:=0
              rexystp:=-1
            if (rexy<ypos) and (getmap(rexx,rexy+1) == 0)
              rexxstp:=0
              rexystp:=1
          if getmap(rexx+rexxstp,rexy+rexystp)
            if rexxstp==0
              if getmap(rexx-1,rexy) == 0
                rexxstp:=-1
                rexystp:=0
              if getmap(rexx+1,rexy) == 0
                rexxstp:=1
                rexystp:=0
            else
              if getmap(rexx,rexy-1) == 0
                rexxstp:=0
                rexystp:=-1
              if getmap(rexx,rexy+1) == 0
                rexxstp:=0
                rexystp:=1
          rexx+=rexxstp
          rexy+=rexystp

      counter++
      if counter>3000
        counter:=0
        if rexspeed>0
          rexspeed--


      if rexx==xpos and rexy==ypos
        ShowEaten
        return

PUB plot(x,y,c)
  if x<0 or x>127 or y<0 or y>63
    return
  buffer[y*16+x>>3]&=-1-(3<<((x&7)<<1))
  buffer[y*16+x>>3]|=c<<((x&7)<<1)

PUB putbox(ptr,x,y,w,h) | tx,ty
  repeat ty from 0 to h-1
    repeat tx from 0 to w-1
      gfx_map[(y+ty)<<4+x+tx]:=byte[ptr++]

PUB putwall(x,y,w,h,t) | tx,ty,ptr
  if t==3
    putexit(x,y,w,h)
    return
  if t==0
    return
  ptr:=@gfx_map[y<<4+x]
  byte[ptr++]:=$0d
  if w>2
    repeat tx from 1 to w-2
      byte[ptr++]:=$06
  byte[ptr++]:=$05
  ptr+=16-w
  if h>2
    repeat ty from 1 to h-2
      byte[ptr++]:=$0a
      if w>2
        repeat tx from 1 to w-2
          byte[ptr++]:=$0c
      byte[ptr++]:=$02
      ptr+=16-w
  byte[ptr++]:=$0f
  if w>2
    repeat tx from 1 to w-2
      byte[ptr++]:=$08
  byte[ptr++]:=$07

PUB putleftwall(x,y,w,h,t,m) | tx,ty,ptr
  ptr:=@gfx_map[y<<4+x]
  if w>1
    repeat tx from 0 to w-2
      byte[ptr++]:=$06
  if m
    byte[ptr++]:=$06
  else
    byte[ptr++]:=$05
  byte[ptr]:=$01
  if t==2
    byte[ptr+1+16]:=$01
  ptr+=16-w
  if h>2
    repeat ty from 1 to h-2
      if w>1
        repeat tx from 0 to w-2
          byte[ptr++]:=$0c
      if m
        byte[ptr++]:=$0c
      else
        byte[ptr++]:=$02
      if t==2
       byte[ptr]:=$0c
       if ty>1
        byte[ptr+1]:=$02
      else
        byte[ptr]:=$02
      ptr+=16-w
  if w>1
    repeat tx from 0 to w-2
      byte[ptr++]:=$08
  if m
    byte[ptr++]:=$08
  else
    byte[ptr++]:=$07
  byte[ptr]:=$03
  if t==2
    byte[ptr+1-16]:=$03

PUB putrightwall(x,y,w,h,t,m) | tx,ty,ptr
  ptr:=@gfx_map[y<<4+x]
  byte[ptr-1]:=$09
  if t==2
    byte[ptr-2+16]:=$09
  if m
    byte[ptr++]:=$06
  else
    byte[ptr++]:=$0d
  if w>1
    repeat tx from 1 to w-1
      byte[ptr++]:=$06
  ptr+=16-w
  if h>2
    repeat ty from 1 to h-2
      if t==2
        byte[ptr-1]:=$0c
        if ty>1
          byte[ptr-2]:=$0a
      else
        byte[ptr-1]:=$0a
      if m
        byte[ptr++]:=$0c
      else
        byte[ptr++]:=$0a
      if w>1
        repeat tx from 1 to w-1
          byte[ptr++]:=$0c
      ptr+=16-w
  byte[ptr-1]:=$0b
  if t==2
    byte[ptr-18]:=$0b
  if m
    byte[ptr++]:=$08
  else
    byte[ptr++]:=$0f
  if w>1
    repeat tx from 1 to w-1
      byte[ptr++]:=$08

PUB putexit(x,y,w,h) | ptr, i, j,k
  ptr := @gfx_map[y<<4+x]
  j:=(gameframe&3)+$11
  repeat k from 0 to h-2 step 2
    repeat i from 0 to w-2
      byte[ptr]:=j
      ptr++
    repeat i from 0 to w-2
      byte[ptr]:=j
      ptr+=16
    repeat i from 0 to w-2
      byte[ptr]:=j
      ptr--
    repeat i from 0 to w-2
      byte[ptr]:=j
      ptr-=16
    ptr+=17
    w-=2
    j:=(j&3)+$11

PUB getmap(mx,my)
  return (gfx_arena[((my&31)<<1)+((mx&16)>>4)]>>((15-(mx&15))<<1)) & 3

DAT

gfx_whatcansee  byte    1,0,1, 1,0,1, 1,0,1, 1,0,1, 1,0,1, 1,0,1

gfx_arena       long    %%1111111111111111,%%1111111111111111
                long    %%1000000000000000,%%0000000000000001
                long    %%1011111111110111,%%1111111111111101
                long    %%1010000000000100,%%0000000000000101
                long    %%1010111111111101,%%0101111111110101
                long    %%1010000000000001,%%0100000100000101
                long    %%1011111111111111,%%0111111101111101
                long    %%1010000000000000,%%0000000001000001
                long    %%1011111111111111,%%1111111101011101
                long    %%1010000000000000,%%0100000101000101
                long    %%1010111101111111,%%0101110101110101
                long    %%1010100000000001,%%0101000100010101
                long    %%1010101111101101,%%0101011111010101
                long    %%1010101000000101,%%0101000001010101
                long    %%1010101011110101,%%0101111100000101
                long    %%1010001013110100,%%0100000111111101
                long    %%1010101010110101,%%0111110000000101
                long    %%1010101010110101,%%0000011111110101
                long    %%1010101010110101,%%0111000100010101
                long    %%1010101010110101,%%0001010101010101
                long    %%1010101000000101,%%0101010001000101
                long    %%1010001011111100,%%0101011111111101
                long    %%1010101000000001,%%0101000000000101
                long    %%1010101111111111,%%0101111111110101
                long    %%1010100000000000,%%0100010000010101
                long    %%1010111111111111,%%1101010101010101
                long    %%1010000000000000,%%0001000101010101
                long    %%1010111111111111,%%1111111101010101
                long    %%1010000000000000,%%0000000001000101
                long    %%1011111111111111,%%1111111111111101
                long    %%1000000000000000,%%0000000000000001
                long    %%1111111111111111,%%1111111111111111

gfx_chars       word    %%00000000 '0
                word    %%00000000
                word    %%00000000
                word    %%00000000

                word    %%00000011 '1
                word    %%00001133
                word    %%00113333
                word    %%11333333

                word    %%11333333 '2
                word    %%11333333
                word    %%11333333
                word    %%11333333

                word    %%11333333 '3
                word    %%00113333
                word    %%00001133
                word    %%00000011

                word    %%33333333 '4
                word    %%33333333
                word    %%33333333
                word    %%33333333

                word    %%11111111 '5
                word    %%11333333
                word    %%11333333
                word    %%11333333

                word    %%11111111 '6
                word    %%33333333
                word    %%33333333
                word    %%33333333

                word    %%11333333 '7
                word    %%11333333
                word    %%11333333
                word    %%11111111

                word    %%33333333 '8
                word    %%33333333
                word    %%33333333
                word    %%11111111

'-----
                word    %%11000000 '9
                word    %%33110000
                word    %%33331100
                word    %%33333311

                word    %%33333311 'a
                word    %%33333311
                word    %%33333311
                word    %%33333311

                word    %%33333311 'b
                word    %%33331100
                word    %%33110000
                word    %%11000000

                word    %%33333333 'c
                word    %%33333333
                word    %%33333333
                word    %%33333333

                word    %%11111111 'd
                word    %%33333311
                word    %%33333311
                word    %%33333311

                word    %%11111111 'e
                word    %%33333333
                word    %%33333333
                word    %%33333333

                word    %%33333311 'f
                word    %%33333311
                word    %%33333311
                word    %%11111111

                word    %%33333333 '10
                word    %%33333333
                word    %%33333333
                word    %%11111111

                word    %%33333333
                word    %%33333333
                word    %%33333333
                word    %%33333333

                word    %%22222222
                word    %%22222222
                word    %%22222222
                word    %%22222222

                word    %%11111111
                word    %%11111111
                word    %%11111111
                word    %%11111111

                word    %%00000000
                word    %%00000000
                word    %%00000000
                word    %%00000000

gfx_frames byte 9,9,9,8,7,6,5,4

gfx_clown1
word 2048
word 128,64
  file "clown1.bit" ' 0
  file "clown2.bit" ' 1
  file "eaten2.bit" ' 2
  file "eaten1.bit" ' 3
  file "trex12.bit" ' 4
  file "trex11.bit" ' 5
  file "trex22.bit" ' 6
  file "trex21.bit" ' 7
  file "trex32.bit" ' 8
  file "trex31.bit" ' 9
'  file "trex42.bit" '10

'
'---------------
'

