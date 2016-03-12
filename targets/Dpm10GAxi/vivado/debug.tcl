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
set_property C_DATA_DEPTH 2048 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/axiClk}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[state]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[rMaster][araddr]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[rMaster][arsize]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[rMaster][arlen]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[rMaster][arvalid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[reqBytes]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[reqCount]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[gotCount]*}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[maxPend]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[dataEn]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[first]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_AxisDmaGen.U_RceG3DmaAxis/U_DmaChanGen[0].U_AxiStreamDma/U_ObDma/r[lastAddr]*}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force $::env(PROJ_DIR)/debug/debug_probes.ltx

