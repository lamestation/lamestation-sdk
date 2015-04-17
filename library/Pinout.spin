' The LameStation pinout is defined in a separate file to
' make cross-compatibility between board versions easier.
'
' Applicable boards:
' - P5
' - RC1
' - RC2
'
'                              ┏━━━━━━━━━━━━━━┓
'           ╭────       D/I ───┨P0         P31┣─── RX        ────╮ Serial Port
'           │             E ───┨P1         P30┣─── TX        ────╯
'           │            D0 ───┨P2         P29┣─── SDA       ────╮ EEPROM
'       LCD │            D1 ───┨P3         P28┣─── SCL       ────╯   
'           │            D2 ───┨P4         P27┣─── AUDIO     ───── Audio Output
'           │            D3 ───┨P5         P26┣─── BUTTON_B  ────╮ Buttons
'           │            D4 ───┨P6         P25┣─── BUTTON_A  ────╯
'           │            D5 ───┨P7         P24┣─── LED       ───── LED
'           ┊                  ┃              ┃                 
'           ┊               ───┨VSS        VDD┣───              
'           ┊               ───┨BOEn        XO┣───              
'           ┊               ───┨RESn        XI┣───              
'           ┊               ───┨VDD        VSS┣───              
'           ┊                  ┃              ┃                 
'           │            D6 ───┨P8         P23┣─── EX7       ────╮ 
'           │            D7 ───┨P9         P22┣─── EX6           │ 
'           │           CSA ───┨P10        P21┣─── EX5           │ 
'           ╰────       CSB ───┨P11        P20┣─── EX4           │ Expansion Port
'           ╭────    JOY_UP ───┨P12        P19┣─── EX3           │ 
'  Joystick │      JOY_DOWN ───┨P13        P18┣─── EX2           │ 
'           │      JOY_LEFT ───┨P14        P17┣─── EX1           │ 
'           ╰──── JOY_RIGHT ───┨P15        P16┣─── EX0       ────╯
'                              ┗━━━━━━━━━━━━━━┛
'
CON
' LCD pins
' -------------------------
    DI          = 0
    E           = 1

    D0          = 2
    D1          = 3
    D2          = 4
    D3          = 5
    D4          = 6
    D5          = 7
    D6          = 8
    D7          = 9

    CSA         = 10
    CSB         = 11

' Joystick pins
' -------------------------
    JOY_UP      = 12
    JOY_DOWN    = 13
    JOY_LEFT    = 14
    JOY_RIGHT   = 15

' Expansion Port
' -------------------------
    EX0         = 16
    EX1         = 17
    EX2         = 18
    EX3         = 19
    EX4         = 20
    EX5         = 21
    EX6         = 22
    EX7         = 23

' Software-controlled LED
' -------------------------
    LED         = 24

' Buttons
' -------------------------
    BUTTON_A    = 25
    BUTTON_B    = 26

' Audio output
' -------------------------
    AUDIO       = 27

' EEPROM
' -------------------------
    SDA         = 28
    SCL         = 29

' Serial port
' -------------------------
    TX          = 30
    RX          = 31

PUB null
