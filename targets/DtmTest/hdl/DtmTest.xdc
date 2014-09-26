
# PGP Clocks
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

create_generated_clock -name pgpClk250 -source [get_ports locRefClkP] \
    -multiply_by 1 [get_pins U_PgpArray/U_PgpClkGen/CLKOUT0]

set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks fclk0] \
      -group [get_clocks -include_generated_clocks locRefClk]

# IO Types
set_property IOSTANDARD LVDS_25  [get_ports dtmToRtmLsP]
set_property IOSTANDARD LVDS_25  [get_ports dtmToRtmLsM]

