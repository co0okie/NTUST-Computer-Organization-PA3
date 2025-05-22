# MEM -> EX forward
addiu   $1,     $0,     0x1111  # 0x1111
addu    $2,     $1,     $0      # 0x1111
addu    $3,     $0,     $2      # 0x1111
addu    $4,     $3,     $3      # 0x2222
# WB -> EX forward
addu    $5,     $3,     $0      # 0x1111
addu    $6,     $0,     $4      # 0x2222
addu    $7,     $5,     $5      # 0x2222
# together
addu    $7,     $7,     $7      # 0x4444
addu    $7,     $7,     $7      # 0x8888