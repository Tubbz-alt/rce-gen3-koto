
# PGP Clocks
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]
set pgpClkGroup [get_clocks -of_objects [get_pins U_RtmTest/U_PgpClkGen/CLKOUT0]]

# Cross Clock Domains
set_clock_groups -asynchronous -group ${dmaClkGroup}    -group ${pgpClkGroup}

set_clock_groups -asynchronous -group ${sysClk125Group} -group ${pgpClkGroup}

set_clock_groups -asynchronous -group ${sysClk200Group} -group ${pgpClkGroup}

# DTM Timing Groups
set_property IODELAY_GROUP "DtmTimingGrp" [get_cells {U_DtmTimingSource/U_DlyCntrl}]
set_property IODELAY_GROUP "DtmTimingGrp" [get_cells -hier -filter {name =~ *U_OpCodeSink/IDELAYE2_inst}]

# IO Types
set_property IOSTANDARD LVCMOS25 [get_ports led]
set_property IOSTANDARD LVDS_25  [get_ports dtmToRtmLsP]
set_property IOSTANDARD LVDS_25  [get_ports dtmToRtmLsM]
set_property IOSTANDARD LVDS_25  [get_ports dpmClkP]
set_property IOSTANDARD LVDS_25  [get_ports dpmClkM]
set_property IOSTANDARD LVDS_25  [get_ports dpmFbP]
set_property IOSTANDARD LVDS_25  [get_ports dpmFbM]
set_property IOSTANDARD LVCMOS25 [get_ports plSpareP]
set_property IOSTANDARD LVCMOS25 [get_ports plSpareM]

