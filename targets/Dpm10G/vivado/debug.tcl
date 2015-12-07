
## Open the run
open_run synth_1

## Create core
set ilaName u_ila_0
CreateDebugCore ${ilaName}

## Configure Core
set_property C_DATA_DEPTH 2048 [get_debug_cores ${ilaName}]

## Setup Clock, Variable set in xdc file
SetDebugCoreClk ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/ethClk}

connect_debug_port dbg_hub/clk [get_nets {sysClk200}]

ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/phyRxc*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/phyRxd*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift0}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift1}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift2}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift3}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift4}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/frameShift5}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/rxdAlign}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/dlyRxd*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcDataWidth*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcDataValid}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcFifoOut*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/phyRxcDly*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcWidthDly0*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcWidthDly1*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcWidthDly2*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcWidthDly3*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcShift0}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcShift1}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/endDetect}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/endShift0}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/endShift1}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcGood}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/intLastLine}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/intAdvance}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/lastSOF}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcIn*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcInit}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcReset}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/crcOut*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/macData*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/macSize*}
ConfigProbe ${ilaName} {U_DpmCore/U_Eth10gGen.U_ZynqEthernet10G/U_EthMacTop/U_EthMacImport/rxCrcError}

## Delete the last unused port
delete_debug_port [get_debug_ports [GetCurrentProbe ${ilaName}]]

## Write the port map file
write_debug_probes -force $::env(PROJ_DIR)/debug/debug_probes.ltx

