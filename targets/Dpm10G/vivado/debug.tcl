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
append nl [get_nets {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[0].U_PpiSocket/U_IbPayload/U_WrDma/*}]
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
SetDebugCoreClk ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxClk}

## Set the Probes
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[0][tValid]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[0][tLast]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[0][tUser][*]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[1][tValid]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[1][tLast]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[1][tUser][*]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[2][tValid]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[2][tLast]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[2][tUser][*]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[3][tValid]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[3][tLast]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/pgpTxMasters[3][tUser][*]}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/cellTxEOC}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/cellTxEOF}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/cellTxEOFE}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/cellTxSOC}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/cellTxSOF}
ConfigProbe ${ilaName} {PGP_GTX_GEN[0].Pgp2bGtx7VarLat_1/MuliLane_Inst/U_Pgp2bLane/U_TxEnGen.U_Pgp2bTx/schTxTimeout}

## Delete the last unused port}
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${IMAGENAME}.ltx

