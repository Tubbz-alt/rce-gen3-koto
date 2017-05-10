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
set IMAGENAME  $::env(IMAGENAME)
source -quiet ${RUCKUS_DIR}/vivado_env_var.tcl
source -quiet ${RUCKUS_DIR}/vivado_proc.tcl

## Open the run
open_run synth_1

# Get a list of nets
set netFile ${PROJ_DIR}/net_log.txt
set fd [open ${netFile} "w"]
set nl ""
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/*}]
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/*} ]
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/*} ]
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/*}]
append nl [get_nets {U_DpmCore/*}]
append nl [get_nets *]

regsub -all -line { } $nl "\n" nl
puts $fd $nl
close $fd

## Setup configurations
set ilaName u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {sysClk200}

## Set the Probes
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[ackCount][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[awlen][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[continue]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][address][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][dropEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][inUse]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][overflow]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][dest][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[reqCount][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[result][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[slave][tReady]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[wMaster][wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[wMaster][wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[wMaster][wstrb][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/r[wMaster][awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteCtrl[pause]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tDest][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisSlave[tReady]}

ConfigProbe ${ilaName} {prbsAxisMaster[0][tLast]}
ConfigProbe ${ilaName} {prbsAxisMaster[0][tValid]}
ConfigProbe ${ilaName} {prbsAxisMaster[1][tLast]}
ConfigProbe ${ilaName} {prbsAxisMaster[1][tValid]}
ConfigProbe ${ilaName} {prbsAxisSlave[0][tReady]}
ConfigProbe ${ilaName} {prbsAxisSlave[1][tReady]}

ConfigProbe ${ilaName} {dmaIbMaster[2][tLast]}
ConfigProbe ${ilaName} {dmaIbMaster[2][tValid]}
ConfigProbe ${ilaName} {dmaIbSlave[2][tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[awid][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[wid][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteMaster[wstrb][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteSlave[awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteSlave[bvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/axiWriteSlave[wready]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[0][awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[0][wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[0][wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[0][wstrb][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteSlave[0][awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteSlave[0][wready]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[1][awvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[1][wlast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[1][wvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteMaster[1][wstrb][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteSlave[1][awready]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[2].U_RceG3DmaAxisChan/intWriteSlave[1][wready]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

