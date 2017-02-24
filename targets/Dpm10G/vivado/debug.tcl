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
puts $fd [get_nets {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/*}]
close $fd

## Setup configurations
#set ilaName u_ila_0

## Create the core
#CreateDebugCore ${ilaName}

## Set the record depth
#set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

## Set the clock for the Core
#SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_V2Gen/U_ChanGen[0].U_DmaWrite/axiClk}

## Set the Probes
#ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/}

## Delete the last unused port
#delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
#write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

