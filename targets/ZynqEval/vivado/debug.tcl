
## Open the run
open_run synth_1

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 2048 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {sysClk125}

ConfigProbe ${ilaName} {crcOut*}
ConfigProbe ${ilaName} {crcDataValid}
ConfigProbe ${ilaName} {crcDataWidth*}
ConfigProbe ${ilaName} {crcIn*} 
ConfigProbe ${ilaName} {crcInAdj*}
ConfigProbe ${ilaName} {crcReset}
ConfigProbe ${ilaName} {crcCount*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

