
## Open the run
open_run synth_1

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 2048 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {axiClk}

ConfigProbe ${ilaName} {crcOut*}       : signal is "true";
ConfigProbe ${ilaName} {crcDataValid}  : signal is "true";
ConfigProbe ${ilaName} {crcDataWidth*} : signal is "true";
ConfigProbe ${ilaName} {crcIn*}        : signal is "true";
ConfigProbe ${ilaName} {crcInAdj*}     : signal is "true";
ConfigProbe ${ilaName} {crcReset}      : signal is "true";
ConfigProbe ${ilaName} {crcCount*}     : signal is "true";

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/debug/debug_probes.ltx

