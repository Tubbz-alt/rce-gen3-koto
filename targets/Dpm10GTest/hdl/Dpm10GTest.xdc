##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
# PGP Clocks
#create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

#create_generated_clock -name pgpClk -source [get_ports locRefClkP] \
    #-multiply_by 5 -divide_by 8 [get_pins U_DevelPgpLane/ClockManager7_1/MmcmGen.U_Mmcm/CLKOUT0]

#create_generated_clock -name locClk -source [get_ports locRefClkP] \
    #-multiply_by 5 -divide_by 32 [get_pins U_DevelPgpLane/ClockManager7_1/MmcmGen.U_Mmcm/CLKOUT1]

create_clock -name ethClk   -period 6.4 [get_pins U_10GigE/TenGigEthGtx7Clk_Inst/IBUFDS_GTE2_Inst/ODIV2]
create_clock -name ethTxClk -period 3.103 [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}]
create_clock -name ethRxClk -period 3.103 [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK}]

set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks sysClk200] \
      -group [get_clocks -include_generated_clocks sysClk125] \
      -group [get_clocks -include_generated_clocks ethRefClk] \
      -group [get_clocks -include_generated_clocks ethClk]    \
      -group [get_clocks -include_generated_clocks ethRxClk] \
      -group [get_clocks -include_generated_clocks ethTxClk] 

set_property PACKAGE_PIN AE8  [get_ports extRxP]
set_property PACKAGE_PIN AE7  [get_ports extRxM]
set_property PACKAGE_PIN AK2  [get_ports extTxP]
set_property PACKAGE_PIN AK1  [get_ports extTxM]

