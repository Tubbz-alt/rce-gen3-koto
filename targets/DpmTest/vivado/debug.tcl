##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################
set RUCKUS_DIR $::env(RUCKUS_DIR)
source -quiet ${RUCKUS_DIR}/vivado_env_var.tcl
source -quiet ${RUCKUS_DIR}/vivado_proc.tcl

## Open the run
open_run synth_1

## Setup configurations
set ilaName u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/axiClk}

## Set the Probes
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/axiRst}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/axiWriteSlave[awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/axiWriteSlave[wready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/rdFifoValid_0}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/rdFifoValid_1}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[rdFifoValidDly][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[rdFifoValidDly][1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/wrFifoValid}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[wrFifoValidDly][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[wrFifoValidDly][1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[acknowledge]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axiWriteMaster][awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axiWriteMaster][bready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axiWriteMaster][wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axiWriteMaster][wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axilReadSlave][arready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axilReadSlave][rvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axilWriteSlave][awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axilWriteSlave][bvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axilWriteSlave][wready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[contEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[descRetNum]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[descState][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[descState][1]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[dmaRdDescReq][0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/dmaRdDescAck[0]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/dmaRdDescRet[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[dmaRdDescRetAck]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/dmaWrDescReq[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[dmaWrDescAck][0][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/dmaWrDescRet[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[dmaWrDescRetAck]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[dropEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[enable]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[intAckEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[intEnable]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[interrupt]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[rdFifoWr][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[rdFifoWr][1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[fifoReset]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_DmaTest/U_DmaDesc/r[axiWriteMaster][awaddr][*]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${PRJ_VERSION}.ltx

