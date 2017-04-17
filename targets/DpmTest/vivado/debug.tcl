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

append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/*}]
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaRead/*}]
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_DmaDesc/*}]
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
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiClk}

## Set the Probes
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiWriteCtrl[pause]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[ackCount][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[awlen][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[continue]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][dropEn]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][inUse]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][overflow]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[dmaWrTrack][dest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[reqCount][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[result][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[slave][tReady]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[state][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][wlast]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][wvalid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/r[wMaster][awvalid]}

#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tDest][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tKeep][*]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tLast]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisMaster[tValid]}
#ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axisSlave[tReady]}

## Delete the last unused port
#delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
#write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

