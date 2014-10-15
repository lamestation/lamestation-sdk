LameSDK
===============

All the Spin libraries you need to get started using the LameStation right away.

Learn more at [our homepage](http://www.lamestation.com) or check out [the wiki](https://lamestation.atlassian.net/wiki)!

## Getting Started

### LameStation Pinout

```
                        ┏━━━━━━━━━━━━━━┓
           ╭──── D/I ───┨P0         P31┣─── PROP_RX   ────╮ Serial Port
           │       E ───┨P1         P30┣─── PROP_TX   ────╯
           │      D0 ───┨P2         P29┣─── EX_SDA    ────╮ EEPROM
       LCD │      D1 ───┨P3         P28┣─── EX_SCL    ────╯   
           │      D2 ───┨P4         P27┣─── AUDIO_OUT ───── Audio Output
           │      D3 ───┨P5         P26┣─── SW_B      ────╮ Buttons
           │      D4 ───┨P6         P25┣─── SW_A      ────╯
           │      D5 ───┨P7         P24┣─── LED       ───── LED
           ┊            ┃              ┃                 
           ┊         ───┨VSS        VDD┣───              
           ┊         ───┨BOEn        XO┣───              
           ┊         ───┨RESn        XI┣───              
           ┊         ───┨VDD        VSS┣───              
           ┊            ┃              ┃                 
           │      D6 ───┨P8         P23┣─── EX7       ────╮ 
           │      D7 ───┨P9         P22┣─── EX6           │ 
           │     CS1 ───┨P10        P21┣─── EX5           │ 
           ╰──── CS2 ───┨P11        P20┣─── EX4           │ Expansion Port
           ╭──── C_U ───┨P12        P19┣─── EX3           │ 
  Joystick │     C_D ───┨P13        P18┣─── EX2           │ 
           │     C_L ───┨P14        P17┣─── EX1           │ 
           ╰──── C_R ───┨P15        P16┣─── EX0       ────╯
                        ┗━━━━━━━━━━━━━━┛
```
---
