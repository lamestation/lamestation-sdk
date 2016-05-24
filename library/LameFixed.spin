DAT

    precision   byte    4
        
PUB SetPrecision(value)

    precision := value & $1F
    
PUB Fixed(value)

    return value << precision    
    
PUB Integer(value)

    return value >> precision

PUB Fraction(value)

    return value & ((2 << precision)-1)

PUB Range

    return (2 << (32 - precision))
    