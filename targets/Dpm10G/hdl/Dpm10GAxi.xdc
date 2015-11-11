# PGP Clocks
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

create_generated_clock -name pgpClk -source [get_ports locRefClkP] \
    -multiply_by 5 -divide_by 8 [get_pins ClockManager7_1/MmcmGen.U_Mmcm/CLKOUT0]

set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks fclk0] \
      -group [get_clocks -include_generated_clocks locRefClk]


