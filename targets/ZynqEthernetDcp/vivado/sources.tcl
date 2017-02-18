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

## Set the top level file
set_property top zynq_gige_block [current_fileset]

## Set the Secure IP library 
set_property library gig_ethernet_pcs_pma_v14_3 [get_files ${PROJ_DIR}/hdl/gig_ethernet_pcs_pma_v14_3_rfs.vhd]

