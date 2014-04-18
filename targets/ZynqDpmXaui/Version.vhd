-------------------------------------------------------------------------------
-- Title         : Version Constant File
-- Project       : COB Zynq DTM
-------------------------------------------------------------------------------
-- File          : Version.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/07/2013
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module
-------------------------------------------------------------------------------
-- Copyright (c) 2012 by SLAC. All rights reserved.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"DA100006"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "Built Thu Apr 17 14:41:50 PDT 2014 by rherbst";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 04/09/2014 (0xDA100001): Initial Version
-- 04/09/2014 (0xDA100002): XAUI status over feedback bus.
-- 04/09/2014 (0xDA100003): Reg Debug
-- 04/09/2014 (0xDA100004): Self reset
-- 04/09/2014 (0xDA100005): Removed self reset, added PGP
-- 04/09/2014 (0xDA100006): PGP Fix
-------------------------------------------------------------------------------

