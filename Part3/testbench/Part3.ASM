addiu $R01, $R0, 1         
addiu $R02, $R0, 2         
addu  $R03, $R01, $R02     
subu  $R04, $R03, $R02     
sw    $R04, 0($R0)         
lw    $R05, 0($R0)         
ori   $R06, $R05, 0x0100   
addu  $R07, $R06, $R01     
