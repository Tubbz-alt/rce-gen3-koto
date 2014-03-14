
# DTM Clock
create_clock -name dtmClk -period 5 [get_ports dtmClkP[0]]

# PGP Clocks
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP[1]]
set pgpClkGroup [get_clocks -of_objects [get_pins U_RtmTest/U_PgpClkGen/CLKOUT0]]

# Cross Clock Domains
set_clock_groups -asynchronous -group ${dmaClkGroup}    -group [get_clocks {dtmClk}]
set_clock_groups -asynchronous -group ${dmaClkGroup}    -group ${pgpClkGroup}

set_clock_groups -asynchronous -group ${sysClk125Group} -group [get_clocks {dtmClk}]
set_clock_groups -asynchronous -group ${sysClk125Group} -group ${pgpClkGroup}

set_clock_groups -asynchronous -group ${sysClk200Group} -group [get_clocks {dtmClk}]
set_clock_groups -asynchronous -group ${sysClk200Group} -group ${pgpClkGroup}

# DPM Timing Groups
set_property IODELAY_GROUP "DpmTimingGrp" [get_cells {U_DpmTimingSink/U_DlyCntrl}]
set_property IODELAY_GROUP "DpmTimingGrp" [get_cells -hier -filter {name =~ *U_OpCodeSink/IDELAYE2_inst}]

# IO Standard
set_property IOSTANDARD LVCMOS25 [get_ports led]

set_property IOSTANDARD LVDS_25 [get_ports dtmClkP]
set_property IOSTANDARD LVDS_25 [get_ports dtmClkM]

set_property IOSTANDARD LVDS_25 [get_ports dtmFbP]
set_property IOSTANDARD LVDS_25 [get_ports dtmFbM]

