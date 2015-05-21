---
version: 0.0.0
layout: learnpage
title: "Step 8: Pikemanz"
section: "Section : "


prev_file: "04_Battle.spin.html"
prev_name: "Step 4: Battle"
---

    {{

             `////sMdddddddddddds:   -////.    -od///:         :Mddmh  hmdddNh:
      `..dhyhNsssss++++++++++++osy.ymNNsd+    om+sshmyd-     /dN++hh  hh+++odh
    ooyhhho+++++++++++++++++++++++MMh+++d+   +yy++++ohM:     om+++syo hh++++hh
    Ms+++++osssmmddddddddNds++++++Mmho++d+  Nmy+++sdNMy/.    om++++sM:mh++++hh                 hmhhhm+  Ndo::
    Ms+++++yNMyso//...../smm++++odMsyd++do-yMs+++dNMMMMMdyy  om++hysMMMh++++hh         -yyy/  `hh+++mo  MsohNy.
    +mh+++++ohM:        +yhy+++shh-`od++ydNh++syyhhhhyyyyhh++hm+yNh++Ms+oy++hh   -++++hNh+ys/ Ms++++mo  Ms+oyh-
    `+hd++++++oho. --+hho++++sdmy`  om+++oo++ohd+`dhsMyydm+yNMm+MMh++o++sMNshh -syooyyys+++hh Ms++++mo-mo++sM/` `-
     .+hd++++++sdmsyys+++++odyy+.   oNd+++oddh+.  hhoyyyyhdyNms+Mhhy++++sMMshNsyosddyymm+++hd-Mssdd+my+M++smM  :hMss:
      .+dyo+++++++++++++yhdhydo-    +mM++smMy.    hhsMMmdy: dh++Mshm++++sMMsymM+mh+:  om++sdm+MshMM+mdhM++hm+ .sNd++sddd+///
       `/Ns+++++++++oosdo-+hyosyo   -oM++++sNh/.. hhsMo-....dh++M/sm++++sNMs+sM+ds-...od++mdymsohMM+mMMN+hmh. smdoooooo+oshM
         -shy+++++++mms-  `/hhh+.    :M++sy+++sdMoyhhho..+MhNh++N-om+++hm+Ms+sM++syhhhs+++mmdM+mmdM+mMm+hNh:   `/hhhmNh++syh
          -sds++++++ohmo   `:Ndddm:` .oNsymNdyo+omNdydyhddydNh++M:+ds+shy`Ms+sMdyssssso++sdNmo+myoM+hmh+Mm+     `::ydh+smmh:
           -sM+++++++ohM   .yMs+oyMh/`+Ms+sM.ohh++syydyddhydNhody.-sM+mh: MmysM.oyyyymh++Mshm++mo:M+++++Ms-    /yyyo+odMh/.
            `+Mhs+++++odMs-  dhs++dNo  Ms+sM  ./dMs+++dNms-Ms+sM-` :M+mo  MMhsM      -oddsNmy+Md/:M+++oyM:   +ys+++smNd-`
             `smdo++++++sdms `hmd++oys NmysM    `+hmdoomNy mdddN   -NmMo  MMhsM       ``` hh++Mo.:M+++sM+:odhs++smds+/`
              -smm++++++++hms .sm+++sys-dhoys.    .+dMMMh: -----   `+yy/  MMmdM           hh++M: :M++sdM hmy+++shy-`
               -smM++++++++sdN--sM+syydyNdyyd-      `:::.                 `:::`           hdyyM: :M++hMMNmyoydds-
                -oNo+++++++++Nd+/NdNds/ +sss.                                             +dNNs. :M+hmd/Ns++sddhyyyyho
                 `+Mds+++++ohhNo`----.                                                     .--   :MhNy/hhhhy++++++++hh
                  `odhssshdh+++-                                                                 `+Ms- `+++odddyssssdh
                   ./oyyy:..                                                                       y.      `...+yyyyyo

              The Game!

    -------------------------------------------------
    Version: 1.0
    Copyright (c) 2014 LameStation.
    See end of file for terms of use.

    Authors: Brett Weir
    -------------------------------------------------
    }}

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        lcd         :   "LameLCD"
        gfx         :   "LameGFX"
        audio       :   "LameAudio"
        music       :   "LameMusic"
        ctrl        :   "LameControl"

        state       :   "PikeState"

        title       :   "01_Title"
        intro       :   "02_Intro"
        world       :   "03_World"
        battle      :   "04_Battle"

    PUB Main

        lcd.Start(gfx.Start)
        lcd.SetFrameLimit(lcd#FULLSPEED)
        audio.Start
        music.Start
        ctrl.Start

        world.Init

        state.SetState(state#_TITLE)
        repeat
            case state.State
                state#_TITLE:       title.View
                state#_INTRO:       intro.Scene
                state#_WORLD:       world.View
                state#_BATTLE:      battle.Wild

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
