# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

loadIpCore -path "$::DIR_PATH/cores/ila_2.xci"
loadIpCore -path "$::DIR_PATH/cores/ila_AxiStreamDma.xci"
loadIpCore -path "$::DIR_PATH/cores/ila_DpmApp.xci"
loadIpCore -path "$::DIR_PATH/cores/ila_RceTop.xci"
loadIpCore -path "$::DIR_PATH/cores/ila_Rx2000.xci"

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/rce-gen3-fw-lib/DpmCore

# Load local Source Code and constraints
loadSource -dir       "$::DIR_PATH/hdl/"
loadConstraints -dir  "$::DIR_PATH/hdl/"

