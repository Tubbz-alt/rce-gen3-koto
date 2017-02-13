# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/rce-gen3-fw-lib/DpmCore

# Load local Source Code and constraints
loadSource -sim_only -dir "$::DIR_PATH/rtl/"
loadSource -path           "$::DIR_PATH/Version.vhd"
