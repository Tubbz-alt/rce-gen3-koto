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

#############################################################################################################
#############################################################################################################
#############################################################################################################

# ## Setup configurations
# set ilaName    u_ila_0

# ## Create the core
# CreateDebugCore ${ilaName}

# ## Set the record depth
# set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

# ## Set the clock for the Core
# SetDebugCoreClk ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/ethClk}

# ## Set the Probes

# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/macAddress[*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/dropOnPause}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/filtEnable}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/mAxisCtrl[pause]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/mAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/mAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/sAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Filter/sAxisMaster[tValid]}

# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/rxShift[*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/mAxisMaster[tData][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/mAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/mAxisMaster[tUser][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/sAxisMaster[tData][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/sAxisMaster[tKeep][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/sAxisMaster[tUser][*]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/mAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/mAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/sAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Rx/U_Shift/sAxisMaster[tValid]}

# ## Delete the last unused port
# delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

#############################################################################################################
#############################################################################################################
#############################################################################################################

## Setup configurations
set ilaName    u_ila_1

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/dmaClk}

## Set the Probes

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/obMacPrimMaster[tKeep][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/obMacPrimMaster[tUser][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/obMacPrimMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/obMacPrimMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/obMacPrimSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/dmaIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/dmaIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/dmaIbSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/dmaIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/dmaIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/dmaIbSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/intIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/intIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/intIbSlave[tReady]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/payloadEn}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/iheadIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/iheadIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/iheadIbSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/ipayIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/ipayIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/ipayIbSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/headIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/headIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/headIbSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/payIbMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/payIbMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_IbRoute/payIbSlave[tReady]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

#############################################################################################################
#############################################################################################################
#############################################################################################################

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${PRJ_VERSION}.ltx

