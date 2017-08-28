## new
create_clock -name gt2k_gtrefclk -period 4 [get_ports locRefClkP]

set gt2k_rxusrclk_pin_0 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[0].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_0 -period 8 $gt2k_rxusrclk_pin_0

set gt2k_rxusrclk_pin_1 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[1].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_1 -period 8 $gt2k_rxusrclk_pin_1

set gt2k_rxusrclk_pin_2 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[2].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_2 -period 8 $gt2k_rxusrclk_pin_2

set gt2k_rxusrclk_pin_3 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[3].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_3 -period 8 $gt2k_rxusrclk_pin_3

set gt2k_rxusrclk_pin_4 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[4].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_4 -period 8 $gt2k_rxusrclk_pin_4

set gt2k_rxusrclk_pin_5 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[5].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_5 -period 8 $gt2k_rxusrclk_pin_5

set gt2k_rxusrclk_pin_6 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[6].gtx_channel/gtxe2_i/RXOUTCLK]
create_clock -name gt2k_rxusrclk_6 -period 8 $gt2k_rxusrclk_pin_6

#new new ones
set gt2k_txusrclk_pin_0 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[0].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_0 -period 8 $gt2k_txusrclk_pin_0

set gt2k_txusrclk_pin_1 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[1].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_1 -period 8 $gt2k_txusrclk_pin_1

set gt2k_txusrclk_pin_2 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[2].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_2 -period 8 $gt2k_txusrclk_pin_2

set gt2k_txusrclk_pin_3 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[3].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_3 -period 8 $gt2k_txusrclk_pin_3

set gt2k_txusrclk_pin_4 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[4].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_4 -period 8 $gt2k_txusrclk_pin_4

set gt2k_txusrclk_pin_5 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[5].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_5 -period 8 $gt2k_txusrclk_pin_5

set gt2k_txusrclk_pin_6 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_gtx[6].gtx_channel/gtxe2_i/TXOUTCLK]
create_clock -name gt2k_txusrclk_6 -period 8 $gt2k_txusrclk_pin_6
#end of this block




#old new ones
#set gt2k_txusrclk_pin_0 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[0].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_0 -period 8 $gt2k_txusrclk_pin_0

#set gt2k_txusrclk_pin_1 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[1].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_1 -period 8 $gt2k_txusrclk_pin_1

#set gt2k_txusrclk_pin_2 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[2].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_2 -period 8 $gt2k_txusrclk_pin_2

#set gt2k_txusrclk_pin_3 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[3].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_3 -period 8 $gt2k_txusrclk_pin_3

#set gt2k_txusrclk_pin_4 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[4].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_4 -period 8 $gt2k_txusrclk_pin_4

#set gt2k_txusrclk_pin_5 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[5].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_5 -period 8 $gt2k_txusrclk_pin_5

#set gt2k_txusrclk_pin_6 [get_pins U_AppCore/Rx2000BaseX_Inst/multi_txoutclk[6].txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk_6 -period 8 $gt2k_txusrclk_pin_6
# end of this block

set_clock_groups -asynchronous \
    -group [get_clocks sysClk125] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_0] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_1] \ 
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_2] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_3] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_4] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_5] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_6]

set_clock_groups -asynchronous \
    -group [get_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_0] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_1] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_2] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_3] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_4] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_5] \
    -group [get_clocks -include_generated_clocks gt2k_rxusrclk_6] 

set_clock_groups -asynchronous \
    -group [get_clocks sysClk125] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_0] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_1] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_2] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_3] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_4] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_5] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_6] 

set_clock_groups -asynchronous \
    -group [get_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_0] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_1] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_2] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_3] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_4] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_5] \
    -group [get_clocks -include_generated_clocks gt2k_txusrclk_6] 

## original
#create_clock -name gt2k_gtrefclk -period 4 [get_ports locRefClkP]

#set gt2k_rxusrclk_pin [get_pins U_AppCore/Rx2000BaseX_Inst/gtx_channel/gtxe2_i/RXOUTCLK]
#create_clock -name gt2k_rxusrclk -period 8 $gt2k_rxusrclk_pin

#set gt2k_txusrclk_pin [get_pins U_AppCore/Rx2000BaseX_Inst/txusrclk_bufg/O]
#create_clock -name gt2k_txusrclk -period 8 $gt2k_txusrclk_pin

#set_clock_groups -asynchronous \
#    -group [get_clocks sysClk125] \
#    -group [get_clocks -include_generated_clocks gt2k_rxusrclk]

#set_clock_groups -asynchronous \
#    -group [get_clocks sysClk200] \
#    -group [get_clocks -include_generated_clocks gt2k_rxusrclk]

#set_clock_groups -asynchronous \
#    -group [get_clocks sysClk125] \
#    -group [get_clocks -include_generated_clocks gt2k_txusrclk]

#set_clock_groups -asynchronous \
#    -group [get_clocks sysClk200] \
#    -group [get_clocks -include_generated_clocks gt2k_txusrclk]