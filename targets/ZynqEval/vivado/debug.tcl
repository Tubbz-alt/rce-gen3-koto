
# Create core
set ilaName u_ila_0
create_debug_core u_ila_0 labtools_ila_v3

# Configure Core
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

# Configure Clock
set_property port_width 1 [get_debug_ports ${ilaName}/clk]
connect_debug_port ${ilaName}/clk \
   [get_nets U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl/axiClk]

# First probe exists by default
set_property port_width 1 [get_debug_ports ${ilaName}/probe0]
connect_debug_port ${ilaName}/probe0 \
   [get_nets U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl/axiClkRst]

# Debug ACP Write Controller
set modulePath U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl
source ${TOP_DIR}/modules/ArmRceG3/debug/debug_read_cntrl.tcl

# Debug ACP Write Controller
set modulePath U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_WriteCntrl
source ${TOP_DIR}/modules/ArmRceG3/debug/debug_write_cntrl.tcl

# Build the core
implement_debug_core [get_debug_cores]

# Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

