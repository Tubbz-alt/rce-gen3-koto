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

# Get a list of nets
set netFile ${PROJ_DIR}/net_log.txt
set fd [open ${netFile} "w"]
puts $fd [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/*}]
puts $fd [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/*}]
puts $fd [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/*}]
close $fd

## Setup configurations
set ilaName u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiClk}

## Set the Probes
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/r[rMaster][araddr][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/r[rMaster][arvalid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/axiReadSlave[rdata][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/axiReadSlave[rlast]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/axiReadSlave[rvalid]}
#
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiWriteCtrl[pause]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiWriteSlave[bresp][0]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiWriteSlave[bresp][1]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiWriteSlave[bvalid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[ackCount][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[awlen][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[continue]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][dropEn]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][inUse]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][overflow]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[reqCount][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[result][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[slave][tReady]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[state][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][wlast]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][wvalid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][awvalid]}
#
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tData][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tKeep][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tLast]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tValid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisSlave[tReady]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/addrRamAddr[*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/addrRamDout[*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[addrFifoSel]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[rdAddr][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[wrAddr][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[rdAddrValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[wrAddrValid]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][buffId][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][continue]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][id][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][lastUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][0][valid]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][buffId][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][continue]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][id][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][lastUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][1][valid]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][buffId][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][continue]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][id][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][lastUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescReq][2][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescAck[0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescAck[1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescAck[2]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescAck][0][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescAck][0][contEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescAck][0][dropEn]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescAck][0][maxSize][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescAck][0][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescReq[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescReq[1][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescReq[2][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrDescReq][dest][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrDescReq][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[1].U_DmaWrite/r[dmaWrDescReq][dest][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[1].U_DmaWrite/r[dmaWrDescReq][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[2].U_DmaWrite/r[dmaWrDescReq][dest][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[2].U_DmaWrite/r[dmaWrDescReq][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/r[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[1].U_DmaRead/r[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[2].U_DmaRead/r[state][*]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][continue]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][lastUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][continue]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][lastUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[1][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][continue]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][firstUser][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][lastUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaWrDescRet[2][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescRetAck][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescRetAck][1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaWrDescRetAck][2]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[0][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[0][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[0][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[1][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[1][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[1][valid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[2][buffId][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[2][result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/dmaRdDescRet[2][valid]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescRetAck][0]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescRetAck][1]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[dmaRdDescRetAck][2]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[descState][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[intReqCount][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[intAckCount][*]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[rdIndex][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/r[wrIndex][*]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

