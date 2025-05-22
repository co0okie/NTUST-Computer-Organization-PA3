addiu   $1,     $0,     0x1111      # 0x1111
sw      $1,     0($0)
# EX.Rt == ID.Rs
lw      $2,     0($0)               # 0x1111
addu    $3,     $2,     $0          # 0x1111
# EX.Rt == ID.Rt
lw      $4,     0($0)               # 0x1111
addu    $5,     $0,     $4          # 0x1111
# together
lw      $6,     0($0)               # 0x1111
addu    $7,     $6,     $6          # 0x2222