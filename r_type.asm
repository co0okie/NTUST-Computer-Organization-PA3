addiu   $1,     $0,     1
addiu   $2,     $0,     2
addiu   $3,     $0,     0xffff
addiu   $4,     $0,     0x0f0f
addiu   $5,     $0,     0x00ff
addu    $27,    $1,     $3      # 0x00010000
subu    $28,    $1,     $3      # 0xffff0002
sll     $29,    $2,     30      # 0x80000000
sll     $30,    $2,     31      # 0x00000000
or      $31,    $4,     $5      # 0x00000fff