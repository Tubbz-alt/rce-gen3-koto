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

## Setup configurations
set ilaName    u_ila_0

## Create the core
CreateDebugCore ${ilaName}

## Set the record depth
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

## Set the clock for the Core
SetDebugCoreClk ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/ethClk}

## Set the Probes

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_Reg/phyStatus[*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_Reg/macConfig[pauseTime][*]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/ethClkLock}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/ethClkRst}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/macStatus[rxPauseCnt]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/macStatus[txPauseCnt]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/bypCtrl[overflow]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/bypCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/flowCtrl[overflow]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/flowCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/primCtrl[overflow]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_FlowCtrl/primCtrl[pause]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/U_Fifo/U_Fifo/TWO_STAGE.Fifo_First_Stage/prog_full}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/U_Fifo/U_Fifo/TWO_STAGE.Fifo_Last_Stage/almost_full}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/U_Fifo/U_Fifo/TWO_STAGE.MULTI_STAGE.GEN_MULTI_STAGE[1].Fifo_Middle_Stage/almost_full}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_RxFifo/U_Fifo/U_Fifo/U_Fifo/TWO_STAGE.MULTI_STAGE.GEN_MULTI_STAGE[2].Fifo_Middle_Stage/almost_full}


ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mBypMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mBypMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mBypSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mPrimMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mPrimMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_TxFifo/mPrimSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/sAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/sAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/sAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/U_TxPauseGen.r_reg[state][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/U_TxPauseGen.r_reg[locPauseCnt][*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/pauseTime[*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/rxPauseValue[*]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Pause/macAddress[*]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Csum/sAxisMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Csum/sAxisMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Csum/sAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Export/macObMaster[tLast]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Export/macObMaster[tValid]}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_Tx/U_Export/macObSlave[tReady]}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force ${PROJ_DIR}/images/debug_probes_${PRJ_VERSION}.ltx

