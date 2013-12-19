
# Clocks
create_clock -name dtmClk -period 5 [get_ports dtmClkP[0]]

create_clock -name locRefClk -period 6.4 [get_ports locRefClkP[1]]

set_clock_groups -physically_exclusive -group [get_clocks CLKOUT0]    -group [get_clocks dtmClk]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT0]    -group [get_clocks CLKOUT0_2]
set_clock_groups -physically_exclusive -group [get_clocks CLKOUT1]    -group [get_clocks CLKOUT0_2]
