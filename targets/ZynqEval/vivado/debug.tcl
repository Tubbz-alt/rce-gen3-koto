
## Open the run
open_run synth_1

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 2048 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} [get_nets -of_objects ${axiClkGroup}]

## Read Controller
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[arvalid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[araddr]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[arid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[arlen]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[arcache]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadToArm[rready]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadFromArm[arready]}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadFromArm[rdata]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadFromArm[rlast]}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadFromArm[rvalid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveReadFromArm[rid]*}

## Write Controller
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[awvalid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[awaddr]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[awid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[awlen]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[awcache]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[wdata]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[wlast]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[wvalid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[wstrb]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteToArm[wid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteFromArm[awready]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteFromArm[wready]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteFromArm[bvalid]*}
ConfigProbe ${ilaName} {U_EvalCore/U_ArmRceG3Top/axiAcpSlaveWriteFromArm[bid]*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

