CON
    A_OFFSET = 0
    D_OFFSET = 7
    S_OFFSET = 14
    R_OFFSET = 21
    W_OFFSET = 28

CON
    TUBULAR_BELLS   = (127 + (  4 << D_OFFSET) + ( 80 << S_OFFSET) + (  0 << R_OFFSET) + (  3 << W_OFFSET))
    JARNSICHORD     = (127 + ( 41 << D_OFFSET) + ( 60 << S_OFFSET) + (  0 << R_OFFSET) + (  0 << W_OFFSET))
    SUPER_SQUARE    = ( 10 + (127 << D_OFFSET) + (  0 << S_OFFSET) + (  0 << R_OFFSET) + (  1 << W_OFFSET))
    NO_RELEASE      = (127 + ( 12 << D_OFFSET) + (  0 << S_OFFSET) + (  0 << R_OFFSET) + (  0 << W_OFFSET))
    POWER           = (127 + ( 12 << D_OFFSET) + (127 << S_OFFSET) + (  0 << R_OFFSET) + (  0 << W_OFFSET))
    ACCORDION       = (127 + ( 12 << D_OFFSET) + (127 << S_OFFSET) + ( 64 << R_OFFSET) + (  5 << W_OFFSET))