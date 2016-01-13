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
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/axiClk}

#connect_debug_port dbg_hub/clk [get_nets {sysClk200}]

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadMaster[arid]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadMaster[arlen]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadMaster[arsize]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadMaster[arvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadMaster[rready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadSlave[rid]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadSlave[rresp]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadSlave[arready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadSlave[rlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/mAxiReadSlave[rvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiReadPathMux/r[addrState]*}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[awid]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[awlen]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[awsize]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[wid]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[wstrb]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[bready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteMaster[wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteSlave[bid]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteSlave[awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteSlave[bvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/mAxiWriteSlave[wready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/r[dataState]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_AxiWritePathMux/r[addrState]*}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbHeader/U_IbDma/r_reg[ackCount]__0*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbHeader/U_IbDma/r_reg[reqCount]__0*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbHeader/U_IbDma/r_reg[stCount]__0*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force $::env(PROJ_DIR)/debug/debug_probes_$::env(PRJ_VERSION).ltx
