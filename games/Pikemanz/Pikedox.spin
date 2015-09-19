OBJ
    pk  :   "PikeManager"
    
OBJ    
    pk_player  : "gfx_pk_pakechu2"

    pk1  : "gfx_pk_adheri"
    pk2  : "gfx_pk_blardicuino"
    
    pk3  : "gfx_pk_ghosterman"
    pk4  : "gfx_pk_jarzzard"
    pk5  : "gfx_pk_mootoo"
    pk6  : "gfx_pk_pakechu"
    pk7  : "gfx_pk_pangueen"
    pk8  : "gfx_pk_phonyx"
    pk9  : "gfx_pk_tornadoo"

PUB CreatePikedox
    
    pk.SetPikeman(0, string("PAKECHU"),     20, 10, 32, 50, pk_player.Addr)
    
    pk.SetPikeman(1, string("ADHERI"),      130, 40, 32, 50, pk1.Addr)
    pk.SetPikeman(2, string("BLARDICUINO"), 130, 40, 32, 50, pk2.Addr)
    pk.SetPikeman(3, string("GHOSTERMAN"),  130, 40, 32, 50, pk3.Addr)
    pk.SetPikeman(4, string("JARZZARD"),    130, 40, 32, 50, pk4.Addr)
    pk.SetPikeman(5, string("MOOTOO"),      130, 40, 32, 50, pk5.Addr)
    pk.SetPikeman(6, string("PAKECHU"),     130, 40, 32, 50, pk6.Addr)
    pk.SetPikeman(7, string("PANGUEEN"),    130, 40, 32, 50, pk7.Addr)
    pk.SetPikeman(8, string("PHONYX"),      130, 40, 32, 50, pk8.Addr)
    pk.SetPikeman(9, string("TORNADOO"),    130, 40, 32, 50, pk9.Addr)
