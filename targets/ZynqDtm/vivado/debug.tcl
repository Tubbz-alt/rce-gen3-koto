
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
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadFromArm[1][arvalid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadFromArm[1][araddr]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadFromArm[1][rready]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadFromArm[1][arid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadToArm[1][arready]}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadToArm[1][rdata]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadToArm[1][rvalid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadToArm[1][rresp]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterReadToArm[1][rid]*}

## Write Controller
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteFromArm[1][awvalid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteFromArm[1][awaddr]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteFromArm[1][wdata]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteFromArm[1][wvalid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteFromArm[1][awid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteToArm[1][awready]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteToArm[1][wready]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteToArm[1][bvalid]*}
ConfigProbe ${ilaName} {U_DtmCore/U_ArmRceG3Top/axiGpMasterWriteToArm[1][bid]*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

