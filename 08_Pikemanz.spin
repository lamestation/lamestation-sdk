{

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
}

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
