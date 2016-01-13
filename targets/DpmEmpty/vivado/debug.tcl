##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Get environment
set TOP_DIR  $::env(TOP_DIR)
set PROJ_DIR $::env(PROJ_DIR)

# Open the run
open_run synth_1

# Create core
set ilaName u_ila_0
create_debug_core ${ilaName} labtools_ila_v3

# Configure Core
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

# Configure Clock
set_property port_width 1 [get_debug_ports ${ilaName}/clk]
connect_debug_port ${ilaName}/clk \
   [get_nets U_DpmCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl/axiClk]

# First probe exists by default
set_property port_width 1 [get_debug_ports ${ilaName}/probe0]
connect_debug_port ${ilaName}/probe0 \
   [get_nets U_DpmCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl/axiClkRst]

# Debug ACP Write Controller
set modulePath U_DpmCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl
source ${TOP_DIR}/modules/ArmRceG3/debug/debug_read_cntrl.tcl

# Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

