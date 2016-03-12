##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

## Open the run
open_run synth_1

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]
#set_property C_ADV_TRIGGER  true [get_debug_cores ${ilaName}]
#set_property C_EN_STRG_QUAL true [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {PpiPgpArray_1/U_PpiMonitor/ppiClk}

ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[inFrame]}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[chanInFrame]*}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[currDest]*}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[currSub]*}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[currFirst]*}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[currValid]}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[currEOF]}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[errorDet]}
ConfigProbe ${ilaName} {PpiPgpArray_1/U_PpiMonitor/r[errorDetCnt]*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force $::env(PROJ_DIR)/debug/debug_probes_$::env(PRJ_VERSION).ltx
