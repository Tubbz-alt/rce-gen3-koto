
create_debug_core u_ila_0 labtools_ila_v3

set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]

set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list U_EvalCore/axiClk]]

set p0_list [list {U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_GenFifoGen[0].U_GenFifo/fifoDout*}] 

set_property port_width 72 [get_debug_ports u_ila_0/probe0]
set_property MARK_DEBUG true      [get_nets $p0_list]
connect_debug_port u_ila_0/probe0 [get_nets $p0_list]

set p1_list [list {U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_GenFifoGen[1].U_GenFifo/fifoRd}  \
                  {U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_GenFifoGen[1].U_GenFifo/fifoReady}  \
                  {U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_GenFifoGen[1].U_GenFifo/fifoValid}] 

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
set_property MARK_DEBUG true      [get_nets $p1_list]
connect_debug_port u_ila_0/probe1 [get_nets $p1_list]

set p2_list [list {U_EvalCore/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_GenFifoGen[1].U_GenFifo/dbgState*}]

create_debug_port u_ila_0 probe
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
set_property MARK_DEBUG true      [get_nets $p2_list]
connect_debug_port u_ila_0/probe2 [get_nets $p2_list]

implement_debug_core [get_debug_cores]

write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

