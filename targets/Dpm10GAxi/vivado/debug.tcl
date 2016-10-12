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
SetDebugCoreClk ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/sysClk200}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisSlave[tReady]}


ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/r[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axisSlave[tReady]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiWriteCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiWriteSlave[awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/axiWriteSlave[bvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/dmaReq[request]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/intAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_IbDma/intAxisMaster[tValid]}
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

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/ib[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/ob[state][*]}

# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/mAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/mAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/mAxisSlave[tReady]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/sAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/sAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_ObFifo/sAxisCtrl[pause]}

# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/mAxiReadMaster[arvalid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/mAxiReadMaster[rready]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/mAxiReadSlave[arready]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/mAxiReadSlave[rlast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/mAxiReadSlave[rvalid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/sAxiReadMaster[arvalid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/sAxiReadSlave[arready]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/sAxiReadSlave[rlast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiReadPathFifo/sAxiReadSlave[rvalid]}

# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axiReadMaster[arvalid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axiReadSlave[arready]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axiReadSlave[rlast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axiReadSlave[rvalid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axisCtrl[pause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/axisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/dmaAck[done]}
# ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[3].U_AxiStreamDma/U_ObDma/dmaReq[request]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

#############################################################
#############################################################
#############################################################

# ## Create core
# set ilaName u_ila_1
# CreateDebugCore ${ilaName}

# ## Configure Core
# set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

# ## Setup Clock, Variable set in xdc file
# SetDebugCoreClk ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/ethClk}

# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/ethConfig[dropOnPause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/ethStatus[txPauseCnt]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/ethStatus[txCountEn]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/ethStatus[rxCountEn]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/flowCtrl[overflow]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/flowCtrl[pause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/mPrimCtrl[overflow]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/mPrimCtrl[pause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/mPrimMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/mPrimMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/rxPauseReq}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/rxPauseValue[*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/r[state][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/r[remPreCnt][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/r[remPauseCnt][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/r[locPreCnt][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/r[locPauseCnt][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/pauseTime[*]}

# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/sAxisCtrl[overflow]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/sAxisCtrl[pause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/sAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/sAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/rxMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/rxMaster[tValid]}

# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/txSlave[tReady]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/mAxisSlave[tReady]}

# ## Delete the last unused port
# delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

#############################################################
#############################################################
#############################################################

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${PRJ_VERSION}.ltx

