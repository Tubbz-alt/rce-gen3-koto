
# DTM Clock
create_clock -name dtmClk -period 5 [get_ports dtmClkP[0]]

# PGP Clocks
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

create_generated_clock -name pgpClk250 -source [get_ports locRefClkP] \
    -multiply_by 1 [get_pins U_PgpArray/U_PgpClkGen/CLKOUT0]

set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks fclk0] \
      -group [get_clocks -include_generated_clocks dtmClk] \
      -group [get_clocks -include_generated_clocks locRefClk]

