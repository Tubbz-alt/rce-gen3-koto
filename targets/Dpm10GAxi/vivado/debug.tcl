##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'RCE Development Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set VIVADO_BUILD_DIR $::env(VIVADO_BUILD_DIR)
source -quiet ${VIVADO_BUILD_DIR}/vivado_env_var_v1.tcl
source -quiet ${VIVADO_BUILD_DIR}/vivado_proc_v1.tcl

## Open the run
open_run synth_1

#############################################################
#############################################################
#############################################################

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiClk}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[awlen][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][errorValue][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][firstUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][lastUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaReq][maxSize][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[shift][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/intAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/intAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/dmaReq[request]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiWriteSlave[bvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiWriteCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisSlave[tReady]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][done]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][idle]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][overflow]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaAck][writeError]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaReq][drop]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[dmaReq][request]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[last]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[shiftEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[slave][tReady]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[wMaster][awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[wMaster][bready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[wMaster][wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[wMaster][wvalid]}




## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]


## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${PRJ_VERSION}.ltx

