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
create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

create_generated_clock -name pgpClk -source [get_ports locRefClkP] \
    -multiply_by 5 -divide_by 8 [get_pins U_DevelPgpLane/ClockManager7_1/MmcmGen.U_Mmcm/CLKOUT0]

create_generated_clock -name locClk -source [get_ports locRefClkP] \
    -multiply_by 5 -divide_by 32 [get_pins U_DevelPgpLane/ClockManager7_1/MmcmGen.U_Mmcm/CLKOUT1]

set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks fclk0] \
      -group [get_clocks -include_generated_clocks locRefClk]

set_property PACKAGE_PIN AE8  [get_ports pgpRxP]
set_property PACKAGE_PIN AE7  [get_ports pgpRxM]
set_property PACKAGE_PIN AK2  [get_ports pgpTxP]
set_property PACKAGE_PIN AK1  [get_ports pgpTxM]

